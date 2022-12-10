package org.netbeans.modules.jcup.editor.lexer;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.netbeans.api.lexer.Token;
import org.netbeans.spi.lexer.Lexer;
import org.netbeans.spi.lexer.LexerRestartInfo;
import org.netbeans.spi.lexer.TokenFactory;
import org.openide.util.Exceptions;

/**
 *
 * @author bhaidu
 */
public class JCupLexer implements Lexer<JCupTokenId> {
    private final JCupColoringLexer scanner;
    private final TokenFactory<JCupTokenId> tokenFactory;

    public JCupLexer(LexerRestartInfo<JCupTokenId> info) {
        scanner = new JCupColoringLexer(info);
        tokenFactory = info.tokenFactory();
    }

    @Override
    public Token<JCupTokenId> nextToken() {
        try {
            JCupTokenId tokenId = scanner.findNextToken();
            Token<JCupTokenId> token = null;
            if (tokenId != null) {
                token = tokenFactory.createToken(tokenId);
            }
            return token;
        } catch (IOException ex) {
            Logger.getLogger(JCupLexer.class.getName()).log(Level.SEVERE, null, ex);
            Exceptions.printStackTrace(ex);
        }
        return null;
    }

    @Override
    public Object state() {
        return scanner.getState();
    }

    @Override
    public void release() {
    }

}
