Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97A906B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 22:02:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t184so113610627pgt.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 19:02:03 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id o4si9179675plb.97.2017.03.02.19.02.02
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 19:02:02 -0800 (PST)
Date: Fri, 3 Mar 2017 12:01:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
Message-ID: <20170303030158.GD3503@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-2-git-send-email-minchan@kernel.org>
 <e7a05d50-4fa8-66ce-9aa0-df54f21be0d8@linux.vnet.ibm.com>
MIME-Version: 1.0
In-Reply-To: <e7a05d50-4fa8-66ce-9aa0-df54f21be0d8@linux.vnet.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>

On Thu, Mar 02, 2017 at 07:57:10PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > SWAP_SUCCESS defined value 0 can be changed always so don't rely on
> > it. Instead, use explict macro.
> 
> Right. But should not we move the changes to the callers last in the
> patch series after doing the cleanup to the try_to_unmap() function
> as intended first.

I don't understand what you are pointing out. Could you elaborate it
a bit?

Thanks.

> 
> > > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/huge_memory.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 092cc5c..fe2ccd4 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2114,7 +2114,7 @@ static void freeze_page(struct page *page)
> >  		ttu_flags |= TTU_MIGRATION;
> >  
> >  	ret = try_to_unmap(page, ttu_flags);
> > -	VM_BUG_ON_PAGE(ret, page);
> > +	VM_BUG_ON_PAGE(ret != SWAP_SUCCESS, page);
> >  }
> >  
> >  static void unfreeze_page(struct page *page)
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
