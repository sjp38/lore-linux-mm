Received: from mea.tmt.tele.fi (root@mea.tmt.tele.fi [194.252.70.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA27433
	for <linux-mm@kvack.org>; Sun, 27 Dec 1998 19:07:01 -0500
Subject: Re: Large-File support of 32-bit Linux v0.01 available!
In-Reply-To: <m167ay5bb1.fsf@flinx.ccr.net> from "Eric W. Biederman" at "Dec 27, 98 00:49:38 am"
Date: Mon, 28 Dec 1998 00:04:37 +0200 (EET)
From: Matti Aarnio <matti.aarnio@sonera.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <19981227220446Z92289-18655+40@mea.tmt.tele.fi>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: matti.aarnio@sonera.fi, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Eric W. Biederman replied to my challenge on large file offsets on
Linux kernel:
..
> I started on it a while ago but I've be extremly short on free time.
> 
> The following is a patch you will need if you intend to make everything page
> aligned in the page cache.  It removes the need for old that old a.out binaries
> have for unaligned mappings, leaving only the page alinged QMAGIC
> a.out binaries still in a position to do code sharing.  The rest
> continue to work and just print anoying warnings. (Reminding me it's
> time I upgrade some of my old slackware 2.2 software...)

	Ok, I added those in.

> I have some other logic mostly complete that keeps offset parameter in
> the vm_area struct at 32 bits, and hopefully a greater chunck of the
> page cache.

	You mean 'vm_offset' field ?
	There are 37 files with (sub)string 'vm_offset' in them.
	Changeing its type from current  loff_t  to  pgoff_t  would
	help finding its instances, I guess.  (And thus ease locating
	places using it for page (non-)aligned things.)

	That part about "a greater chunk" I don't understand, though.

> If I have the time I'll finish merging that with your start on the
> system calls.
> 
> Eric

/Matti Aarnio <matti.aarnio@sonera.fi>
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
