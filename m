Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAA56B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:35:23 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id g6so15748460igt.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:35:23 -0800 (PST)
Received: from out1134-186.mail.aliyun.com (out1134-186.mail.aliyun.com. [42.120.134.186])
        by mx.google.com with ESMTP id e5si4957367igg.38.2016.02.25.06.35.21
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 06:35:22 -0800 (PST)
Message-ID: <56CF1202.2020809@emindsoft.com.cn>
Date: Thu, 25 Feb 2016 22:38:58 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net>
In-Reply-To: <20160225092752.GU2854@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 2/25/16 17:27, Mel Gorman wrote:
> On Thu, Feb 25, 2016 at 06:26:31AM +0800, chengang@emindsoft.com.cn wrote:
>> From: Chen Gang <chengang@emindsoft.com.cn>
>>
>> Always notice about 80 columns, and the white space near '|'.
>>
>> Let the wrapped function parameters align as the same styles.
>>
>> Remove redundant statement "enum zone_type z;" in function gfp_zone.
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> NAK from me at least. From my perspective, it's preferrable to preserve
> blame than go through a layer of cleanup when looking for the commit
> that defined particular flags. It's ok to cleanup code at the same time
> definitions change for functional or performance reasons.
> 

I can understand for your NAK, it is a trivial patch. For me, I guess
trivial@kernel.org will care about this kind of patch.

If we have another better way than sending trivial patch, that will be
OK to me. At present, I am learning mm in my free time, when I feel
something is valuable more or less, I will send related patch for it.

And excuse me, I guess my english is not quite well, I am not quite
understand the meaning below, could you provide more details?

  "it's preferable to preserve blame than go through a layer of cleanup
  when looking for the commit that defined particular flags".

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
