Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97A138E0085
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 10:34:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id t18so7044329qtj.3
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 07:34:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m41si19800708qvh.168.2019.01.24.07.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 07:34:37 -0800 (PST)
Date: Thu, 24 Jan 2019 10:34:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH RFC 04/24] mm: gup: allow VM_FAULT_RETRY for multiple
 times
Message-ID: <20190124153431.GB5030@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-5-peterx@redhat.com>
 <20190121162455.GC3711@redhat.com>
 <20190124070503.GJ18231@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190124070503.GJ18231@xz-x1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Thu, Jan 24, 2019 at 03:05:03PM +0800, Peter Xu wrote:
> On Mon, Jan 21, 2019 at 11:24:55AM -0500, Jerome Glisse wrote:
> > On Mon, Jan 21, 2019 at 03:57:02PM +0800, Peter Xu wrote:
> > > This is the gup counterpart of the change that allows the VM_FAULT_RETRY
> > > to happen for more than once.
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > So it would be nice to add a comment in the code and in the commit message
> > about possible fault starvation (mostly due to previous patch changes) as
> > if some one experience that and try to bisect it might overlook the commit.
> > 
> > Otherwise:
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Jerome, can I still keep this r-b if I'm going to fix the starvation
> issue you mentioned in previous patch about lock page?
> 

No please, i still want to review properly the oneline ie making sure
that it will not change any of the existing use of FAULT_FLAG_TRIED
I am finishing a bunch of patches myself so i am bit short on time right
now to take a deeper look but i will try to do that in next few days :)

In anycase i will review again your next posting.

Cheers,
Jérôme
