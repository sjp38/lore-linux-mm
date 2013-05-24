Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D76C76B0089
	for <linux-mm@kvack.org>; Fri, 24 May 2013 07:18:33 -0400 (EDT)
Date: Fri, 24 May 2013 12:18:16 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 03/11] mm: hugetlb: Copy general hugetlb code from x86
 to mm.
Message-ID: <20130524111816.GH18272@arm.com>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <1369328878-11706-4-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369328878-11706-4-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Thu, May 23, 2013 at 06:07:50PM +0100, Steve Capper wrote:
> The huge_pte_alloc, huge_pte_offset and follow_huge_p[mu]d
> functions in x86/mm/hugetlbpage.c do not rely on any architecture
> specific knowledge other than the fact that pmds and puds can be
> treated as huge ptes.
> 
> To allow other architectures to use this code (and reduce the need
> for code duplication), this patch copies these functions into mm,
> replaces the use of pud_large with pud_huge and provides a config
> flag to activate them:
> CONFIG_ARCH_WANT_GENERAL_HUGETLB

BTW, I think it's worth mentioning that pud_large is inline while
pud_huge is not.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
