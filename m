Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A285B6B00F0
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:10:23 -0400 (EDT)
Date: Wed, 12 Sep 2012 19:10:20 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-ID: <20120912181020.GH32234@mudshark.cambridge.arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-4-git-send-email-will.deacon@arm.com>
 <20120912153206.GT21579@dhcp22.suse.cz>
 <5050CF33.4000909@tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5050CF33.4000909@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Steve Capper <Steve.Capper@arm.com>

On Wed, Sep 12, 2012 at 07:06:43PM +0100, Chris Metcalf wrote:
> On 9/12/2012 11:32 AM, Michal Hocko wrote:
> > Makes sense if there are going to be more archs to support THP.
> 
> The tile architecture currently supports it in our in-house tree,
> though we haven't returned it to the community yet.

That's a similar situation for AArch64. We hope to post the arm patches
pretty soon though, just ironing out some issues with the thp code.

Unfortunately, it looks like there might be one more change to the core
code as we don't have hardware page aging and need to manipulate the YOUNG
bit explicitly.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
