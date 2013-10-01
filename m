Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CD71F6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 02:22:12 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so6787845pdj.1
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 23:22:12 -0700 (PDT)
Message-ID: <524A69DA.9050701@cn.fujitsu.com>
Date: Tue, 01 Oct 2013 14:21:14 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm, memory-hotpulg: Rename movablenode boot option
 to movable_node
References: <5249B7C6.7010902@gmail.com> <20131001054646.GA17220@gmail.com>
In-Reply-To: <20131001054646.GA17220@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, imtangchen@gmail.com

Hello Ingo,

On 10/01/2013 01:46 PM, Ingo Molnar wrote:
> 
> * Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:
> 
>> @@ -153,11 +153,18 @@ config MOVABLE_NODE
>>  	help
>>  	  Allow a node to have only movable memory.  Pages used by the kernel,
>>  	  such as direct mapping pages cannot be migrated.  So the corresponding
>> +	  memory device cannot be hotplugged.  This option allows the following
>> +	  two things:
>> +	  - When the system is booting, node full of hotpluggable memory can
>> +	  be arranged to have only movable memory so that the whole node can
>> +	  be hotplugged. (need movable_node boot option specified).
> 
> So this is _exactly_ what I complained about earlier: why is the 
> movable_node boot option needed to get that extra functionality? It's 
> clearly not just a drop-in substitute to CONFIG_MOVABLE_NODE but extends 
> its functionality, right?

Generally speaking, CONFIG_MOVABLE_NODE is used to allow a node to have
only movable memory. Firstly, we didn't support the functionality to support
boot-time configuration. That said, before this patchset, we only support
later hot-add node to have only movable memory but any node that is dectected
at boot-time cannot. So here is movable_node option, to protect the kernel
from using hotpluggable memory at boot-time and if a node is full of hotpluggable
memory, this node is arranged to have only movable memory and can be hot-removed
after the system is up.

> 
> Boot options are _very_ poor user interface. If you don't want to enable 
> it by default then turn this sub-functionality into 
> CONFIG_MOVABLE_NODE_AUTO and keep it default-off - but don't pretend that 
> this is only about CONFIG_MOVABLE_NODE alone - it isnt: as described above 
> the 'movable_node' is needed for the full functionality to be available!

As explained above, we need the boot option to only disable boot-time
memory-hotplug configuration not the whole MOVABLE_NODE functionality.

Thanks

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
