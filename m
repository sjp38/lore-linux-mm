Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AD0196B0095
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:41:55 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so721538pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:41:55 -0800 (PST)
Date: Wed, 14 Nov 2012 15:41:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 11/11] thp, vmstat: implement HZP_ALLOC and HZP_ALLOC_FAILED
 events
In-Reply-To: <1352300463-12627-12-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141541000.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-12-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> hzp_alloc is incremented every time a huge zero page is successfully
> 	allocated. It includes allocations which where dropped due
> 	race with other allocation. Note, it doesn't count every map
> 	of the huge zero page, only its allocation.
> 
> hzp_alloc_failed is incremented if kernel fails to allocate huge zero
> 	page and falls back to using small pages.
> 

Nobody is going to know what hzp_ is, sorry.  It's better to be more 
verbose and name them what they actually are: THP_ZERO_PAGE_ALLOC and 
THP_ZERO_PAGE_ALLOC_FAILED.  But this would assume we want to lazily 
allocate them, which I disagree with hpa about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
