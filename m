From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 17/22] s390: Use generic show_mem()
Date: Fri, 04 Apr 2008 00:37:53 +0200
Message-ID: <87lk3umuny.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<12071690203023-git-send-email-hannes@saeurebad.de>
	<20080403075029.GB4125@osiris.boeblingen.de.ibm.com>
	<87iqyzozyx.fsf@saeurebad.de>
	<20080403175856.GA4131@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759596AbYDCWiT@vger.kernel.org>
In-Reply-To: <20080403175856.GA4131@osiris.boeblingen.de.ibm.com> (Heiko
	Carstens's message of "Thu, 3 Apr 2008 19:58:56 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi,

Heiko Carstens <heiko.carstens@de.ibm.com> writes:

> On Thu, Apr 03, 2008 at 03:00:22PM +0200, Johannes Weiner wrote:
>> Hi,
>> 
>> Heiko Carstens <heiko.carstens@de.ibm.com> writes:
>> 
>> >> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>> >> index 8053245..27b94cb 100644
>> >> --- a/arch/s390/mm/init.c
>> >> +++ b/arch/s390/mm/init.c
>> >> @@ -42,42 +42,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
>> >>  pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
>> >>  char  empty_zero_page[PAGE_SIZE] __attribute__((__aligned__(PAGE_SIZE)));
>> >> 
>> >> -	printk("Free swap:       %6ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
>> >> -	printk("%lu pages dirty\n", global_page_state(NR_FILE_DIRTY));
>> >> -	printk("%lu pages writeback\n", global_page_state(NR_WRITEBACK));
>> >> -	printk("%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
>> >> -	printk("%lu pages slab\n",
>> >> -	       global_page_state(NR_SLAB_RECLAIMABLE) +
>> >> -	       global_page_state(NR_SLAB_UNRECLAIMABLE));
>> >> -	printk("%lu pages pagetables\n", global_page_state(NR_PAGETABLE));
>> >
>> > These are all missing in the generic implementation.
>> 
>> These are all duplicates from show_free_areas().
>
> In this case ignore my comment ;)
> Btw. your patch regarding the removal of show_free_areas() from
> s390's arch code will be merged during the next merge window.

Okay.

Do you mean the removal of

	printk("Free swap:       %6ldkB\n", nr_swap_pages << (PAGE_SHIFT
		- 10));

in show_mem()?  This was my last patch series about.

Can I add your Acked-by for _this_ series?

Thanks,

	Hannes
