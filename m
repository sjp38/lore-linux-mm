Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA05214
	for <linux-mm@kvack.org>; Wed, 27 Nov 2002 12:11:43 -0800 (PST)
Message-ID: <3DE526FC.3D78DB54@digeo.com>
Date: Wed, 27 Nov 2002 12:11:40 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.49-mm2
References: <3DE48C4A.98979F0C@digeo.com> <20021127210153.A8411@jaquet.dk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rasmus Andersen wrote:
> 
> On Wed, Nov 27, 2002 at 01:11:38AM -0800, Andrew Morton wrote:
> >
> > url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.49/2.5.49-mm2/
> 
> I'm fairly sure this is not specific to -mm2 since it looks
> at lot like my problem from plain 2.5.49
> (http://marc.theaimsgroup.com/?l=linux-kernel&m=103805691602076&w=2)
> but -mm2 gave me some usable debug output:
> 
> Debug: Sleeping function called from illegal context at include/
> linux/rwsem.h:66
> Call Trace: __might_sleep+0x54/0x58
>            sys_mprotect+0x97/0x22b
>            syscall_call+0x7/0xb

Oh that's cute.  Looks like we've accidentally disabled preemption
somewhere...

> Unable to handle kernel paging request at virtual address 4001360c

And once you do that, the pagefault handler won't handle pagefaults.
 
> (I did not copy the rest but can reproduce at will.)

Please do.  And tell how you're making it happen.

Is that .config still current?

Does it go away if you turn off preemption?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
