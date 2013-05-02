Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D05796B0257
	for <linux-mm@kvack.org>; Thu,  2 May 2013 06:05:18 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so376466wgh.18
        for <linux-mm@kvack.org>; Thu, 02 May 2013 03:05:17 -0700 (PDT)
Date: Thu, 2 May 2013 11:05:08 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH 8/9] ARM64: mm: Introduce MAX_ZONE_ORDER for 64K
 and THP.
Message-ID: <20130502100507.GA19880@linaro.org>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-9-git-send-email-steve.capper@linaro.org>
 <20130502100000.GB20730@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130502100000.GB20730@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Thu, May 02, 2013 at 11:00:00AM +0100, Catalin Marinas wrote:
> On Tue, Apr 30, 2013 at 05:30:47PM +0100, Steve Capper wrote:
 
> Can we just keep some sane defaults here without giving too much choice
> to the user? Something like:
> 
> config FORCE_MAX_ZONEORDER
> 	int
> 	default "13" if (ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE)
> 	default "11"
> 
> We can extend it later if people need this but I'm aiming for a single
> config on a multitude of boards.
> 
> -- 
> Catalin

Thanks, that does look a lot neater :-).

-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
