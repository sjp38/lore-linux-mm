Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DADD6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 11:06:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p2so11455915pfk.13
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 08:06:24 -0800 (PST)
Received: from out0-248.mail.aliyun.com (out0-248.mail.aliyun.com. [140.205.0.248])
        by mx.google.com with ESMTPS id s9si10534918plp.177.2017.11.06.08.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 08:06:23 -0800 (PST)
Subject: Re: [PATCH] mm: filemap: remove include of hardirq.h
References: <1509734868-120762-1-git-send-email-yang.s@alibaba-inc.com>
 <20171104134709.GA23784@bombadil.infradead.org>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <e2253597-cb34-409e-9be0-768136ca0942@alibaba-inc.com>
Date: Tue, 07 Nov 2017 00:06:11 +0800
MIME-Version: 1.0
In-Reply-To: <20171104134709.GA23784@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/4/17 6:47 AM, Matthew Wilcox wrote:
> On Sat, Nov 04, 2017 at 02:47:48AM +0800, Yang Shi wrote:
>> in_atomic() has been moved to include/linux/preempt.h, and the filemap.c
>> doesn't use in_atomic() directly at all, so it sounds unnecessary to
>> include hardirq.h.
>> With removing hardirq.h, around 32 bytes can be saved for x86_64 bzImage
>> with allnoconfig.
> 
> Wait, what?  How would including an unused header file increase the size
> of the final image?

Sorry for the wrong message, I double checked again with building kernel 
a couple of times then comparing the size, there is no change. Will 
remove this from the commit log.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
