Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id PAA00927
	for <linux-mm@kvack.org>; Tue, 20 Jun 2000 15:19:34 +0100
Subject: ac22 classzone vs. riel
From: "John Fremlin" <vii@penguinpowered.com>
Date: 20 Jun 2000 15:19:33 +0100
Message-ID: <m2og4wxwne.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

System is 64 Mo RAM, no swap, 8 Mo/s sustained rate from hd.

Classzone

        + very good interactive perf., buzzes like mad but lets me
        keep typing smoothly when stressed: as things should be (none
        of the annoying few second freezeups)

Riel
        + faster than classzone (gut feeling)

        - still freezes up for seconds at odd points when
        stressed. Pressing SysREQ-p keeps dumping PCs in swap_out.

IOW, all the tuning people have done to the riel branch has paid off,
but there is still something bigtime screwed up in it.

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
