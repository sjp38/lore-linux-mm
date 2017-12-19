Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7ED96B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:41:14 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id f5so4450755lff.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:41:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u66sor2813914lja.26.2017.12.19.07.41.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:41:13 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
From: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Message-ID: <2c08488e-7a6f-5623-bf9a-354ce843b0dc@gmail.com>
Date: Tue, 19 Dec 2017 18:41:10 +0300
MIME-Version: 1.0
In-Reply-To: <20171219152536.GA591@tigerII.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 12/19/2017 06:25 PM, Sergey Senozhatsky wrote:

> Hi Michal,
>
> On (12/19/17 16:13), Michal Hocko wrote:
>> On Tue 19-12-17 13:49:12, Aliaksei Karaliou wrote:
>> [...]
>>> @@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
>>>  	 * Not critical, we still can use the pool
>>>  	 * and user can trigger compaction manually.
>>>  	 */
>>> -	if (zs_register_shrinker(pool) == 0)
>>> -		pool->shrinker_enabled = true;
>>> +	(void) zs_register_shrinker(pool);
>>> +
>>>  	return pool;
>> So what will happen if the pool is alive and used without any shrinker?
>> How do objects get freed?
> we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
> don't free any objects from that path. just move them around within their
> size classes - to consolidate objects and to, may be, free unused pages
> [but we first need to make them "unused"]. it's not a mandatory thing for
> zsmalloc, we are just trying to be nice.
>
> 	-ss

Thanks a lot for clarification from your side, Sergey.

Best regards,
    Aliaksei.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
