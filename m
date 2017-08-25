Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3ED6810D0
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:14:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y14so1323137wrd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:14:04 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k62si1850506wma.248.2017.08.25.14.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 14:13:59 -0700 (PDT)
Date: Fri, 25 Aug 2017 23:13:47 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent is
 negative
In-Reply-To: <599FB3C4.6000009@huawei.com>
Message-ID: <alpine.DEB.2.20.1708252308500.2124@nanos>
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <alpine.DEB.2.20.1706282353190.1890@nanos> <599FB3C4.6000009@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhen Lei <thunder.leizhen@huawei.com>

On Fri, 25 Aug 2017, zhong jiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> Date: Fri, 25 Aug 2017 12:05:56 +0800
> Subject: [PATCH v2] futex: avoid undefined behaviour when shift exponent is
>  negative

Please do not send patches without changing the subject line so it's clear
that there is a new patch.

> using a shift value < 0 or > 31 will get crap as a result. because
> it's just undefined. The issue still disturb me, so I try to fix
> it again by excluding the especially condition.

Which is obsolete now as this code is unified accross all architectures and
the shift issue is addressed in the generic version of it. So all
architectures get the same fix. See:

 http://git.kernel.org/tip/30d6e0a4190d37740e9447e4e4815f06992dd8c3

And no, we won't add that x86 fix before that unification hits mainline
because that undefined behaviour is harmless as it only affects the user
space value of the futex. IOW, the caller gets what it asked for: crap.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
