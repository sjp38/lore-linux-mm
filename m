Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C327A6B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 17:20:35 -0400 (EDT)
Date: Thu, 13 Jun 2013 14:20:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/11] HugeTLB and THP support for ARM64.
Message-Id: <20130613142033.fdcefe11264c1bb2df8fc4cb@linux-foundation.org>
In-Reply-To: <20130611090714.GA21776@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
	<20130611090714.GA21776@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: x86@kernel.org, catalin.marinas@arm.com, linux-mm@kvack.org

On Tue, 11 Jun 2013 10:07:15 +0100 Steve Capper <steve.capper@linaro.org> wrote:

> Hello,
> I was just wondering if there were any comments on the mm and x86 patches in
> this series, or should I send a pull request for them?
> 
> Catalin has acked the ARM64 ones but we need the x86->mm code move in place
> before the ARM64 code is merged. The idea behind the code move was to avoid
> code duplication between x86 and ARM64 (and ARM).

Ack from me on patches 1, 2, 3, 4 and 5.  Please get the whole series
into linux-next asap and merge it up at the appropriate time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
