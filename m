Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 7B3046B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 08:55:54 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x54so466038wes.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:55:53 -0700 (PDT)
Date: Fri, 14 Jun 2013 13:55:47 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 00/11] HugeTLB and THP support for ARM64.
Message-ID: <20130614125547.GA7008@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <20130611090714.GA21776@linaro.org>
 <20130613142033.fdcefe11264c1bb2df8fc4cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130613142033.fdcefe11264c1bb2df8fc4cb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, catalin.marinas@arm.com, linux-mm@kvack.org

On Thu, Jun 13, 2013 at 02:20:33PM -0700, Andrew Morton wrote:
> On Tue, 11 Jun 2013 10:07:15 +0100 Steve Capper <steve.capper@linaro.org> wrote:
> 
> > Hello,
> > I was just wondering if there were any comments on the mm and x86 patches in
> > this series, or should I send a pull request for them?
> > 
> > Catalin has acked the ARM64 ones but we need the x86->mm code move in place
> > before the ARM64 code is merged. The idea behind the code move was to avoid
> > code duplication between x86 and ARM64 (and ARM).
> 
> Ack from me on patches 1, 2, 3, 4 and 5.  Please get the whole series
> into linux-next asap and merge it up at the appropriate time.

Thanks,
I've sent a request to the linux-next to pull the series.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
