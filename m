Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C66D46B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 08:48:17 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so16956514wid.5
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:48:16 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id cv8si61784028wjc.78.2015.02.23.05.48.14
        for <linux-mm@kvack.org>;
        Mon, 23 Feb 2015 05:48:15 -0800 (PST)
Date: Mon, 23 Feb 2015 15:48:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/24] huge tmpfs: an alternative approach to THPageCache
Message-ID: <20150223134810.GB7322@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 20, 2015 at 07:49:16PM -0800, Hugh Dickins wrote:
> I warned last month that I have been working on "huge tmpfs":
> an implementation of Transparent Huge Page Cache in tmpfs,
> for those who are tired of the limitations of hugetlbfs.
> 
> Here's a fully working patchset, against v3.19 so that you can give it
> a try against a stable base.  I've not yet studied how well it applies
> to current git: probably lots of easily resolved clashes with nonlinear
> removal.  Against mmotm, the rmap.c differences looked nontrivial.
> 
> Fully working?  Well, at present page migration just keeps away from
> these teams of pages.  And once memory pressure has disbanded a team
> to swap it out, there is nothing to put it together again later on,
> to restore the original hugepage performance.  Those must follow,
> but no thought yet (khugepaged? maybe).
> 
> Yes, I realize there's nothing yet under Documentation, nor fs/proc
> beyond meminfo, nor other debug/visibility files: must follow, but
> I've cared more to provide the basic functionality.
> 
> I don't expect to update this patchset in the next few weeks: now that
> it's posted, my priority is look at other people's work before LSF/MM;
> and in particular, of course, your (Kirill's) THP refcounting redesign.

I scanned through the patches to get general idea on how it works. I'm not
sure that I will have time and will power to do proper code-digging before
the summit. I found few bugs in my patchset which I want to troubleshoot
first.

One thing I'm not really comfortable with is introducing yet another way
to couple pages together. It's less risky in short term than my approach
-- fewer existing codepaths affected, but it rises maintaining cost later.
Not sure it's what we want.

After Johannes' work which added exceptional entries to normal page cache
I hoped to see shmem/tmpfs implementation moving toward generic page
cache. But this patchset is step in other direction -- it makes
shmem/tmpfs even more special-cased. :(

Do you have any insights on how this approach applies to real filesystems?
I don't think there's any show stopper, but better to ask early ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
