Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3CC246B0088
	for <linux-mm@kvack.org>; Fri, 24 May 2013 07:18:59 -0400 (EDT)
Date: Fri, 24 May 2013 12:18:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 05/11] mm: thp: Correct the HPAGE_PMD_ORDER check.
Message-ID: <20130524111842.GI18272@arm.com>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <1369328878-11706-6-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369328878-11706-6-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Thu, May 23, 2013 at 06:07:52PM +0100, Steve Capper wrote:
> All Transparent Huge Pages are allocated by the buddy allocator.
> 
> A compile time check is in place that fails when the order of a
> transparent huge page is too large to be allocated by the buddy
> allocator. Unfortunately that compile time check passes when:
> HPAGE_PMD_ORDER == MAX_ORDER
> ( which is incorrect as the buddy allocator can only allocate
> memory of order strictly less than MAX_ORDER. )
> 
> This patch updates the compile time check to fail in the above
> case.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
