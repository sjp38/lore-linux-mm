Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 747B66B0038
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 22:28:15 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so192938481pdb.2
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 19:28:15 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id u9si26142494pdp.186.2015.04.19.19.28.13
        for <linux-mm@kvack.org>;
        Sun, 19 Apr 2015 19:28:13 -0700 (PDT)
Message-ID: <55345FC4.4070404@cn.fujitsu.com>
Date: Mon, 20 Apr 2015 10:09:08 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com> <5531679d.4642ec0a.1beb.3569@mx.google.com> <55345756.40902@huawei.com> <5534603a.36208c0a.4784.6286@mx.google.com>
In-Reply-To: <5534603a.36208c0a.4784.6286@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Ishimatsu, Xishi,

On 04/20/2015 10:11 AM, Yasuaki Ishimatsu wrote:

> 
>> When hot adding memory and creating new node, the node is offline.
>> And after calling node_set_online(), the node becomes online.
>>
>> Oh, sorry. I misread your ptaches.
>>
> 
> Please ignore it...

Seems also a misread to me.
I clear it (my worry) here:
If we set the node size to 0 here, it may hidden more things than we experted.
All the init chunks around with the size (spanned/present/managed...) will
be non-sense, and the user/caller will not get a summary of the hot added node
because of the changes here.
I am not sure the worry is necessary, please correct me if I missing something.

Regards,
Gu

> 
> Thanks,
> Yasuaki Ishimatsu
> 
> On 
> Yasuaki Ishimatsu <yasu.isimatu@gmail.com> wrote:
> 
>>
>> When hot adding memory and creating new node, the node is offline.
>> And after calling node_set_online(), the node becomes online.
>>
>> Oh, sorry. I misread your ptaches.
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>> On Mon, 20 Apr 2015 09:33:10 +0800
>> Xishi Qiu <qiuxishi@huawei.com> wrote:
>>
>>> On 2015/4/18 4:05, Yasuaki Ishimatsu wrote:
>>>
>>>>
>>>> Your patches will fix your issue.
>>>> But, if BIOS reports memory first at node hot add, pgdat can
>>>> not be initialized.
>>>>
>>>> Memory hot add flows are as follows:
>>>>
>>>> add_memory
>>>>   ...
>>>>   -> hotadd_new_pgdat()
>>>>   ...
>>>>   -> node_set_online(nid)
>>>>
>>>> When calling hotadd_new_pgdat() for a hot added node, the node is
>>>> offline because node_set_online() is not called yet. So if applying
>>>> your patches, the pgdat is not initialized in this case.
>>>>
>>>> Thanks,
>>>> Yasuaki Ishimatsu
>>>>
>>>
>>> Hi Yasuaki,
>>>
>>> I'm not quite understand, when BIOS reports memory first, why pgdat
>>> can not be initialized?
>>> When hotadd a new node, hotadd_new_pgdat() will be called too, and
>>> when hotadd memory to a existent node, it's no need to call hotadd_new_pgdat(),
>>> right?
>>>
>>> Thanks,
>>> Xishi Qiu
>>>
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
