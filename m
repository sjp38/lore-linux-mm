Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDA58E0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:32:00 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so23369427qtr.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:32:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q123si4667951qkd.203.2019.01.22.00.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:31:59 -0800 (PST)
Date: Tue, 22 Jan 2019 16:31:46 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 05/24] userfaultfd: wp: add helper for writeprotect
 check
Message-ID: <20190122083146.GD14907@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-6-peterx@redhat.com>
 <20190121102312.GD19725@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121102312.GD19725@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, Jan 21, 2019 at 12:23:12PM +0200, Mike Rapoport wrote:
> On Mon, Jan 21, 2019 at 03:57:03PM +0800, Peter Xu wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > add helper for writeprotect check. Will use it later.
> 
> I'd merge this with the commit that actually uses this helper.

Hi, Mike,

Yeah actually that's what I'd prefer for most of the time.  But I'm
trying to avoid doing that because I wanted to keep the credit of the
original authors, not only for this single patch, but also for the
whole series.  Meanwhile, since this work has been there for quite a
few years (starting from 2015), IMHO keeping the old patches mostly
untouched at least in the RFC stage might also help the reviewers if
they have read or prior knowledge of the previous work.

And if the patch cannot even stand on itself (this one can; it only
introduces new functions) I'll do the merge no matter what.

Please correct me if this is not the good way to do.

Thanks!

>  
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  include/linux/userfaultfd_k.h | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > index 37c9eba75c98..38f748e7186e 100644
> > --- a/include/linux/userfaultfd_k.h
> > +++ b/include/linux/userfaultfd_k.h
> > @@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
> >  	return vma->vm_flags & VM_UFFD_MISSING;
> >  }
> > 
> > +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> > +{
> > +	return vma->vm_flags & VM_UFFD_WP;
> > +}
> > +
> >  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
> >  {
> >  	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
> > @@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
> >  	return false;
> >  }
> > 
> > +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> > +{
> > +	return false;
> > +}
> > +
> >  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
> >  {
> >  	return false;
> > -- 
> > 2.17.1
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

Regards,

-- 
Peter Xu
