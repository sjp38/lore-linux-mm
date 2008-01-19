In-reply-to: <4df4ef0c0801181148y8d446c7ifb23677dbf4ea0c9@mail.gmail.com>
	(salikhmetov@gmail.com)
Subject: Re: [PATCH -v6 0/2] Fixing the issue with memory-mapped file times
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu> <4df4ef0c0801181148y8d446c7ifb23677dbf4ea0c9@mail.gmail.com>
Message-Id: <E1JGBCh-0002Li-Ug@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 19 Jan 2008 11:45:35 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: miklos@szeredi.hu, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> 2008/1/18, Miklos Szeredi <miklos@szeredi.hu>:
> > > 4. Performance test was done using the program available from the
> > > following link:
> > >
> > > http://bugzilla.kernel.org/attachment.cgi?id=14493
> > >
> > > Result: the impact of the changes was negligible for files of a few
> > > hundred megabytes.
> >
> > Could you also test with ext4 and post some numbers?  Afaik, ext4 uses
> > nanosecond timestamps, so the time updating code would be exercised
> > more during the page faults.
> >
> > What about performance impact on msync(MS_ASYNC)?  Could you please do
> > some measurment of that as well?
> 
> Did a quick test on an ext4 partition. This is how it looks like:

Thanks for running these tests.

I was more interested in the slowdown on ext4 (checked with the above
mentioned program).  Can you do such a test as well, and post
resulting times with and without the patch?

> Table 1. Reference platforms.
> 
> ------------------------------------------------------------
> |             | HP-UX/PA-RISC | HP-UX/Itanium | FreeBSD    |
> ------------------------------------------------------------
> | First run   | 263405 usec   | 202283 usec   | 90 SECONDS |
> ------------------------------------------------------------
> | Second run  | 262253 usec   | 172837 usec   | 90 SECONDS |
> ------------------------------------------------------------
> | Third run   | 238465 usec   | 238465 usec   | 90 SECONDS |
> ------------------------------------------------------------
> 
> It looks like FreeBSD is a clear outsider here. Note that FreeBSD
> showed an almost liner depencence of the time spent in the
> msync(MS_ASYNC) call on the file size.
> 
> Table 2. The Qemu system. File size is 512M.
> 
> ---------------------------------------------------
> |            | Before the patch | After the patch |
> ---------------------------------------------------
> | First run  |     35 usec      |   5852 usec     |
> ---------------------------------------------------
> | Second run |     35 usec      |   4444 usec     |
> ---------------------------------------------------
> | Third run  |     35 usec      |   6330 usec     |
> ---------------------------------------------------

Interesting.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
