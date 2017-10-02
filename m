Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB476B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:44:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y192so15733136pgd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:44:35 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id b184si7846340pgc.721.2017.10.02.08.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 08:44:34 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake>
 <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
 <alpine.DEB.2.20.1709271655330.3643@nuc-kabylake>
 <b023b5f4-84b5-1686-7b15-c9a3a439b8be@alibaba-inc.com>
 <alpine.DEB.2.20.1710010142420.25658@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <bfbb7523-c30d-7923-d64f-92b3608ddeba@alibaba-inc.com>
Date: Mon, 02 Oct 2017 23:44:08 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1710010142420.25658@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/30/17 11:43 PM, Christopher Lameter wrote:
> On Thu, 28 Sep 2017, Yang Shi wrote:
> 
>>> CONFIG_SLABINFO and /proc/slabinfo have nothing to do with the
>>> unreclaimable slab info.
>>
>> The current design uses "struct slabinfo" and get_slabinfo() to retrieve some
>> info, i.e. active objs, etc. They are protected by CONFIG_SLABINFO.
> 
> Ok I guess then those need to be moved out of CONFIG_SLABINFO. Otherwise
> dumping of slabs will not be supported when disabling that option.

Yes.

> 
> Or dump CONFIG_SLABINFO ..

I prefer to this. It sounds pointless to keep CONFIG_SLABINFO. It is 
always on by default and can't be changed in menuconfig.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
