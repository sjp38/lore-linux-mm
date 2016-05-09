Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 757216B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 13:27:52 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xm6so269417126pab.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 10:27:52 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id a62si38681843pfc.166.2016.05.09.10.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 10:27:51 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id y69so77685266pfb.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 10:27:51 -0700 (PDT)
Subject: Re: [PATCH] mm: slab: remove ZONE_DMA_FLAG
References: <1462381297-11009-1-git-send-email-yang.shi@linaro.org>
 <20160505114946.GI4386@dhcp22.suse.cz>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <c5c0d500-d5f9-195f-4db4-84716f5cf86c@linaro.org>
Date: Mon, 9 May 2016 10:27:49 -0700
MIME-Version: 1.0
In-Reply-To: <20160505114946.GI4386@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/5/2016 4:49 AM, Michal Hocko wrote:
> On Wed 04-05-16 10:01:37, Yang Shi wrote:
>> Now we have IS_ENABLED helper to check if a Kconfig option is enabled or not,
>> so ZONE_DMA_FLAG sounds no longer useful.
>>
>> And, the use of ZONE_DMA_FLAG in slab looks pointless according to the
>> comment [1] from Johannes Weiner, so remove them and ORing passed in flags with
>> the cache gfp flags has been done in kmem_getpages().
>>
>> [1] https://lkml.org/lkml/2014/9/25/553
>
> I haven't checked the patch but I have a formal suggestion.
> lkml.org tends to break and forget, please use
> http://lkml.kernel.org/r/$msg-id instead. In this case
> http://lkml.kernel.org/r/20140925185047.GA21089@cmpxchg.org

Thanks for the suggestion. Will use msg-id in later post.

Regards,
Yang

>
> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
