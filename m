Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D90426B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 20:05:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F22A43EE0C0
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:05:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D6ED245DE5C
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:05:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A91AF45DE5A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:05:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AB281DB8055
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:05:22 +0900 (JST)
Received: from g01jpexchkw36.g01.fujitsu.local (g01jpexchkw36.g01.fujitsu.local [10.0.193.54])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 538FA1DB804C
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:05:22 +0900 (JST)
Message-ID: <5175D01E.5000302@jp.fujitsu.com>
Date: Tue, 23 Apr 2013 09:04:46 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v2] numa, cpu hotplug: Change links of CPU and
 node when changing node number by onlining CPU
References: <5170D4CB.20900@jp.fujitsu.com> <20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org>
In-Reply-To: <20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, mingo@kernel.org, hpa@zytor.com, srivatsa.bhat@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

2013/04/23 7:35, Andrew Morton wrote:
> On Fri, 19 Apr 2013 14:23:23 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> When booting x86 system contains memoryless node, node numbers of CPUs
>> on memoryless node were changed to nearest online node number by
>> init_cpu_to_node() because the node is not online.
>>
>> ...
>>
>> If we hot add memory to memoryless node and offine/online all CPUs on
>> the node, node numbers of these CPUs are changed to correct node numbers
>> by srat_detect_node() because the node become online.
>
> OK, here's a dumb question.
>
> At boot time the CPUs are assigned to the "nearest online node" rather
> than to their real memoryless node.  The patch arranges for those CPUs
> to still be assigned to the "nearest online node" _after_ some memory
> is hot-added to their real node.  Correct?

Yes. For changing node number of CPUs safely, we should offline CPUs.

>
> Would it not be better to fix this by assigning those CPUs to their real,
> memoryless node right at the initial boot?  Or is there something in
> the kernel which makes cpus-on-a-memoryless-node not work correctly?
>

I think assigning CPUs to real node is better. But current Linux's node
strongly depend on memory. Thus if we just create cpus-on-a-memoryless-node,
the kernel cannot work correctly.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
