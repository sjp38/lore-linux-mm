Date: Tue, 15 Aug 2000 19:25:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH*] new VM patch for 2.4.0-test7-pre4
Message-ID: <Pine.LNX.4.21.0008151922360.2466-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

I spent some time today porting the new VM patch to
2.4.0-test7-pre4, *and* tuning the new VM patch for
performance (yesterday's one wasn't tuned yet).

The new patch should be fine for general use and is
available at http://www.surriel.com/patches/2.4.0-t7p4-vmpatch2

The only thing "unstable" with this patch is that it
seems to catch an SMP race in filemap.c, simply because
this patch has debugging code that isn't in the stock
kernel (and the stock kernel would corrupt the lru list).

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
