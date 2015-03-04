Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 890A16B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 21:53:17 -0500 (EST)
Received: by pdno5 with SMTP id o5so53529285pdn.8
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 18:53:17 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id cx1si3184009pad.152.2015.03.03.18.53.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 18:53:16 -0800 (PST)
Message-ID: <54F67376.8050001@huawei.com>
Date: Wed, 4 Mar 2015 10:52:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com>
In-Reply-To: <54F66C52.4070600@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Li Zefan <lizefan@huawei.com>

On 2015/3/4 10:22, Xishi Qiu wrote:

> On 2015/3/3 18:20, Gu Zheng wrote:
> 
>> Hi Xishi,
>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>
>>> When hot-remove a numa node, we will clear pgdat,
>>> but is memset 0 safe in try_offline_node()?
>>
>> It is not safe here. In fact, this is a temporary solution here.
>> As you know, pgdat is accessed lock-less now, so protection
>> mechanism (RCUi 1/4 ?) is needed to make it completely safe here,
>> but it seems a bit over-kill.
>>

Hi Gu,

Can we just remove "memset(pgdat, 0, sizeof(*pgdat));" ?
I find this will be fine in the stress test except the warning 
when hot-add memory.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
