Date: Tue, 20 Jun 2000 23:13:46 -0300
Subject: linux-2.4.0-test1-ac22-riel+quintela
Message-ID: <20000620231346.A9382@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Finished the testing here on leaf (the 386).

dpkg --list caused kswapd get at 25% CPU max (an spike while doing the final
printing) and 12% on average (and also max before it started printing).

It was fast enough to be usable (not as fast as ac19 with that test deleted,
but if it's faster on other boxen I can stand it =) ).

vmstat 1 updates sometimes got delayed by about 2-3 secs (comparing with vmstat
in the other (unloaded) box). Hacked ac19 didn't have these delays.

Free memory normal (unlike hacked ac19 which had a bit more free mem).

The test was with ac22-riel and both quintela's patches for ac22-riel, plus my
own nvramfix5 patch (harmless since it's in a module).

So ac19 without the zone tests in shrink_mmap still win. I wonder why.

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
