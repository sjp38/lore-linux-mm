Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DAA926B0257
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:39:25 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so52711676pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:39:25 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ha1si6029198pbb.149.2015.11.18.10.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:39:25 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so54501647pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:39:25 -0800 (PST)
Message-ID: <564CC5DB.8000104@linaro.org>
Date: Wed, 18 Nov 2015 10:39:23 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org> <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org> <20151118181142.GC11496@mtj.duckdns.org> <564CC314.1090904@linaro.org> <20151118183344.GD11496@mtj.duckdns.org>
In-Reply-To: <20151118183344.GD11496@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 11/18/2015 10:33 AM, Tejun Heo wrote:
> Hello,
>
> On Wed, Nov 18, 2015 at 10:27:32AM -0800, Shi, Yang wrote:
>>> This was the main reason the code was structured the way it is.  If
>>> cgroup writeback is not enabled, any derefs of mdtc variables should
>>> trigger warnings.  Ugh... I don't know.  Compiler really should be
>>> able to tell this much.
>>
>> Thanks for the explanation. It sounds like a compiler problem.
>>
>> If you think it is still good to cease the compile warning, maybe we could
>
> If this is gonna be a problem with new gcc versions, I don't think we
> have any other options. :(
>
>> just assign it to an insane value as what Andrew suggested, maybe
>> 0xdeadbeef.
>
> I'd just keep it at zero.  Whatever we do, the effect is gonna be
> difficult to track down - it's not gonna blow up in an obvious way.
> Can you please add a comment tho explaining that this is to work
> around compiler deficiency?

Sure.

Other than this, in v2, I will just initialize m_dirty since compiler 
just reports it is uninitialized.

Thanks,
Yang

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
