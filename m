Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A0A5B6B006E
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:41:49 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so5240019wgh.8
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 12:41:49 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id t10si653946wif.19.2015.01.13.12.41.48
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 12:41:49 -0800 (PST)
Date: Tue, 13 Jan 2015 22:41:44 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Message-ID: <20150113204144.GA1865@node.dhcp.inet.fi>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
 <54B581C7.50206@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B581C7.50206@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 12:36:23PM -0800, Dave Hansen wrote:
> On 01/13/2015 11:14 AM, Kirill A. Shutemov wrote:
> >  	pgd_t * pgd;
> >  	atomic_t mm_users;			/* How many users with user space? */
> >  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> > -	atomic_long_t nr_ptes;			/* Page table pages */
> > +	atomic_long_t nr_pgtables;		/* Page table pages */
> >  	int map_count;				/* number of VMAs */
> 
> One more crazy idea...
> 
> There are 2^9 possible pud pages, 2^18 pmd pages and 2^27 pte pages.
> That's only 54 bits (technically minus one bit each because the upper
> half of the address space is for the kernel).

Does this math make sense for all architecures? IA64? Power?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
