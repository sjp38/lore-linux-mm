From: jordi polo <wigsm@LatinMail.com>
Date: Wed, 16 Aug 2000 19:59:23 -0400
Subject: riel's patch really works
Message-Id: <200008161959503.SM00150@latinmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

i have tested riel's vm patch in a k6-2 64mb with 2.4.0test6 some other patch  riel patch and it made a improvement not very spectacular but it seemed it did it, specially it improve work with netscape6pre2 (it use a lot of memory).
I have also probe it in a 486/16mb(same kernel) and it has been impresive, with kde   1 virtual terminal   netscape 4.5 it didn't take any swap ,(usually it would take about 10-15mb) The bad point is that even when i don't see anything in the code that can cause it (and my opinion it's not very valid) i think i have seen a little cpu overwork. 






_________________________________________________________
http://www.latinmail.com.  Gratuito, latino y en espanol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
