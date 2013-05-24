Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C44DC6B008C
	for <linux-mm@kvack.org>; Fri, 24 May 2013 07:24:03 -0400 (EDT)
Date: Fri, 24 May 2013 12:23:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 09/11] ARM64: mm: HugeTLB support.
Message-ID: <20130524112346.GK18272@arm.com>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <1369328878-11706-10-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369328878-11706-10-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Thu, May 23, 2013 at 06:07:56PM +0100, Steve Capper wrote:
> Add huge page support to ARM64, different huge page sizes are
> supported depending on the size of normal pages:
> 
> PAGE_SIZE is 4KB:
>    2MB - (pmds) these can be allocated at any time.
> 1024MB - (puds) usually allocated on bootup with the command line
>          with something like: hugepagesz=1G hugepages=6
> 
> PAGE_SIZE is 64KB:
>  512MB - (pmds) usually allocated on bootup via command line.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
