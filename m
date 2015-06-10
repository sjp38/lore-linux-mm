Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD7796B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 23:10:27 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so27540256pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 20:10:27 -0700 (PDT)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id w16si808435pbt.253.2015.06.09.20.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 20:10:27 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 407F0AC04A9
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 12:10:23 +0900 (JST)
Message-ID: <5577AA87.3080607@jp.fujitsu.com>
Date: Wed, 10 Jun 2015 12:09:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 08/12] mm: use mirrorable to switch allocate mirrored
 memory
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com> <55769058.3030406@jp.fujitsu.com> <5576BB3C.50100@huawei.com>
In-Reply-To: <5576BB3C.50100@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/09 19:09, Xishi Qiu wrote:
> On 2015/6/9 15:06, Kamezawa Hiroyuki wrote:
>
>> On 2015/06/04 22:02, Xishi Qiu wrote:
>>> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it means
>>> we should allocate mirrored memory for both user and kernel processes.
>>>
>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>
>> I can't see why do we need this switch. If this is set, all GFP_HIGHUSER will use
>> mirrored memory ?
>>
>> Or will you add special MMAP/madvise flag to use mirrored memory ?
>>
>
> Hi Kame,
>
> Yes,
>
> MMAP/madvise
> 	-> add VM_MIRROR
> 		-> add GFP_MIRROR
> 			-> use MIGRATE_MIRROR list to alloc mirrored pages
>
> So user can use mirrored memory. What do you think?
>

I see. please explain it (your final plan) in patch description or in cover page of patches.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
