Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F76B025B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 20:15:45 -0500 (EST)
Received: by obciw8 with SMTP id iw8so48881578obc.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 17:15:45 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l194si10987395oib.83.2015.12.09.17.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 17:15:44 -0800 (PST)
Message-ID: <5668D1FA.4050108@huawei.com>
Date: Thu, 10 Dec 2015 09:14:34 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679FDC.1080800@huawei.com> <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/10 5:59, Luck, Tony wrote:

>> How about add some comment, if mirrored memroy is too small, then the
>> normal zone is small, so it may be oom.
>> The mirrored memory is at least 1/64 of whole memory, because struct
>> pages usually take 64 bytes per page.
> 
> 1/64th is the absolute lower bound (for the page structures as you say). I
> expect people will need to configure 10% or more to run any real workloads.
> 
> I made the memblock boot time allocator fall back to non-mirrored memory
> if mirrored memory ran out.  What happens in the run time allocator if the
> non-movable zones run out of pages? Will we allocate kernel pages from movable
> memory?
> 

As I know, the kernel pages will not allocated from movable zone.

Thanks,
Xishi Qiu

> -Tony
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
