Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1EA156B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 15:32:12 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so90685bkw.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 12:32:10 -0700 (PDT)
Date: Tue, 3 Apr 2012 23:32:04 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120403193204.GE3370@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120402230423.GB32299@count0.beaverton.ibm.com>
 <4F7A863C.5020407@openvz.org>
 <20120403181631.GD32299@count0.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120403181631.GD32299@count0.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Apr 03, 2012 at 11:16:31AM -0700, Matt Helsley wrote:
> On Tue, Apr 03, 2012 at 09:10:20AM +0400, Konstantin Khlebnikov wrote:
> > Matt Helsley wrote:
> > >On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
> > >>On 03/31, Konstantin Khlebnikov wrote:
> > >>>
> > >>>comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
> > >>>where all this stuff was introduced:
> > >>>
> > >>>>...
> > >>>>This avoids pinning the mounted filesystem.
> > >>>
> > >>>So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
> > >>>fix some hypothetical pinning fs from umounting by mm which already unmapped all
> > >>>its executable files, but still alive. Does anyone know any real world example?
> > >>
> > >>This is the question to Matt.
> > >
> > >This is where I got the scenario:
> > >
> > >https://lkml.org/lkml/2007/7/12/398
> > 
> > Cyrill Gogcunov's patch "c/r: prctl: add ability to set new mm_struct::exe_file"
> > gives userspace ability to unpin vfsmount explicitly.
> 
> Doesn't that break the semantics of the kernel ABI?

Which one? exe_file can be changed iif there is no MAP_EXECUTABLE left.
Still, once assigned (via this prctl) the mm_struct::exe_file can't be changed
again, until program exit.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
