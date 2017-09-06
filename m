Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE762802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 13:07:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u206so10318629oif.6
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 10:07:37 -0700 (PDT)
Received: from sender-pp-091.zoho.com (sender-pp-091.zoho.com. [135.84.80.236])
        by mx.google.com with ESMTPS id u11si166318oif.492.2017.09.06.10.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 10:07:35 -0700 (PDT)
Subject: Re: [PATCH 1/1] workqueue: use type int instead of bool to index
 array
References: <59AF6CB6.4090609@zoho.com>
 <20170906143320.GK1774378@devbig577.frc2.facebook.com>
 <c795e42f-8355-b79b-3239-15c4ea8fede7@zoho.com>
 <20170906164015.GQ1774378@devbig577.frc2.facebook.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <58cb4eab-8334-a884-efa3-8752c34112e5@zoho.com>
Date: Thu, 7 Sep 2017 01:07:23 +0800
MIME-Version: 1.0
In-Reply-To: <20170906164015.GQ1774378@devbig577.frc2.facebook.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, jiangshanlai@gmail.com

On 2017/9/7 0:40, Tejun Heo wrote:
> On Thu, Sep 07, 2017 at 12:04:59AM +0800, zijun_hu wrote:
>> On 2017/9/6 22:33, Tejun Heo wrote:
>>> Hello,
>>>
>>> On Wed, Sep 06, 2017 at 11:34:14AM +0800, zijun_hu wrote:
>>>> From: zijun_hu <zijun_hu@htc.com>
>>>>
>>>> type bool is used to index three arrays in alloc_and_link_pwqs()
>>>> it doesn't look like conventional.
>>>>
>>>> it is fixed by using type int to index the relevant arrays.
>>>
>>> bool is a uint type which can be either 0 or 1.  I don't see what the
>>> benefit of this patch is.q
>>>
>> bool is NOT a uint type now, it is a new type introduced by gcc, it is
>> rather different with "typedef int bool" historically
> 
> http://www.open-std.org/jtc1/sc22/wg14/www/docs/n815.htm
> 
>   Because C has existed for so long without a Boolean type, however, the
>   new standard must coexist with the old remedies. Therefore, the type
>   name is taken from the reserved identifier space. To maintain
>   orthogonal promotion rules, the Boolean type is defined as an unsigned
>   integer type capable of representing the values 0 and 1. The more
>   conventional names for the type and its values are then made available
>   only with the inclusion of the <stdbool.h> header. In addition, the
>   header defines a feature test macro to aid in integrating new code
>   with old code that defines its own Boolean type.
> 
in this case, i think type int is more suitable than bool in aspects of
extendibility, program custom and consistency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
