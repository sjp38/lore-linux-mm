From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 17/22] s390: Use generic show_mem()
Date: Thu, 03 Apr 2008 15:00:22 +0200
Message-ID: <87iqyzozyx.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<12071690203023-git-send-email-hannes@saeurebad.de>
	<20080403075029.GB4125@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757561AbYDCNAj@vger.kernel.org>
In-Reply-To: <20080403075029.GB4125@osiris.boeblingen.de.ibm.com> (Heiko
	Carstens's message of "Thu, 3 Apr 2008 09:50:29 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi,

Heiko Carstens <heiko.carstens@de.ibm.com> writes:

>> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>> index 8053245..27b94cb 100644
>> --- a/arch/s390/mm/init.c
>> +++ b/arch/s390/mm/init.c
>> @@ -42,42 +42,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
>>  pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
>>  char  empty_zero_page[PAGE_SIZE] __attribute__((__aligned__(PAGE_SIZE)));
>> 
>> -	printk("Free swap:       %6ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
>> -	printk("%lu pages dirty\n", global_page_state(NR_FILE_DIRTY));
>> -	printk("%lu pages writeback\n", global_page_state(NR_WRITEBACK));
>> -	printk("%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
>> -	printk("%lu pages slab\n",
>> -	       global_page_state(NR_SLAB_RECLAIMABLE) +
>> -	       global_page_state(NR_SLAB_UNRECLAIMABLE));
>> -	printk("%lu pages pagetables\n", global_page_state(NR_PAGETABLE));
>
> These are all missing in the generic implementation.

These are all duplicates from show_free_areas().

Thanks,

	Hannes
