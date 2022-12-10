   /*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright 2016 Oracle and/or its affiliates. All rights reserved.
 *
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates.
 * Other names may be trademarks of their respective owners.
 *
 * The contents of this file are subject to the terms of either the GNU
 * General Public License Version 2 only ("GPL") or the Common
 * Development and Distribution License("CDDL") (collectively, the
 * "License"). You may not use this file except in compliance with the
 * License. You can obtain a copy of the License at
 * http://www.netbeans.org/cddl-gplv2.html
 * or nbbuild/licenses/CDDL-GPL-2-CP. See the License for the
 * specific language governing permissions and limitations under the
 * License.  When distributing the software, include this License Header
 * Notice in each file and include the License file at
 * nbbuild/licenses/CDDL-GPL-2-CP.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the GPL Version 2 section of the License file that
 * accompanied this code. If applicable, add the following below the
 * License Header, with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 *
 * If you wish your version of this file to be governed by only the CDDL
 * or only the GPL Version 2, indicate your decision by adding
 * "[Contributor] elects to include this software in this distribution
 * under the [CDDL or GPL Version 2] license." If you do not indicate a
 * single choice of license, a recipient has the option to distribute
 * your version of this file under either the CDDL, the GPL Version 2 or
 * to extend the choice of license to its licensees as provided above.
 * However, if you add GPL Version 2 code and therefore, elected the GPL
 * Version 2 license, then the option applies only if the new code is
 * made subject to such option by the copyright holder.
 *
 * Contributor(s):
 *
 * Portions Copyrighted 2016 Sun Microsystems, Inc.
 */

package org.netbeans.modules.jcup.editor.lexer;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.netbeans.spi.lexer.LexerInput;
import org.netbeans.spi.lexer.LexerRestartInfo;
import org.netbeans.modules.jcup.editor.common.ByteStack;

@org.netbeans.api.annotations.common.SuppressWarnings({"SF_SWITCH_FALLTHROUGH", "URF_UNREAD_FIELD", "DLS_DEAD_LOCAL_STORE", "DM_DEFAULT_ENCODING", "EI_EXPOSE_REP"})
%%
%public
%class JCupColoringLexer
%type JCupTokenId
%function findNextToken
%unicode
%caseless
%char


%{
    private ByteStack stack = new ByteStack();
    private LexerInput input;
    private int pushBackCount = 0;
    private int curlyBalance = 0;
    private int curlyBalanceExpr = 0;
    private boolean hasExpression = false;
    private boolean inExpression = false;
    private boolean typeAdded = false;
    private boolean nonTerminal = false;
    private String expression; 

    public JCupColoringLexer(LexerRestartInfo info) {
        this.input = info.input();
        if(info.state() != null) {
            //reset state
            setState((LexerState) info.state());
        } else {
            //initial state
            stack.push(YYINITIAL);
            zzState = YYINITIAL;
            zzLexicalState = YYINITIAL;
        }

    }

    public static final class LexerState  {
        final ByteStack stack;
        /** the current state of the DFA */
        final int zzState;
        /** the current lexical state */
        final int zzLexicalState;

        LexerState(ByteStack stack, int zzState, int zzLexicalState) {
            this.stack = stack;
            this.zzState = zzState;
            this.zzLexicalState = zzLexicalState;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null || obj.getClass() != this.getClass()) {
                return false;
            }
            LexerState state = (LexerState) obj;
            return (this.stack.equals(state.stack)
                && (this.zzState == state.zzState)
                );
        }

        @Override
        public int hashCode() {
            int hash = 11;
            hash = 31 * hash + this.zzState;
            hash = 31 * hash + this.zzLexicalState;
            if (stack != null) {
                hash = 31 * hash + this.stack.hashCode();
            }
            return hash;
        }
    }

    public LexerState getState() {
        return new LexerState(stack.copyOf(), zzState, zzLexicalState);
    }

    public void setState(LexerState state) {
        this.stack.copyFrom(state.stack);
        this.zzState = state.zzState;
        this.zzLexicalState = state.zzLexicalState;
    }

    protected int getZZLexicalState() {
        return zzLexicalState;
    }

    //other functions

    protected void pushBack(int i) {
        yypushback(i);
    }

    protected void popState() {
        yybegin(stack.pop());
    }

    protected void pushState(final int state) {
        stack.push(getZZLexicalState());
        yybegin(state);
    }

%}

%eofval{
        if(input.readLength() > 0) {
            String yytext = yytext();
            // backup eof
            input.backup(1);
            //and return the text as error token
             return JCupTokenId.T_JAVA;
        } else {
            return null;
        }
%eofval}

%state ST_JCUP_JAVA_CODE
%state ST_JCUP_RESULT_JAVA_CODE
%state ST_JCUP_TERMINAL_DECLARATION
%state ST_JCUP_PRECEDENCE
%state ST_JCUP_SCRIPT_STATEMENT

LABEL=([[:letter:]_]|[\u007f-\u00ff])([[:letter:][:digit:]_]|[\u007f-\u00ff])*
DECLARATION_CURLY_OPEN = "{:"
DECLARATION_CURLY_CLOSE = ":}"
WHITESPACE = [ \t\f]
ANY_CHAR=[^]
//IT'S A BIT SPECULATIV, BUT NO NEED DO COMPLICATE
CLASS_NAME = [a-zA-Z] ([a-zA-Z\0-9])+
TOKEN_NAME = [A-Z] ([A-Z\_0-9])+
IDENTIFIER = {LABEL}
SEMI_COLON = ";"
COLON = ":"
INLINE_COMMENT = "//" + [^\n]+ [\n]
//comment
BLOCK_COMMENT = "/*" [^*] ~"*/" | "/*" "*"+ "/"
BLOCK_COMMENT_NL = {BLOCK_COMMENT} [ ]* [\n]
%%

/*
* COMMENTS
*/

<YYINITIAL, ST_JCUP_JAVA_CODE, ST_JCUP_RESULT_JAVA_CODE, ST_JCUP_SCRIPT_STATEMENT>{INLINE_COMMENT} | {BLOCK_COMMENT_NL} {
    yypushback(1);
    return JCupTokenId.T_JAVA; 
}

<YYINITIAL>"package" [ ] {
    yypushback(1);
    return JCupTokenId.T_JAVA; 
}

<YYINITIAL>"import" [ ] {
    yypushback(1);
    return JCupTokenId.T_JAVA; 
}

<YYINITIAL>"parser code" {WHITESPACE}+ {DECLARATION_CURLY_OPEN} {
    pushState(ST_JCUP_JAVA_CODE);
    return JCupTokenId.T_PARSER_DECLARATION_TAG;
}

/*
* DECLARATIONS
*/

<YYINITIAL>"non" [ ] {
    nonTerminal = true;
    yypushback(1);
    return JCupTokenId.T_JCUP_KEYWORD; 
}

<YYINITIAL>"terminal" [ ] {
    pushState(ST_JCUP_TERMINAL_DECLARATION);
    yypushback(1);
    typeAdded = false;
    return JCupTokenId.T_JCUP_TERMINAL; 
}

<YYINITIAL>[a-zA-Z]([a-zA-Z0-9\.])+ {
    return JCupTokenId.T_JAVA; 
}

<ST_JCUP_TERMINAL_DECLARATION>{TOKEN_NAME} {
    return JCupTokenId.T_TOKEN_NAME; 
}

<ST_JCUP_TERMINAL_DECLARATION>{CLASS_NAME}[ ] {
    yypushback(1);
    if (typeAdded) {
        return ((nonTerminal) ? JCupTokenId.T_IDENTIFIER : JCupTokenId.T_TOKEN_NAME);
    }
    typeAdded = true;
    return JCupTokenId.T_JAVA; 
}

<ST_JCUP_TERMINAL_DECLARATION>{IDENTIFIER} {
    return JCupTokenId.T_IDENTIFIER; 
}


<ST_JCUP_TERMINAL_DECLARATION>{WHITESPACE}+ {
    return JCupTokenId.T_WHITESPACE; 
}

<ST_JCUP_TERMINAL_DECLARATION>{SEMI_COLON} {
    popState();
    nonTerminal = false;
    return JCupTokenId.T_SEMI_COLON; 
}

/*
* precedence
*/

<YYINITIAL>"precedence" [ ] {
    pushState(ST_JCUP_PRECEDENCE);
    yypushback(1);
    return JCupTokenId.T_PRECEDENCE;
}

<ST_JCUP_PRECEDENCE>"left" | "right" {
    return JCupTokenId.T_JCUP_KEYWORD;
}

<ST_JCUP_PRECEDENCE>{TOKEN_NAME} {
    return JCupTokenId.T_TOKEN_NAME; 
}

<ST_JCUP_PRECEDENCE>{SEMI_COLON} {
    popState();
    nonTerminal = false;
    return JCupTokenId.T_SEMI_COLON; 
}

<ST_JCUP_PRECEDENCE>{WHITESPACE}+ {
    return JCupTokenId.T_WHITESPACE; 
}

/*
* CODE SNIPPET
*/

<ST_JCUP_JAVA_CODE>{DECLARATION_CURLY_CLOSE} {
    popState();
    return JCupTokenId.T_DECLARATION_CURLY;
}

<ST_JCUP_JAVA_CODE>[^\:\}]+ {
    return JCupTokenId.T_JAVA; 
}

<YYINITIAL>{IDENTIFIER}{WHITESPACE}+ "::=" {
    int spaceCount = 0;
    for (char c : yytext().toCharArray()) {
        if (c == ' ') {
             spaceCount++;
        }
    }
    pushState(ST_JCUP_SCRIPT_STATEMENT);
    yypushback("::=".length() + spaceCount);
    return JCupTokenId.T_IDENTIFIER;
}

<YYINITIAL, ST_JCUP_SCRIPT_STATEMENT>{WHITESPACE}+ {
    return JCupTokenId.T_WHITESPACE; 
}

<ST_JCUP_SCRIPT_STATEMENT>"::=" {
    return JCupTokenId.T_SCRIPT_DEFINITION_OPERATOR;
}

<ST_JCUP_SCRIPT_STATEMENT>{DECLARATION_CURLY_OPEN} {
    pushState(ST_JCUP_RESULT_JAVA_CODE);
    return JCupTokenId.T_DECLARATION_CURLY;
}

<ST_JCUP_RESULT_JAVA_CODE>"RESULT" {
    return JCupTokenId.T_RESULT;
}

<ST_JCUP_RESULT_JAVA_CODE>":}" {
    popState();
    return JCupTokenId.T_DECLARATION_CURLY;
}

<ST_JCUP_RESULT_JAVA_CODE>[^\:\}R]+ {
    return JCupTokenId.T_JAVA; 
}

<ST_JCUP_RESULT_JAVA_CODE>{ANY_CHAR} {
    return JCupTokenId.T_JAVA; 
}

<ST_JCUP_SCRIPT_STATEMENT>{TOKEN_NAME} {
    return JCupTokenId.T_TOKEN_NAME; 
}

<ST_JCUP_SCRIPT_STATEMENT>{TOKEN_NAME}([ ]|[\:]|[\n]) {
    yypushback(1);
    return JCupTokenId.T_TOKEN_NAME; 
}

<ST_JCUP_SCRIPT_STATEMENT>{IDENTIFIER}([ ]|[\:]|[\n]) {
    yypushback(1);
    return JCupTokenId.T_IDENTIFIER;
}


/*
* FALLBACKS
*/

<YYINITIAL, ST_JCUP_JAVA_CODE, ST_JCUP_TERMINAL_DECLARATION, ST_JCUP_PRECEDENCE, ST_JCUP_SCRIPT_STATEMENT>{ANY_CHAR} {
    return JCupTokenId.T_JAVA; 
}

<YYINITIAL, ST_JCUP_JAVA_CODE, ST_JCUP_TERMINAL_DECLARATION, ST_JCUP_PRECEDENCE, ST_JCUP_SCRIPT_STATEMENT>. {
   return  JflexTokenId.T_JAVA;
}