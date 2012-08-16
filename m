Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D40E76B0074
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 14:06:17 -0400 (EDT)
Date: Thu, 16 Aug 2012 20:06:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120816180614.GB12578@dhcp22.suse.cz>
References: <20120710104234.GI9108@mudshark.cambridge.arm.com>
 <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
 <20120712112645.GG2816@mudshark.cambridge.arm.com>
 <20120712115708.GG21013@tiehlicka.suse.cz>
 <20120807160337.GC16877@mudshark.cambridge.arm.com>
 <20120808162607.GA7885@dhcp22.suse.cz>
 <20120816160954.GA4330@mudshark.cambridge.arm.com>
 <20120816172527.GA12578@dhcp22.suse.cz>
 <20120816173459.GB7203@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816173459.GB7203@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu 16-08-12 18:34:59, Will Deacon wrote:
> On Thu, Aug 16, 2012 at 06:25:27PM +0100, Michal Hocko wrote:
> > On Thu 16-08-12 17:09:54, Will Deacon wrote:
> > > On Wed, Aug 08, 2012 at 05:26:07PM +0100, Michal Hocko wrote:
> > > > I guess the cleanest way is to hook into dequeue_huge_page_node and add
> > > > something like arch_clear_hugepage_flags.
> > > 
> > > I hooked into enqueue_huge_page instead, but how about something like this?:
> > 
> > Do you have any specific reason for that? enqueue_huge_page is called on
> > pages which potentially never get used so isn't that wasting a bit?
> > Not that it would be wrong I was just thinking why shouldn't we do it
> > when the page is actualy going to be used for sure.
> 
> I just did it that way to match the flag clearing for normal pages. I can
> move it into dequeue if you think it's worthwhile but in the worst case it
> just adds a clear_bit call, so I doubt it's measurable.

I do not have a strong opinion on that but the flags come in cleared when
they are freshly allocated (gather_surplus_pages) so then it would be
more appropriate in free_huge_page when enqueue_huge_page is called.

But this is just a nit.

> 
> Will

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
