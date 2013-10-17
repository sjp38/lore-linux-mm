Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id E07B06B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 22:25:52 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1668051pbb.10
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:25:52 -0700 (PDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 03B763EE0CF
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:25:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3E6145DE53
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:25:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB52545DE57
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:25:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B87161DB8045
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:25:48 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 622FF1DB8044
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:25:48 +0900 (JST)
Message-ID: <525F4A77.1050400@jp.fujitsu.com>
Date: Thu, 17 Oct 2013 11:24:55 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Release device_hotplug_lock when store_mem_state returns
 EINVAL
References: <52579C69.1080304@jp.fujitsu.com> <1381509080.26234.32.camel@misato.fc.hp.com>
In-Reply-To: <1381509080.26234.32.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org

(2013/10/12 1:31), Toshi Kani wrote:
> On Fri, 2013-10-11 at 15:36 +0900, Yasuaki Ishimatsu wrote:
>> When inserting a wrong value to /sys/devices/system/memory/memoryX/state file,
>> following messages are shown. And device_hotplug_lock is never released.
>>
>> ================================================
>> [ BUG: lock held when returning to user space! ]
>> 3.12.0-rc4-debug+ #3 Tainted: G        W
>> ------------------------------------------------
>> bash/6442 is leaving the kernel with locks still held!
>> 1 lock held by bash/6442:
>>   #0:  (device_hotplug_lock){+.+.+.}, at: [<ffffffff8146cbb5>] lock_device_hotplug_sysfs+0x15/0x50
>>
>> This issue was introdued by commit fa2be40 (drivers: base: use standard
>> device online/offline for state change).
>>
>> This patch releases device_hotplug_lcok when store_mem_state returns EINVAL.
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> CC: Toshi Kani <toshi.kani@hp.com>
>> CC: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>
> Good catch!
>
> Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thank you for your review.

Thanks,
Yasuaki Ishimatsu



>
> Thanks,
> -Toshi
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
