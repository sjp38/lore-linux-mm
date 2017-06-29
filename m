Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 167706B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:07:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u18so75858568pfa.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:07:30 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id o4si3452041plb.43.2017.06.29.00.07.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 00:07:29 -0700 (PDT)
Message-ID: <5954A66D.0@huawei.com>
Date: Thu, 29 Jun 2017 15:04:13 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent
 is negative
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <alpine.DEB.2.20.1706282353190.1890@nanos> <59545DD6.3030508@huawei.com> <alpine.DEB.2.20.1706290832140.1861@nanos>
In-Reply-To: <alpine.DEB.2.20.1706290832140.1861@nanos>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/6/29 14:33, Thomas Gleixner wrote:
> On Thu, 29 Jun 2017, zhong jiang wrote:
>> On 2017/6/29 6:13, Thomas Gleixner wrote:
>>> That's simply wrong. If oparg is negative and the SHIFT bit is set then the
>>> result is undefined today and there is no way that this can be used at
>>> all.
>>>
>>> On x86:
>>>
>>>    1 << -1	= 0x80000000
>>>    1 << -2048	= 0x00000001
>>>    1 << -2047	= 0x00000002
>>   but I test the cases in x86_64 all is zero.   I wonder whether it is related to gcc or not
>>
>>   zj.c:15:8: warning: left shift count is negative [-Wshift-count-negative]
>>   j = 1 << -2048;
>>         ^
>> [root@localhost zhongjiang]# ./zj
>> j = 0
> Which is not a surprise because the compiler can detect it as the shift is
> a constant. oparg is not so constant ...
  I get it. Thanks
 
  Thanks
  zhongjiang
> Thanks,
>
> 	tglx
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
