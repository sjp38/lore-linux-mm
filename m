Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A93266B0062
	for <linux-mm@kvack.org>; Sun,  2 Sep 2012 21:25:20 -0400 (EDT)
Message-ID: <5044084B.3050705@cn.fujitsu.com>
Date: Mon, 03 Sep 2012 09:30:51 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 04/20] memory-hotplug: offline and remove memory
 when removing the memory device
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<1346148027-24468-5-git-send-email-wency@cn.fujitsu.com> <20120831135514.2a2dc0d4.akpm@linux-foundation.org>
In-Reply-To: <20120831135514.2a2dc0d4.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 09/01/2012 04:55 AM, Andrew Morton Wrote:
> On Tue, 28 Aug 2012 18:00:11 +0800
> wency@cn.fujitsu.com wrote:
> 
>> +int remove_memory(int nid, u64 start, u64 size)
>> +{
>> +	int ret = -EBUSY;
>> +	lock_memory_hotplug();
>> +	/*
>> +	 * The memory might become online by other task, even if you offine it.
>> +	 * So we check whether the cpu has been onlined or not.
> 
> I think you meant "memory", not "cpu".

Yes. I will fix it.

Thanks
Wen Congyang

> 
> Actually, "check whether any part of this memory range has been
> onlined" would be better.  If that is accurate ;)
> 
>> +	 */
>> +	if (!is_memblk_offline(start, size)) {
>> +		pr_warn("memory removing [mem %#010llx-%#010llx] failed, "
>> +			"because the memmory range is online\n",
>> +			start, start + size);
>> +		ret = -EAGAIN;
>> +	}
>> +
>> +	unlock_memory_hotplug();
>> +	return ret;
>> +
>> +}
>> +EXPORT_SYMBOL_GPL(remove_memory);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
