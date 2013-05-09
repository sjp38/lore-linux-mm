Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 94E806B0062
	for <linux-mm@kvack.org>; Thu,  9 May 2013 04:22:40 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q55so2620761wes.12
        for <linux-mm@kvack.org>; Thu, 09 May 2013 01:22:38 -0700 (PDT)
Date: Thu, 9 May 2013 09:22:36 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH v2 08/11] ARM64: mm: Swap PTE_FILE and
 PTE_PROT_NONE bits.
Message-ID: <20130509082235.GB28545@linaro.org>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
 <1368006763-30774-9-git-send-email-steve.capper@linaro.org>
 <20130508164018.GF20820@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130508164018.GF20820@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <Catalin.Marinas@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Wed, May 08, 2013 at 05:40:19PM +0100, Will Deacon wrote:
> On Wed, May 08, 2013 at 10:52:40AM +0100, Steve Capper wrote:

 [...] 

> Can you update the comment describing swp entries too please? I *think* the
> __SWP_* defines can remain untouched, but the comment is now wrong.
> 
> Will

Ta Will, I've now changed the other comment.
The __SWP_* entries look ok to me. I'm going to run some swap tests though
to see if anything crops up.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
