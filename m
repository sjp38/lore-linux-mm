Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1CA6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 18:12:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x78so25337534pff.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 15:12:10 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id y11si10501plg.98.2017.09.27.15.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 15:12:09 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake>
 <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
 <alpine.DEB.2.20.1709271655330.3643@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <b023b5f4-84b5-1686-7b15-c9a3a439b8be@alibaba-inc.com>
Date: Thu, 28 Sep 2017 06:11:46 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1709271655330.3643@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/17 2:59 PM, Christopher Lameter wrote:
> On Thu, 28 Sep 2017, Yang Shi wrote:
>>> CONFIG_SLABINFO? How does this relate to the oom info? /proc/slabinfo
>>> support is optional. Oom info could be included even if CONFIG_SLABINFO
>>> goes away. Remove the #ifdef?
>>
>> Because we want to dump the unreclaimable slab info in oom info.
> 
> CONFIG_SLABINFO and /proc/slabinfo have nothing to do with the
> unreclaimable slab info.

The current design uses "struct slabinfo" and get_slabinfo() to retrieve 
some info, i.e. active objs, etc. They are protected by CONFIG_SLABINFO.

We could replicate the logic in get_slabinfo without using struct 
slabinfo, but it sounds not that necessary and CONFIG_SLABINFO is 
typically enabled by default and it is not shown in menuconfig.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
