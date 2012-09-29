Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3ADD16B006C
	for <linux-mm@kvack.org>; Sat, 29 Sep 2012 10:30:07 -0400 (EDT)
Date: Sat, 29 Sep 2012 07:30:06 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20120929143006.GC4110@tassilo.jf.intel.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120929134811.GC26989@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Sat, Sep 29, 2012 at 03:48:11PM +0200, Andrea Arcangeli wrote:
> On Sat, Sep 29, 2012 at 02:37:18AM +0300, Kirill A. Shutemov wrote:
> > Cons:
> >  - increases TLB pressure;
> 
> I generally don't like using 4k tlb entries ever. This only has the

>From theory I would also prefer the 2MB huge page.

But some numbers comparing between the two alternatives are definitely
interesting.  Numbers are often better than theory.

> There would be a small cache benefit here... but even then some first
> level caches are virtually indexed IIRC (always physically tagged to

Modern x86 doesn't have virtually indexed caches.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
