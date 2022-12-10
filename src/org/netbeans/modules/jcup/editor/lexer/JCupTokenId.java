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

import java.util.Collection;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import org.netbeans.api.java.lexer.JavaTokenId;
import org.netbeans.api.lexer.InputAttributes;
import org.netbeans.api.lexer.Language;
import org.netbeans.api.lexer.LanguagePath;
import org.netbeans.api.lexer.Token;
import org.netbeans.api.lexer.TokenId;
import org.netbeans.modules.jcup.editor.csl.JCupLanguage;
//import org.netbeans.modules.jflex.editor.csl.JCupLanguage;
import org.netbeans.spi.lexer.LanguageEmbedding;
import org.netbeans.spi.lexer.LanguageHierarchy;
import org.netbeans.spi.lexer.Lexer;
import org.netbeans.spi.lexer.LexerRestartInfo;

/**
 *
 * @author bhaidu
 */
public enum JCupTokenId implements TokenId {
    T_JAVA("java_embedding"),
    T_WHITESPACE("whitespace"),
    T_RESULT("keyword_result"),
    T_JCUP_KEYWORD("keyword"),
    T_JCUP_TERMINAL("keyword_terminal"),
    T_IDENTIFIER("identifier"),
    T_DECLARATION_CURLY("custom_operator"),
    T_TOKEN_NAME("token"),
    T_PARSER_DECLARATION_TAG("custom_operator"),
    T_SEMI_COLON("whitespace"),
    T_SCRIPT_DEFINITION_OPERATOR("custom_operator"),
    T_PRECEDENCE("keyword_precedence"),
    ;
    private final String primaryCategory;

    JCupTokenId(String primaryCategory) {
        this.primaryCategory = primaryCategory;
    }

    @Override
    public String primaryCategory() {
        return primaryCategory;
    }
    
    private static final Language<JCupTokenId> LANGUAGE =
            new LanguageHierarchy<JCupTokenId>() {
                @Override
                protected Collection<JCupTokenId> createTokenIds() {
                    return EnumSet.allOf(JCupTokenId.class);
                }

                @Override
                protected Map<String, Collection<JCupTokenId>> createTokenCategories() {
                    Map<String, Collection<JCupTokenId>> cats = new HashMap<String, Collection<JCupTokenId>>();
                    return cats;
                }

                @Override
                protected Lexer<JCupTokenId> createLexer(LexerRestartInfo<JCupTokenId> info) {
                   // return JCupColoringLexer.create(info);
                    return new JCupLexer(info);
                }

                @Override
                protected String mimeType() {
                    return JCupLanguage.JCUP_MIME_TYPE;
                }

                @Override
                protected LanguageEmbedding<?> embedding(Token<JCupTokenId> token,
                        LanguagePath languagePath, InputAttributes inputAttributes) {
                    Language<?> lang = null;
                    boolean join_sections = false;
                    JCupTokenId id = token.id();

                    switch (id){
                        case T_WHITESPACE:
                        case T_JAVA:
                            lang = JavaTokenId.language();
                            join_sections = true;
                            break;
                    }
                    
                    if (lang != null){
                        return LanguageEmbedding.create( lang, 0, 0, join_sections );
                    }
 
                    return null;

                }
            }.language();

    public static Language<JCupTokenId> language() {
        return LANGUAGE;
    }
}
