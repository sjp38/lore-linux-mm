Received: from cnode1.sys ([172.16.10.10])
	by gate.sys with esmtp (Exim 3.12 #1 (Debian))
	id 16FeEZ-0000BH-00
	for <linux-mm@kvack.org>; Sun, 16 Dec 2001 17:33:51 +0100
Received: from cnode1.sys (localhost [127.0.0.1])
	by cnode1.sys (8.12.1/8.12.1/Debian -2) with ESMTP id fBGGjj3C000791
	for <linux-mm@kvack.org>; Sun, 16 Dec 2001 17:45:45 +0100
Received: (from volker@localhost)
	by cnode1.sys (8.12.1/8.12.1/Debian -2) id fBGGjj02000789
	for linux-mm@kvack.org; Sun, 16 Dec 2001 17:45:45 +0100
From: V.Dormeyer@t-online.de (Volker Dormeyer)
Date: Sun, 16 Dec 2001 17:45:40 +0100
Subject: VM questions
Message-ID: <20011216164540.GA766@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

last week I asked the following questions on the kernelnewbies
mailinglist. I haven't got any response, yet. Perhaps somebody
on this list can help me.

What are the /proc/sys/vm/max-readahead and /proc/sys/vm/min-readahead
are for? I find some mails about it in the kernel-mailinglist archive.
But I didn't understand the concept behind these parameters.

/proc/sys/vm/pagetable_cache is described in the kernel documentation.
I don't understand, why do we have/need a per processor cache? Can
someone explain more about that?

Thanks,
Volker

-- 
 Volker Dormeyer # V.Dormeyer@t-online.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
