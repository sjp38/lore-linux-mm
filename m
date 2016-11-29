Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5DE6B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:57:12 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so45546335wmd.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:57:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u82si3415041wme.75.2016.11.29.08.57.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 08:57:11 -0800 (PST)
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
 <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz>
 <20161129163807.GB19454@htj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz>
Date: Tue, 29 Nov 2016 17:57:08 +0100
MIME-Version: 1.0
In-Reply-To: <20161129163807.GB19454@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On 11/29/2016 05:38 PM, Tejun Heo wrote:
> On Tue, Nov 29, 2016 at 08:25:07AM +0100, Michal Hocko wrote:
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -246,7 +246,7 @@ struct vm_area_struct;
>>  #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
>>  #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
>>  #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
>> -#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
>> +#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM|__GFP_NOWARN)
>>  #define GFP_NOIO	(__GFP_RECLAIM)
>>  #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
>>  #define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
>>
>> this will not catch users who are doing gfp & ~__GFP_DIRECT_RECLAIM but
>> I would rather not make warn_alloc() even more cluttered with checks.
>
> Yeah, FWIW, looks good to me.

Me too. Just don't forget to update the comment describing GFP_NOWAIT and check 
the existing users if duplicite __GFP_NOWARN can be removed, and if they really 
want to be doing GFP_NOWAIT and not GFP_ATOMIC.

Also dunno what about Tejun's eariler patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
