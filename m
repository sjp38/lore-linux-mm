Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D52CC6B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 13:38:00 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z20so3231644dae.17
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 10:38:00 -0700 (PDT)
Message-ID: <5175756C.5080009@gmail.com>
Date: Mon, 22 Apr 2013 23:07:48 +0530
From: vinayak <vinayakm.list@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add an option to disable bounce
References: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com> <51756C24.8060505@infradead.org>
In-Reply-To: <51756C24.8060505@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Monday 22 April 2013 10:28 PM, Randy Dunlap wrote:

> On 04/22/13 08:23, vinayakm.list@gmail.com wrote:
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
>> +	help
>> +	  Enable bounce buffers for devices that cannot access
>> +	  the full range of memory available to the CPU. Enabled
>> +	  by default when ZONE_DMA or HIGMEM is selected, but you
> 
> 	                              HIGHMEM


Thanks. I will correct this.

> 
>> +	  may say n to override this.
>>  
>>  # On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
>>  # have more than 4GB of memory, but we don't currently use the IOTLB to present
>>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
