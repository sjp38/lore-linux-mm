Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3E556B0038
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:49:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so94950pga.6
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:49:04 -0700 (PDT)
Received: from out0-230.mail.aliyun.com (out0-230.mail.aliyun.com. [140.205.0.230])
        by mx.google.com with ESMTPS id c10si11777129pfl.6.2017.09.14.10.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 10:49:03 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
 <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1709141231430.529@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <9037e387-2828-8f77-2dab-01f290187119@alibaba-inc.com>
Date: Fri, 15 Sep 2017 01:48:56 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1709141231430.529@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/14/17 10:32 AM, Christopher Lameter wrote:
> I am not sure that this is generally useful at OOM times unless this is
> not a rare occurrence.

I would say it is not very rare. But, it is definitely troublesome to 
narrow down without certain information about slab usage when it happens.

Thanks,
Yang

> 
> Certainly information like that would create more support for making
> objects movable
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
