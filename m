Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id ECBC56B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 19:12:47 -0400 (EDT)
Date: Thu, 16 Aug 2012 16:12:47 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Message-ID: <20120816231247.GA4461@tassilo.jf.intel.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816122023.c0e9bbc0.akpm@linux-foundation.org>
 <20120816194024.GP11188@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816194024.GP11188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

> Because this is done the right way (i.e. to allocate an hugepage at
> the first wp fault, and to fallback exclusively if compaction fails)
> it will help much less than the 4k zero pages if the zero pages are

The main benefit is that you have a zero page with THP enabled.
So it lowers the cost of having THP on (for workloads that benefit
from a zero page)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
