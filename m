Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3055E900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 23:19:31 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so43755446pdj.3
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 20:19:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id vp9si8770838pbc.141.2015.06.04.20.19.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 20:19:30 -0700 (PDT)
Message-ID: <557113CF.6000905@huawei.com>
Date: Fri, 5 Jun 2015 11:13:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 08/12] mm: use mirrorable to switch allocate mirrored
 memory
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com> <55709BEA.8030903@intel.com>
In-Reply-To: <55709BEA.8030903@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/5 2:41, Dave Hansen wrote:

> On 06/04/2015 06:02 AM, Xishi Qiu wrote:
>> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it means
>> we should allocate mirrored memory for both user and kernel processes.
> 
> That's a pretty dangerously short name. :)
> 

Hi Dave,

Thanks for your comment. I'm not sure whether we should add this interface
for user processes. However some important userspace(e.g. /bin/init, key
business like datebase) may be want mirrored memory to improve reliability.

If we want this interface, I think the code need more change.

Thanks,
Xishi Qiu

> How would this end up getting used?  It seems like it would be dangerous
> to use once userspace was very far along.  So would the kernel set it to
> 1 and then let (early??) userspace set it back to 0?  That would let
> important userspace like /bin/init get mirrored memory without having to
> actually change much in userspace.
> 
> This definitely needs some good documentation.
> 
> Also, if it's insane to turn it back *on*, maybe it should be a one-way
> trip to turn off.
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
