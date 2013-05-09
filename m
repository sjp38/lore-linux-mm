Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 3918B6B0069
	for <linux-mm@kvack.org>; Thu,  9 May 2013 04:27:21 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id y10so6003834wgg.2
        for <linux-mm@kvack.org>; Thu, 09 May 2013 01:27:19 -0700 (PDT)
Date: Thu, 9 May 2013 09:27:13 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH v2 07/11] ARM64: mm: Make PAGE_NONE pages read only
 and no-execute.
Message-ID: <20130509082712.GA28801@linaro.org>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
 <1368006763-30774-8-git-send-email-steve.capper@linaro.org>
 <20130508164341.GG20820@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130508164341.GG20820@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <Catalin.Marinas@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Wed, May 08, 2013 at 05:43:41PM +0100, Will Deacon wrote:
> On Wed, May 08, 2013 at 10:52:39AM +0100, Steve Capper wrote:
 
> Whilst it's not strictly needed for pte_exec to work, I think you should
> include PTE_PXN in the PAGE_NONE definitions as well.

Agreed, it does look a little weird without it.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
