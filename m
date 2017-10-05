Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5F96B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:10:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so10583523wmb.0
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:10:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor9524001edc.21.2017.10.05.03.10.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 03:10:16 -0700 (PDT)
Date: Thu, 5 Oct 2017 13:10:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: Introduce wrapper to access mm->nr_ptes
Message-ID: <20171005101013.hdf7hjkcl4l7aw2a@node.shutemov.name>
References: <20171004163648.11234-1-kirill.shutemov@linux.intel.com>
 <e90bf773-330c-74d0-a0de-57e1783ebd9e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e90bf773-330c-74d0-a0de-57e1783ebd9e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Wed, Oct 04, 2017 at 11:35:47AM -0700, Mike Kravetz wrote:
> On 10/04/2017 09:36 AM, Kirill A. Shutemov wrote:
> > @@ -813,7 +813,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> >  	init_rwsem(&mm->mmap_sem);
> >  	INIT_LIST_HEAD(&mm->mmlist);
> >  	mm->core_state = NULL;
> > -	atomic_long_set(&mm->nr_ptes, 0);
> > +	mm_nr_ptes_init(mm);
> >  	mm_nr_pmds_init(mm);
> >  	mm_nr_puds_init(mm);
> >  	mm->map_count = 0;
> > @@ -869,9 +869,9 @@ static void check_mm(struct mm_struct *mm)
> >  					  "mm:%p idx:%d val:%ld\n", mm, i, x);
> >  	}
> >  
> > -	if (atomic_long_read(&mm->nr_ptes))
> > +	if (mm_nr_pmds(mm))
> 
> Should that be?
> 
> 	if (mm_nr_ptes(mm))

Thanks, for catching this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
