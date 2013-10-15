Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8C96B0036
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 21:43:24 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8331982pab.32
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 18:43:23 -0700 (PDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1DECF3EE0C1
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:43:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DA9245DEBB
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:43:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6B9845DEB2
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:43:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8E171DB8041
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:43:19 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88EF81DB803E
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:43:19 +0900 (JST)
Message-ID: <525C9D86.1020502@jp.fujitsu.com>
Date: Tue, 15 Oct 2013 10:42:30 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Release device_hotplug_lock when store_mem_state returns
 EINVAL
References: <52579C69.1080304@jp.fujitsu.com> <20131011155454.GA32305@kroah.com>
In-Reply-To: <20131011155454.GA32305@kroah.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, toshi.kani@hp.com, sjenning@linux.vnet.ibm.com

Hi Greg,

(2013/10/12 0:54), Greg KH wrote:
> On Fri, Oct 11, 2013 at 03:36:25PM +0900, Yasuaki Ishimatsu wrote:
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
> Is this needed in 3.12-final, and possibly older kernel releases as well
> (3.10, 3.11, etc.)?  Or is it ok for 3.13?

The patch is needed in 3.12 because this problem has occurred since 3.12-rc1.

Thanks,
Yasuaki Ishimatsu

>
> thanks,
>
> greg k-h
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
