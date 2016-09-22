Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 747B9280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:40:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so76573895wmc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:40:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m125si40148503wme.54.2016.09.22.09.40.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 09:40:33 -0700 (PDT)
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
References: <20160922152831.24165-1-vbabka@suse.cz>
 <1474561478.23058.127.camel@edumazet-glaptop3.roam.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3097822d-231b-8406-17bc-631aea4f82e7@suse.cz>
Date: Thu, 22 Sep 2016 18:40:30 +0200
MIME-Version: 1.0
In-Reply-To: <1474561478.23058.127.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On 09/22/2016 06:24 PM, Eric Dumazet wrote:

>> +		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
>> +		if (!bits && alloc_size > PAGE_SIZE) {
>> +			bits = vmalloc(alloc_size);
>> +
>> +			if (!bits)
>> +				goto out_nofds;
>
> Test should happen if alloc_size <= PAGE_SIZE
>
>> +		}
>
> if (!bits && alloc_size > PAGE_SIZE)
>     bits = vmalloc(alloc_size);
>
> if (!bits)
>       goto out_nofds;
>

Thanks... stupid last-minute changes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
