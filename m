Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF146810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 22:54:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z193so5685511pgd.10
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 19:54:09 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b89si2371853plb.24.2017.08.25.19.54.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 19:54:08 -0700 (PDT)
Message-ID: <59A0E237.1070501@huawei.com>
Date: Sat, 26 Aug 2017 10:51:35 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent
 is negative
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <alpine.DEB.2.20.1706282353190.1890@nanos> <599FB3C4.6000009@huawei.com> <alpine.DEB.2.20.1708252308500.2124@nanos>
In-Reply-To: <alpine.DEB.2.20.1708252308500.2124@nanos>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhen Lei <thunder.leizhen@huawei.com>

On 2017/8/26 5:13, Thomas Gleixner wrote:
> On Fri, 25 Aug 2017, zhong jiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>> Date: Fri, 25 Aug 2017 12:05:56 +0800
>> Subject: [PATCH v2] futex: avoid undefined behaviour when shift exponent is
>>  negative
> Please do not send patches without changing the subject line so it's clear
> that there is a new patch.
  ok
>> using a shift value < 0 or > 31 will get crap as a result. because
>> it's just undefined. The issue still disturb me, so I try to fix
>> it again by excluding the especially condition.
> Which is obsolete now as this code is unified accross all architectures and
> the shift issue is addressed in the generic version of it. So all
> architectures get the same fix. See:
>
>  http://git.kernel.org/tip/30d6e0a4190d37740e9447e4e4815f06992dd8c3
  ok , I  miss the above patch.
> And no, we won't add that x86 fix before that unification hits mainline
> because that undefined behaviour is harmless as it only affects the user
> space value of the futex. IOW, the caller gets what it asked for: crap.
  Thank you for clarification.

  Regards
 zhongjiang
> Thanks,
>
> 	tglx
>
>
> .
>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
