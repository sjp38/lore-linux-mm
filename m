Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF8F96B0005
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 09:49:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e1-v6so6377375pgp.20
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 06:49:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 13-v6si19304143ple.274.2018.06.04.06.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 06:49:35 -0700 (PDT)
Date: Mon, 4 Jun 2018 06:49:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Change return type int to vm_fault_t for fault
 handlers
Message-ID: <20180604134903.GA2526@bombadil.infradead.org>
References: <20180602200407.GA15200@jordon-HP-15-Notebook-PC>
 <20180602220136.GA14810@bombadil.infradead.org>
 <CAFqt6zaf1k1SvYXLrCXAvsAPC+jGQoKxR_LtUwNybdJosptQTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zaf1k1SvYXLrCXAvsAPC+jGQoKxR_LtUwNybdJosptQTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, zi.yan@cs.rutgers.edu, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, Kate Stewart <kstewart@linuxfoundation.org>, David Rientjes <rientjes@google.com>, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, yang.s@alibaba-inc.com, Minchan Kim <minchan@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Mon, Jun 04, 2018 at 10:07:16AM +0530, Souptick Joarder wrote:
> On Sun, Jun 3, 2018 at 3:31 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Sun, Jun 03, 2018 at 01:34:07AM +0530, Souptick Joarder wrote:
> >> @@ -3570,9 +3571,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >>                       return 0;
> >>               }
> >>
> >> -             ret = (PTR_ERR(new_page) == -ENOMEM) ?
> >> -                     VM_FAULT_OOM : VM_FAULT_SIGBUS;
> >> -             goto out_release_old;
> >> +             ret = vmf_error(PTR_ERR(new_page));
> >> +                     goto out_release_old;
> >>       }
> >>
> >>       /*
> >
> > Something weird happened to the goto here
> 
> Didn't get it ? Do you refer to wrong indent in goto ?

Yes.
