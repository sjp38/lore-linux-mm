Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 377A028024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 17:17:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so222338134pab.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 14:17:06 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id h131si9530106pfc.282.2016.09.23.14.17.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 14:17:04 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/percpu.c: correct max_distance calculation for
 pcpu_embed_first_chunk()
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
 <20160923192351.GE31387@htj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <39277252-5bf4-b355-c076-8059e693f4aa@zoho.com>
Date: Sat, 24 Sep 2016 05:16:56 +0800
MIME-Version: 1.0
In-Reply-To: <20160923192351.GE31387@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

On 2016/9/24 3:23, Tejun Heo wrote:
> On Sat, Sep 24, 2016 at 02:20:24AM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> correct max_distance from (base of the highest group + ai->unit_size)
>> to (base of the highest group + the group size)
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> 
> Nacked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks.
>
frankly, the current max_distance is error, doesn't represents the ranges spanned by
areas owned by the groups


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
