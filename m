Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 704728E001D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:36:55 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so17696919pgq.12
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:36:55 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id e16si16634308pge.364.2018.12.19.13.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 13:36:54 -0800 (PST)
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
 <114881A8-8960-4436-AAE4-DE40BFFCFB4B@oracle.com>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Message-ID: <d58e8389-3e27-b1cf-7787-52808a0c22a7@synopsys.com>
Date: Wed, 19 Dec 2018 13:36:43 -0800
MIME-Version: 1.0
In-Reply-To: <114881A8-8960-4436-AAE4-DE40BFFCFB4B@oracle.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org

On 12/19/18 12:46 PM, William Kucharski wrote:
> I would rather see 256 as a #define somewhere rather than a magic number sprinkled
> around arch/arc/kernel/troubleshoot.c.

That bothered me as well, but I was too lazy to define one and the existing ones
don't apply. PATH_MAX is 4K which will blow up the stack usage.
> 
> Still, that's what the existing code does, so I suppose it's OK.

I'll define one locally.

> Otherwise the change looks good.

Thx for taking a look.

> Reviewed-by: William Kucharski <william.kucharski@oracle.com>

I'll add this to the patch.

Thx,
-Vineet
