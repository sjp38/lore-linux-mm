Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D6A026B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 20:14:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E95273EE0AE
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:14:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D23D945DE55
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:14:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE23645DE56
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:14:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B37101DB8056
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:14:32 +0900 (JST)
Received: from g01jpexchyt01.g01.fujitsu.local (g01jpexchyt01.g01.fujitsu.local [10.128.194.40])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 658AA1DB8052
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:14:32 +0900 (JST)
Message-ID: <507760BE.4060906@jp.fujitsu.com>
Date: Fri, 12 Oct 2012 09:13:50 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2]suppress "Device nodeX does not have a release() function"
 warning
References: <507656D1.5020703@jp.fujitsu.com> <50765896.4000300@jp.fujitsu.com> <alpine.DEB.2.00.1210111326000.28062@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210111326000.28062@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

2012/10/12 5:31, David Rientjes wrote:
> On Thu, 11 Oct 2012, Yasuaki Ishimatsu wrote:
>
>> When calling unregister_node(), the function shows following message at
>> device_release().
>>
>> "Device 'node2' does not have a release() function, it is broken and must
>> be fixed."
>>
>> The reason is node's device struct does not have a release() function.
>>
>> So the patch registers node_device_release() to the device's release()
>> function for suppressing the warning message. Additionally, the patch adds
>> memset() to initialize a node struct into register_node(). Because the node
>> struct is part of node_devices[] array and it cannot be freed by
>> node_device_release(). So if system reuses the node struct, it has a garbage.
>>
>
> Nice catch on reuse of the statically allocated node_devices[] for node
> hotplug.
>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>
> Can register_node() be made static in drivers/base/node.c and its
> declaration removed from linux/node.h?

Yah. I'll fix it.

Thanks,
Yasuaki Ishimatsu

>
> Acked-by: David Rientjes <rientjes@google.com>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
