Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id EAA086B0254
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:01:34 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id 128so45736541wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:01:34 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id a125si9950904wmf.3.2016.01.29.02.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 02:01:33 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id l66so60237800wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:01:33 -0800 (PST)
Date: Fri, 29 Jan 2016 12:01:31 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
Message-ID: <20160129100131.GA10918@node.shutemov.name>
References: <56A580F8.4060301@oracle.com>
 <87bn85ycbh.fsf@linux.vnet.ibm.com>
 <56AA6BE1.2050809@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56AA6BE1.2050809@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jan 28, 2016 at 11:28:33AM -0800, Mike Kravetz wrote:
> On 01/28/2016 07:05 AM, Aneesh Kumar K.V wrote:
> > Mike Kravetz <mike.kravetz@oracle.com> writes:
> > 
> >> In a search of the archives, it appears huge page support in one form or
> >> another has been a discussion topic in almost every LSF/MM gathering. Based
> >> on patches submitted this past year, huge pages is still an area of active
> >> development.  And, it appears this level of activity will  continue in the
> >> coming year.
> >>
> >> I propose a "Huge Page Futures" session to discuss large works in progress
> >> as well as work people are considering for 2016.  Areas of discussion would
> >> minimally include:
> >>
> >> - Krill Shutemov's THP new refcounting code and the push for huge page
> >>   support in the page cache.
> > 
> > I am also interested in this discussion. We had some nice challenge
> > w.r.t to powerpc implementation of THP.
> > 
> >>
> >> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
> >>   more interesting is the desire for supporting PUD pages.  This seems to
> >>   beg the question of supporting transparent PUD pages elsewhere.
> >>
> > 
> > I am also looking at switching powerpc hugetlbfs to GENERAL_HUGETLB. To
> > support 16GB pages I would need hugepage at PUD/PGD. Can you elaborate
> > why supporting huge PUD page is a challenge ?
> 
> For hugetlbfs it should not be an issue.  However, page fault handling for
> hugetlbfs is already a special case today.  Is that what you were asking?
> 
> Matt's work adds THP for PUD sized huge pages to DAX mappings.  The thought
> that popped into my head is "Does it make sense to try and expand THP for
> PUD sized pages elsewhere?".  Perhaps that is nonsense and a silly question
> to ask.

I don't think it has much sense on x86-64. But if an architecture has more
reasonable page size on PUD level, who knows...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
