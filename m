Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3313C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:23:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59AA1217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:23:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AA1217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBB468E0006; Mon, 18 Feb 2019 10:23:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93DB8E0002; Mon, 18 Feb 2019 10:23:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C82A78E0006; Mon, 18 Feb 2019 10:23:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0118E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:23:43 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d62so7364579edd.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:23:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DtxKPR+qfLx8EugR1EloWNESgnyesXNJF2pDUbBr7JU=;
        b=sRCW0AjwOW6YPFeKjP6TcUGgpnAgRMS9mB9Wyf4dXMrAhUxAl9zfPmN9pjc1IPlshS
         3D73Sb54QkcNXRKGoLjgMVEb2yca+ZLU3zB0YTL8gTLTw1k12iTyA0FA1o9c/o+8ZDgx
         tEI0UP+FyDs0Zs3wdGF6muaVMcwPVQvmL6K+r/kppOgInVg3Gkc2SP9WJt7QVfPRJ7K0
         PuCARC4IzPgPwrNrUWZqjAvAGEoKE5W6CqTOrw4i2Kk0tDlcJAsXwf2ZJ4M24fP//rox
         bHtuR23iJeoMLemQkJmBYvuUtvHxAcwPKGQehJVX7+nevxzuJsKx8BXQluw0dNqTJUr1
         nnAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuY4YbFpnM+uihP+Xu7tnfyUbQNwpM/tKzWQFiCf/MMIarmyCD3G
	XgBi855Ws9pjqs7PYrMo4uJXg1ozw0OcYyDfUUqY7PZ/XVxqXbmA1DmL670brawdLdeI9gNX4Up
	lK+FbBcEPECPAU/oj7S15f3DFODIJ0TDccjmEzr+U4DYkHJj8HfT85wg2Fj61c3fjgw==
X-Received: by 2002:a50:ae8d:: with SMTP id e13mr19438786edd.124.1550503422991;
        Mon, 18 Feb 2019 07:23:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9kYdIsRkyPyYXJ6QPunqWn5W+Xr4brmQn6E293rvZOeBj+wsCcC6i620cGkUG4Rhdlx05
X-Received: by 2002:a50:ae8d:: with SMTP id e13mr19438742edd.124.1550503422138;
        Mon, 18 Feb 2019 07:23:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550503422; cv=none;
        d=google.com; s=arc-20160816;
        b=m/u0ms+ySGrd49RZYQz8FC52T913SAU2x2OddbNs/bFncndS9qk7hHWRoW8geZ299X
         hACYFmKxsErvEUqjn0R52oKEOt8XPmk4U/foWc3K0F9Esj3W0paCIk9xi7Jo9DGjYUnk
         JWo6XUMhXZFddqm6eHuRywdV/mm3ShKNOeZoXCE4nMKORjfOIRNNC7mRa8nfgJ3z9RPT
         81S/dUlGkbSpqCgyNjByQ47JFSzC2oNrWPEfSvzO3gTPRuiGtCI+35Zmx1KU1sJXe4T8
         zp6djRaN/co5vVGed4+jZTOO3by8AnpKXJGaCb9yn686zWQmHO3QhaK3Pl1GYoGNhrvF
         epSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DtxKPR+qfLx8EugR1EloWNESgnyesXNJF2pDUbBr7JU=;
        b=X9utAJ2zZpEKE6A7hPVm6D8TpN/mh6D8IzInTO0aP5SuGLAiWcNZ5g4goFuRBF5ABW
         4BHBVf88yJDMAT8CuG5x1gCPubRq7EeLJXLULwmhfj3wVMPvL4PUjgtNOzQoo4F6BF94
         OIixNdK2PCxTNBIdahnHCMq7FBN2EQlbY500+91Ak/FzlORr4RsLxcyY4P/A8/Ihuw0n
         wg+xos/l4uhFkOrIJxJ/UFdr7mmNatUpq5ksCdj+nw7eXdJQ2F9dlGYjRXf672P7z647
         jKEm5a4WI35PV2YcjxzvPLyNX/UW0tz50Gs2/1o48OxozJ5Pm2TXLMy+STNIcEBxQ4da
         FKBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x6si3288726eju.32.2019.02.18.07.23.41
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 07:23:42 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 14442A78;
	Mon, 18 Feb 2019 07:23:37 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F2E1C3F675;
	Mon, 18 Feb 2019 07:23:23 -0800 (PST)
Subject: Re: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
To: Mark Rutland <Mark.Rutland@arm.com>
Cc: "x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <Will.Deacon@arm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, James Morse <James.Morse@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-7-steven.price@arm.com>
 <20190218112350.GE8036@lakrids.cambridge.arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <7b0c6eed-102e-ff79-0f65-16bcec043a09@arm.com>
Date: Mon, 18 Feb 2019 15:23:22 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218112350.GE8036@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 11:23, Mark Rutland wrote:
> On Fri, Feb 15, 2019 at 05:02:27PM +0000, Steven Price wrote:
>> +/* If the p4ds are actually just pgds then we should report a depth
>> + * of 0 not 1 (as a missing entry is really a missing pgd
>> + */
> 
> Nit: comment style violation. This should look like:
> should be:
> 
> /*
>  * If the p4ds are actually just pgds then we should report a depth
>  * of 0 not 1 (as a missing entry is really a missing pgd
>  */
> 
>> +int depth = (PTRS_PER_P4D == 1)?0:1;
> 
> Nit: the ternary should have spacing.
> 
> We don't seem to do this at any other level that could be folded, so why
> does p4d need special care?
> 
> For example, what happens on arm64 when using 64K pages and 3 level
> paging, where puds are folded into pgds?
> 
> Thanks,
> Mark.

Yes, you are entirely correct I've missed the other potential foldings.
I somehow imagined that p4d was special and was folded the opposite
direction (I'm not sure why!).

The best solution I can come up with is a function which will convert
from the level the entry is found at, back to the 'real' level the entry
was missing at. This is needed to produce the correct output in the
debugfs file. Something like:

static int real_depth(int depth)
{
	if (depth == 3 && PTRS_PER_PMD == 1)
		depth = 2;
	if (depth == 2 && PTRS_PER_PUD == 1)
		depth = 1;
	if (depth == 1 && PTRS_PER_P4D == 1)
		depth = 0;
	return depth;
}

This should of course get folded by the compiler and not actually
generate any code.

Thanks,

Steve

