Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A78D6B04A1
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 05:10:03 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s132so8616949ita.6
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 02:10:03 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id c79si5790139itc.195.2017.09.04.02.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Sep 2017 02:10:02 -0700 (PDT)
Message-ID: <59AD174B.4020807@huawei.com>
Date: Mon, 4 Sep 2017 17:05:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove timeout from __offline_memory
References: <20170904082148.23131-1-mhocko@kernel.org> <20170904082148.23131-3-mhocko@kernel.org> <59AD15B6.7080304@huawei.com> <20170904090114.mrjxipvucieadxa6@dhcp22.suse.cz>
In-Reply-To: <20170904090114.mrjxipvucieadxa6@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2017/9/4 17:01, Michal Hocko wrote:

> On Mon 04-09-17 16:58:30, Xishi Qiu wrote:
>> On 2017/9/4 16:21, Michal Hocko wrote:
>>
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> We have a hardcoded 120s timeout after which the memory offline fails
>>> basically since the hot remove has been introduced. This is essentially
>>> a policy implemented in the kernel. Moreover there is no way to adjust
>>> the timeout and so we are sometimes facing memory offline failures if
>>> the system is under a heavy memory pressure or very intensive CPU
>>> workload on large machines.
>>>
>>> It is not very clear what purpose the timeout actually serves. The
>>> offline operation is interruptible by a signal so if userspace wants
>>
>> Hi Michal,
>>
>> If the user know what he should do if migration for a long time,
>> it is OK, but I don't think all the users know this operation
>> (e.g. ctrl + c) and the affect.
> 
> How is this operation any different from other potentially long
> interruptible syscalls?
> 

Hi Michal,

I means the user should stop it by himself if migration always retry in endless.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
