Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id B02966B0163
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 13:16:15 -0400 (EDT)
Date: Thu, 13 Sep 2012 19:16:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 10/10] thp: implement refcounting for huge zero page
Message-ID: <20120913171613.GJ3388@redhat.com>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1347444473-26468-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347444473-26468-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi Kirill,

On Wed, Sep 12, 2012 at 01:07:53PM +0300, Kirill A. Shutemov wrote:
> -	hpage = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);

The page is likely as large as a pageblock so it's unlikely to create
much fragmentation even if the __GFP_MOVABLE is set. Said that I guess
it would be more correct if __GFP_MOVABLE was clear, like
(GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE because this page isn't
really movable (it's only reclaimable).

The xchg vs xchgcmp locking also looks good.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
