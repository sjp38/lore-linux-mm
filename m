Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 7B3E96B002B
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 14:33:05 -0400 (EDT)
Date: Thu, 16 Aug 2012 19:32:56 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120816183255.GB19401@mudshark.cambridge.arm.com>
References: <20120710094513.GB9108@mudshark.cambridge.arm.com>
 <20120710104234.GI9108@mudshark.cambridge.arm.com>
 <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
 <20120712112645.GG2816@mudshark.cambridge.arm.com>
 <20120712115708.GG21013@tiehlicka.suse.cz>
 <20120807160337.GC16877@mudshark.cambridge.arm.com>
 <20120808162607.GA7885@dhcp22.suse.cz>
 <20120816160954.GA4330@mudshark.cambridge.arm.com>
 <20120816182015.GC12578@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816182015.GC12578@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Aug 16, 2012 at 07:20:15PM +0100, Michal Hocko wrote:
> On Thu 16-08-12 17:09:54, Will Deacon wrote:
> > +static inline void arch_clear_hugepage_flags(struct page *page)
> > +{
> > +	flush_dcache_page(page);
> > +}
> > +
> 
> Why do we need the hook for ia64? hugetlb_no_page calls clear_huge_page
> and that one calls flush_dcache_page (via clear_user_page), right?
> The same applies to copy_huge_page for COW.

You're right, these are redundant for ppc and ia64 (although ppc does have a
comment moaning about the flush). Looks like it's just sh and ARM that need to
do anything.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
