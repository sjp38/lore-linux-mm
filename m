Message-ID: <48A4BCCC.6090001@sciatl.com>
Date: Thu, 14 Aug 2008 16:16:28 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz>
In-Reply-To: <1218753308.23641.56.camel@nimitz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>


>> +		if (boot_mem_map.map[i].type != BOOT_MEM_RAM)
>> +			continue;
>> +
>> +		start = PFN_UP(boot_mem_map.map[i].addr);
>> +		end   = PFN_DOWN(boot_mem_map.map[i].addr
>> +				    + boot_mem_map.map[i].size);
>> +
>> +		memory_present(0, start, end);
>> +	}
>>  }
>>     
>
> Is that aligning really necessary?  I'm just curious because if it is,
> it would probably be good to stick it inside memory_present().
>
>   
yaknow, there are several loops in this file that look through this 
boot_mem_ map structure.
they all have the same basic form (but of course are slightly 
different). Anyhow, I just
cut and pasted. I'm wondering if the MIPS folks have comment on how best 
to make
this change and possibly clean up this file. I'm happy to do it, but 
think I'd like some
guidance on this... anyone?


I'll fix and resubmit. sorry for posting this to the two lists, but I 
wasn't sure if I should
put it on the linux-mm list or the linux-mips list... I'll keep the 
distribution unless I
her complaints.

mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
