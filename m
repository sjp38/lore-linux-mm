Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 11D2A6B004D
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 19:05:17 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <matthltc@us.ibm.com>;
	Mon, 2 Apr 2012 19:05:15 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 57BAC38C8052
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 19:04:27 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q32N4RL32924544
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 19:04:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q32N4R80002406
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 20:04:27 -0300
Date: Mon, 2 Apr 2012 16:04:23 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120402230423.GB32299@count0.beaverton.ibm.com>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120331201324.GA17565@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Matt Helsley <matthltc@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Cyrill Gorcunov <gorcunov@openvz.org>

On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
> On 03/31, Konstantin Khlebnikov wrote:
> >
> > comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
> > where all this stuff was introduced:
> >
> > > ...
> > > This avoids pinning the mounted filesystem.
> >
> > So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
> > fix some hypothetical pinning fs from umounting by mm which already unmapped all
> > its executable files, but still alive. Does anyone know any real world example?
> 
> This is the question to Matt.

This is where I got the scenario:

https://lkml.org/lkml/2007/7/12/398

Cheers,
	-Matt Helsley

PS: I seem to keep coming back to this so I hope folks don't mind if I leave
some more references to make (re)searching this topic easier:

Thread with Cyrill Gorcunov discussing c/r of symlink:
https://lkml.org/lkml/2012/3/16/448

Thread with Oleg Nesterov re: cleanups:
https://lkml.org/lkml/2012/3/5/240

Thread with Alexey Dobriyan re: cleanups:
https://lkml.org/lkml/2009/6/4/625

mainline commit 925d1c401fa6cfd0df5d2e37da8981494ccdec07
Date:   Tue Apr 29 01:01:36 2008 -0700

	procfs task exe symlink

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
