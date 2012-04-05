Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 59C186B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 16:53:11 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2120765bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 13:53:09 -0700 (PDT)
Date: Fri, 6 Apr 2012 00:53:04 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120405205304.GL8718@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120402230423.GB32299@count0.beaverton.ibm.com>
 <4F7A863C.5020407@openvz.org>
 <20120403181631.GD32299@count0.beaverton.ibm.com>
 <20120403193204.GE3370@moon>
 <20120405202904.GB7761@count0.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405202904.GB7761@count0.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Apr 05, 2012 at 01:29:04PM -0700, Matt Helsley wrote:
...
> > > Doesn't that break the semantics of the kernel ABI?
> > 
> > Which one? exe_file can be changed iif there is no MAP_EXECUTABLE left.
> > Still, once assigned (via this prctl) the mm_struct::exe_file can't be changed
> > again, until program exit.
> 
> The prctl() interface itself is fine as it stands now.
> 
> As far as I can tell Konstantin is proposing that we remove the unusual
> counter that tracks the number of mappings of the exe_file and require
> userspace use the prctl() to drop the last reference. That's what I think
> will break the ABI because after that change you *must* change userspace
> code to use the prctl(). It's an ABI change because the same sequence of
> system calls with the same input bits produces different behavior.

Hi Matt, I see what you mean (I misread your email at first, sorry).
Sure it's impossible to patch already existing programs (and btw, this
prctl code actually won't help a program to drop symlink completely
and live without it then, because old one will gone but new one
will be assigned) so personally I can't answer here on Konstantin's
behalf, but I guess the main question is -- which programs use this
'drop-all-MAP_EXECUTABLE' feature?

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
