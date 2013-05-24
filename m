Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4503B6B0088
	for <linux-mm@kvack.org>; Fri, 24 May 2013 07:22:03 -0400 (EDT)
Date: Fri, 24 May 2013 12:21:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 07/11] ARM64: mm: Make PAGE_NONE pages read only and
 no-execute.
Message-ID: <20130524112149.GJ18272@arm.com>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <1369328878-11706-8-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369328878-11706-8-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Thu, May 23, 2013 at 06:07:54PM +0100, Steve Capper wrote:
> If we consider the following code sequence:
> 
> 	my_pte = pte_modify(entry, myprot);
> 	x = pte_write(my_pte);
> 	y = pte_exec(my_pte);
> 
> If myprot comes from a PROT_NONE page, then x and y will both be
> true which is undesireable behaviour.
> 
> This patch sets the no-execute and read-only bits for PAGE_NONE
> such that the code above will return false for both x and y.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
