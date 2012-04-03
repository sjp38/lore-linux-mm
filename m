Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3BBFF6B0044
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 14:16:50 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <matthltc@us.ibm.com>;
	Tue, 3 Apr 2012 12:16:49 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C746419D804A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 12:16:38 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q33IGZ8i057478
	for <linux-mm@kvack.org>; Tue, 3 Apr 2012 12:16:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q33IGWQN030073
	for <linux-mm@kvack.org>; Tue, 3 Apr 2012 12:16:33 -0600
Date: Tue, 3 Apr 2012 11:16:31 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120403181631.GD32299@count0.beaverton.ibm.com>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120402230423.GB32299@count0.beaverton.ibm.com>
 <4F7A863C.5020407@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F7A863C.5020407@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Cyrill Gorcunov <gorcunov@openvz.org>

On Tue, Apr 03, 2012 at 09:10:20AM +0400, Konstantin Khlebnikov wrote:
> Matt Helsley wrote:
> >On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
> >>On 03/31, Konstantin Khlebnikov wrote:
> >>>
> >>>comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
> >>>where all this stuff was introduced:
> >>>
> >>>>...
> >>>>This avoids pinning the mounted filesystem.
> >>>
> >>>So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
> >>>fix some hypothetical pinning fs from umounting by mm which already unmapped all
> >>>its executable files, but still alive. Does anyone know any real world example?
> >>
> >>This is the question to Matt.
> >
> >This is where I got the scenario:
> >
> >https://lkml.org/lkml/2007/7/12/398
> 
> Cyrill Gogcunov's patch "c/r: prctl: add ability to set new mm_struct::exe_file"
> gives userspace ability to unpin vfsmount explicitly.

Doesn't that break the semantics of the kernel ABI?

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
