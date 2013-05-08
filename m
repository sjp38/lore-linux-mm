Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1D4FA6B00AE
	for <linux-mm@kvack.org>; Wed,  8 May 2013 07:50:32 -0400 (EDT)
Date: Wed, 8 May 2013 15:44:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH v2 05/11] mm: thp: Correct the HPAGE_PMD_ORDER check.
Message-ID: <20130508124417.GA29631@shutemov.name>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
 <1368006763-30774-6-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368006763-30774-6-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org

On Wed, May 08, 2013 at 10:52:37AM +0100, Steve Capper wrote:
> All Transparent Huge Pages are allocated by the buddy allocator.
> 
> A compile time check is in place that fails when the order of a
> transparent huge page is too large to be allocated by the buddy
> allocator. Unfortunately that compile time check passes when:
> HPAGE_PMD_ORDER == MAX_ORDER
> ( which is incorrect as the buddy allocator can only allocate
> memory of order strictly less than MAX_ORDER. )

It looks confusing to me. Shouldn't we fix what MAX_ORDER means instead?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
