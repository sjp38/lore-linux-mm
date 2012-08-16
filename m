Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 788516B0074
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 14:19:40 -0400 (EDT)
Date: Thu, 16 Aug 2012 19:19:31 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120816181931.GA19401@mudshark.cambridge.arm.com>
References: <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
 <20120712112645.GG2816@mudshark.cambridge.arm.com>
 <20120712115708.GG21013@tiehlicka.suse.cz>
 <20120807160337.GC16877@mudshark.cambridge.arm.com>
 <20120808162607.GA7885@dhcp22.suse.cz>
 <20120816160954.GA4330@mudshark.cambridge.arm.com>
 <20120816172527.GA12578@dhcp22.suse.cz>
 <20120816173459.GB7203@mudshark.cambridge.arm.com>
 <20120816180614.GB12578@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816180614.GB12578@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Aug 16, 2012 at 07:06:14PM +0100, Michal Hocko wrote:
> On Thu 16-08-12 18:34:59, Will Deacon wrote:
> > I just did it that way to match the flag clearing for normal pages. I can
> > move it into dequeue if you think it's worthwhile but in the worst case it
> > just adds a clear_bit call, so I doubt it's measurable.
> 
> I do not have a strong opinion on that but the flags come in cleared when
> they are freshly allocated (gather_surplus_pages) so then it would be
> more appropriate in free_huge_page when enqueue_huge_page is called.

Makes sense, I'll move the call into free_huge_page.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
