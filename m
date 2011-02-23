Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E34C78D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:40:07 -0500 (EST)
Date: Wed, 23 Feb 2011 23:39:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 29772] New: memory compaction crashed
Message-ID: <20110223233934.GN15652@csn.ul.ie>
References: <bug-29772-27@https.bugzilla.kernel.org/> <20110223134015.be96110b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110223134015.be96110b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, johannes@sipsolutions.net

On Wed, Feb 23, 2011 at 01:40:15PM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 23 Feb 2011 21:31:41 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=29772
> > 
> >            Summary: memory compaction crashed
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.38-rc6-wl-65354-geac0466-dirty
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: johannes@sipsolutions.net
> >         Regression: No
> > 
> > 
> > see attached image
> 
> screenshot here: https://bugzilla.kernel.org/attachment.cgi?id=48772
> 

isolate_migratepages is hit any time compaction runs so I'm wondering
what is special about this test case. I'm assuming as evince crashed
that it's a normalish desktop and wasn't running anything in particular.
Is that true?

Can you tell me what line the instruction ffffffff8100f1c2 corresponds to? If
you have CONFIG_DEBUG_INFO set, it should be a case of telling me what the
output of "addr2line -e vmlinux 0xffffffff8100f1c2" is. On a similar note,
do you know what sort of crash this was? i.e. was it a NULL deference or
did a VM_BUG_ON or BUG_ON hit such as VM_BUG_ON(PageTransCompound(page))?
Was CONFIG_DEBUG_VM set? Actually, it would be preferable to have the
whole .config attached to the bugzilla if possible please.

Can I also see a full dmesg with the kernel parameters "loglevel=9
mminit_loglevel=4" please? I know the crash won't be included but I want
to see what your memory layout looks like to see can I spot anything
unusual about it.

I see fuse was loaded. Was it being heavily used at the time? If so,
what sort of workload was exercising it?

I *think* the kernel version is 2.6.38-rc6-wl-65354-geac0466-dirty. I'm
not certain because there is a big shine from the camera flash on it.
However, I can't see what this corresponds to. eac0466 is not a commit I
can identify and the "dirty" implies that it's patched. How does this
kernel differ from mainline?

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
