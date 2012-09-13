Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id DBCDE6B017D
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 17:17:08 -0400 (EDT)
Date: Thu, 13 Sep 2012 23:17:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 10/10] thp: implement refcounting for huge zero page
Message-ID: <20120913211705.GM3388@redhat.com>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1347444473-26468-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120913171613.GJ3388@redhat.com>
 <20120913173758.GA4181@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913173758.GA4181@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

Hi Kirill,

On Thu, Sep 13, 2012 at 08:37:58PM +0300, Kirill A. Shutemov wrote:
> On Thu, Sep 13, 2012 at 07:16:13PM +0200, Andrea Arcangeli wrote:
> > Hi Kirill,
> > 
> > On Wed, Sep 12, 2012 at 01:07:53PM +0300, Kirill A. Shutemov wrote:
> > > -	hpage = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
> > 
> > The page is likely as large as a pageblock so it's unlikely to create
> > much fragmentation even if the __GFP_MOVABLE is set. Said that I guess
> > it would be more correct if __GFP_MOVABLE was clear, like
> > (GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE because this page isn't
> > really movable (it's only reclaimable).
> 
> Good point. I'll update the patchset.
> 
> > The xchg vs xchgcmp locking also looks good.
> > 
> > Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Is it for the whole patchset? :)

It was meant for this one, but I reviewed the whole patchset and it
looks fine to me, so in this case it can apply to the whole patchset ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
