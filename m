Received: from localhost by fenrus.demon.nl
	via sendmail with esmtp
	id <m13DYMa-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for <linux-mm@kvack.org>; Sat, 15 Jul 2000 22:16:40 +0200 (CEST)
Date: Sat, 15 Jul 2000 22:16:36 +0200 (CEST)
From: Arjan van de Ven <arjan@fenrus.demon.nl>
Subject: Re: [patch] 2.4.0-test4 filemap.c
In-Reply-To: <Pine.LNX.4.21.0007151534260.17208-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.05.10007152215130.27823-100000@fenrus.demon.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 15 Jul 2000, Rik van Riel wrote:

> Hi,
> 
> the patch below could make filemap.c better behaved.

My system with both your patches works REALLY great. No unneeded swapouts
if there is plenty of ram free (like 16Mb), no trimming of the cache until
there is only 2 Mb free, and only swapping the old stuff when I ask
Mozilla to start....

I hope these patches make it into the kernel, at least until the new VM is
ready...


Greetings,
   Arjan van de Ven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
