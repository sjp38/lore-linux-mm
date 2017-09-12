Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4536B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 17:12:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f4so11468706wmh.7
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 14:12:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q204sor2845597wmb.91.2017.09.12.14.12.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 14:12:54 -0700 (PDT)
Date: Tue, 12 Sep 2017 23:12:50 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm, hugetlb, soft_offline: save compound page order
 before page migration
Message-ID: <20170912211250.GB16850@gmail.com>
References: <20170912204306.GA12053@gmail.com>
 <20170912135448.341359676c6f8045f4a622f0@linux-foundation.org>
 <20170912135835.0b48340ead5570e50529f676@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170912135835.0b48340ead5570e50529f676@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@suse.com, aarcange@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, shli@fb.com, rppt@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, rientjes@google.com, riel@redhat.com, linux-mm@kvack.org

On Tue, Sep 12, 2017 at 01:58:35PM -0700, Andrew Morton wrote:
> On Tue, 12 Sep 2017 13:54:48 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 12 Sep 2017 22:43:06 +0200 Alexandru Moise <00moses.alexander00@gmail.com> wrote:
> > 
> > > This fixes a bug in madvise() where if you'd try to soft offline a
> > > hugepage via madvise(), while walking the address range you'd end up,
> > > using the wrong page offset due to attempting to get the compound
> > > order of a former but presently not compound page, due to dissolving
> > > the huge page (since c3114a8).
> > 
> > What are the user visible effects of the bug?  The wrong page is
> > offlined?  No offlining occurs?  
> 
> This also affects MADV_HWPOISON?

No, MADV_HWPOISON is ok because it doesn't dissolve the hugepage, so the page
remains a compound page the 2nd loop around.

../Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
