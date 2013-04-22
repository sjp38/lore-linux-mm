Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id F23B56B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 14:19:03 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so3804503pab.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:19:03 -0700 (PDT)
Message-ID: <51757F0B.1090104@gmail.com>
Date: Mon, 22 Apr 2013 23:48:51 +0530
From: vinayak <vinayakm.list@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add an option to disable bounce
References: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com> <20130422174712.GS14496@n2100.arm.linux.org.uk>
In-Reply-To: <20130422174712.GS14496@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, rientjes@google.com

On Monday 22 April 2013 11:17 PM, Russell King - ARM Linux wrote:

> On Mon, Apr 22, 2013 at 08:53:00PM +0530, vinayakm.list@gmail.com wrote:
>> From: Vinayak Menon <vinayakm.list@gmail.com>
>>
>> There are times when HIGHMEM is enabled, but
>> we don't prefer CONFIG_BOUNCE to be enabled.
>> CONFIG_BOUNCE can reduce the block device
>> throughput, and this is not ideal for machines
>> where we don't gain much by enabling it. So
>> provide an option to deselect CONFIG_BOUNCE. The
>> observation was made while measuring eMMC throughput
>> using iozone on an ARM device with 1GB RAM.
>>
>> Signed-off-by: Vinayak Menon <vinayakm.list@gmail.com>
>> ---
>>  mm/Kconfig |    6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 3bea74f..29f9736 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -263,8 +263,14 @@ config ZONE_DMA_FLAG
>>  	default "1"
>>  
>>  config BOUNCE
>> +	bool "Enable bounce buffers"
>>  	def_bool y
>>  	depends on BLOCK && MMU && (ZONE_DMA || HIGHMEM)
> 
> I don't think this is correct.  You shouldn't use "bool" with "def_bool".
> Sure, add the "bool", but also change "def_bool" to "default".


Yes. I will change it to "default" and this looks to be correct
even from the definition in kconfig-language.txt. But I see other
instances in mm/Kconfig, where bool and def_bool are used together. When
I had tested this patch with def_bool, it worked as expected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
