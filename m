Received: from mea.tmt.tele.fi (mea.tmt.tele.fi [194.252.70.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA10773
	for <linux-mm@kvack.org>; Wed, 30 Dec 1998 13:31:40 -0500
Subject: Re: Large-File support of 32-bit Linux v0.01 available!
In-Reply-To: <m1iuetsfef.fsf@flinx.ccr.net> from "Eric W. Biederman" at "Dec 30, 98 11:34:00 am"
Date: Wed, 30 Dec 1998 18:29:53 +0200 (EET)
From: Matti Aarnio <matti.aarnio@sonera.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <19981230162959Z92285-18654+43@mea.tmt.tele.fi>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: matti.aarnio@sonera.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yeah.  I actually found/made time to work on this.
> This is my patch for allowing large files in the page cache.
> vm_offset is no more.  I am currently running it.

	Yeah, well, I see the code, but I don't like all
	implications of what you did.    My patches (see URL
	via Linux-MM page, or below ) do handle page-cache
	in very much similar manner, but add an abstraction
	layer on top of the simple scalar type for debug purposes.
	You could have done that too, and perhaps found earlier
	the bugs that did nag you...

> There is a little taken from Matti Aarnio (mostly syscalls, and filesystems
> I don't usually compile).  But not much as I was my empahses was on
> stabalizing my code.
> 
> I was getting really frustrated and discoraged for a while when this wasn't
> booting.  But my 2 or 3 tiny bugs looked to be ironed out.
> 
> My next round of work will add a struct vm_store which will replace
> inode in the page cache, and allow full 64bit file sizes (by multiple
> vmstore's per inode) and unaligned data in the page cache.   The file
> size limit will again be on inodes.  But the generic code (under the vfs)
> will not support unaligned data (and doesn't need to).

	Why unaligned data at the page-cache ?
	And why more than PAGE_SIZE * 4G for file sizes in 32-bit systems ?
	After all, that gives us 16 TB file sizes.

	I would like to wait a bit to hear, what Stephen has to say.

> Then I plan to aim for writing code for:
>  - One single dirty page write out mechanism.
>  - One single clean page freeing mechanism.
>  - One single page removal mechanism. 
> 
> And hopefully have it all ready for early 2.3
> 
> Matti.  I don't have access to the LFS spec, and that really isn't
> where my interest lies, so I'll leave the syscalls to you.

	All those are referenced at my LFS patch area.
	(See README) -- and some even copied there.
	( ftp://mea.ipv6.tmt.tele.fi/linux/LFS/ -- and for non-IPv6 users:
	  ftp://mea.tmt.tele.fi/linux/LFS/ )

	You sure did scramble the  *stat()  syscall family.
	I did have *VERY* good reasons to do them the way I did.
	The LFS tells that  ino_t  shall be 64-bit type, thus
	even Alpha 'struct stat' will not be sufficient..
	And at the same time I took care of 'uid_t' expansion
	to at least 32-bits.


	I seem to have a cold/flu, which means I will have copious
	amounts of idle time at home, as I can't get to work for
	following few days :-/~ (nor much celebrate the new-year)

> Now I'm off on vacation for the rest of this week.  And probably won't
> have time until the first weekend in January to really work anymore on this.
> 
> Eric

/Matti Aarnio <matti.aarnio@sonera.fi>
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
