Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB6566B000C
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:52:02 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t192so8326354iof.6
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:52:02 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m85si1997014iod.122.2018.02.23.10.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 10:52:01 -0800 (PST)
Subject: Re: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data
 Integrity)
References: <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
 <201802231005.WSf8KcHd%fengguang.wu@intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <490b8c3b-fc62-b6e7-af28-7c1257e953ce@oracle.com>
Date: Fri, 23 Feb 2018 11:51:25 -0700
MIME-Version: 1.0
In-Reply-To: <201802231005.WSf8KcHd%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net
Cc: kbuild-all@01.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 02/22/2018 07:50 PM, kbuild test robot wrote:
> Hi Khalid,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on sparc-next/master]
> [also build test ERROR on v4.16-rc2]
> [cannot apply to next-20180222]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Khalid-Aziz/Application-Data-Integrity-feature-introduced-by-SPARC-M7/20180223-071725
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-next.git master
> config: sparc64-allyesconfig (attached as .config)
> compiler: sparc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=sparc64
> 
> All error/warnings (new ones prefixed by >>):

Hi Dave,

Including linux/sched.h in arch/sparc/include/asm/mmu_context.h should 
eliminate these build warnings. My gcc version 6.2.1 does not report 
these errors. Build bot is using 7.2.0.

I can add a patch 12 to add the include, revise patch 10 or you can add 
the include in your tree. Let me know how you would prefer to resolve this.

Thanks,
Khalid

> 
>     In file included from arch/sparc/include/asm/mmu_context.h:5:0,
>                      from include/linux/mmu_context.h:5,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.h:29,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:23:
>     arch/sparc/include/asm/mmu_context_64.h: In function 'arch_start_context_switch':
>>> arch/sparc/include/asm/mmu_context_64.h:157:4: error: implicit declaration of function 'set_tsk_thread_flag'; did you mean 'set_ti_thread_flag'? [-Werror=implicit-function-declaration]
>         set_tsk_thread_flag(prev, TIF_MCDPER);
>         ^~~~~~~~~~~~~~~~~~~
>         set_ti_thread_flag
>>> arch/sparc/include/asm/mmu_context_64.h:159:4: error: implicit declaration of function 'clear_tsk_thread_flag'; did you mean 'clear_ti_thread_flag'? [-Werror=implicit-function-declaration]
>         clear_tsk_thread_flag(prev, TIF_MCDPER);
>         ^~~~~~~~~~~~~~~~~~~~~
>         clear_ti_thread_flag
>     arch/sparc/include/asm/mmu_context_64.h: In function 'finish_arch_post_lock_switch':
>>> arch/sparc/include/asm/mmu_context_64.h:180:25: error: dereferencing pointer to incomplete type 'struct task_struct'
>        if (current && current->mm && current->mm->context.adi) {
>                              ^~
>     In file included from arch/sparc/include/asm/processor.h:5:0,
>                      from arch/sparc/include/asm/spinlock_64.h:12,
>                      from arch/sparc/include/asm/spinlock.h:5,
>                      from include/linux/spinlock.h:88,
>                      from arch/sparc/include/asm/mmu_context_64.h:9,
>                      from arch/sparc/include/asm/mmu_context.h:5,
>                      from include/linux/mmu_context.h:5,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.h:29,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:23:
>>> arch/sparc/include/asm/processor_64.h:194:28: error: implicit declaration of function 'task_thread_info'; did you mean 'test_thread_flag'? [-Werror=implicit-function-declaration]
>      #define task_pt_regs(tsk) (task_thread_info(tsk)->kregs)
>                                 ^
>>> arch/sparc/include/asm/mmu_context_64.h:183:11: note: in expansion of macro 'task_pt_regs'
>         regs = task_pt_regs(current);
>                ^~~~~~~~~~~~
>>> arch/sparc/include/asm/processor_64.h:194:49: error: invalid type argument of '->' (have 'int')
>      #define task_pt_regs(tsk) (task_thread_info(tsk)->kregs)
>                                                      ^
>>> arch/sparc/include/asm/mmu_context_64.h:183:11: note: in expansion of macro 'task_pt_regs'
>         regs = task_pt_regs(current);
>                ^~~~~~~~~~~~
>     In file included from include/linux/cred.h:21:0,
>                      from include/linux/seq_file.h:12,
>                      from include/linux/pinctrl/consumer.h:17,
>                      from include/linux/pinctrl/devinfo.h:21,
>                      from include/linux/device.h:23,
>                      from include/linux/cdev.h:8,
>                      from include/drm/drmP.h:36,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:25:
>     include/linux/sched.h: At top level:
>>> include/linux/sched.h:1530:20: warning: conflicting types for 'set_tsk_thread_flag'
>      static inline void set_tsk_thread_flag(struct task_struct *tsk, int flag)
>                         ^~~~~~~~~~~~~~~~~~~
>>> include/linux/sched.h:1530:20: error: static declaration of 'set_tsk_thread_flag' follows non-static declaration
>     In file included from arch/sparc/include/asm/mmu_context.h:5:0,
>                      from include/linux/mmu_context.h:5,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.h:29,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:23:
>     arch/sparc/include/asm/mmu_context_64.h:157:4: note: previous implicit declaration of 'set_tsk_thread_flag' was here
>         set_tsk_thread_flag(prev, TIF_MCDPER);
>         ^~~~~~~~~~~~~~~~~~~
>     In file included from include/linux/cred.h:21:0,
>                      from include/linux/seq_file.h:12,
>                      from include/linux/pinctrl/consumer.h:17,
>                      from include/linux/pinctrl/devinfo.h:21,
>                      from include/linux/device.h:23,
>                      from include/linux/cdev.h:8,
>                      from include/drm/drmP.h:36,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:25:
>>> include/linux/sched.h:1535:20: warning: conflicting types for 'clear_tsk_thread_flag'
>      static inline void clear_tsk_thread_flag(struct task_struct *tsk, int flag)
>                         ^~~~~~~~~~~~~~~~~~~~~
>>> include/linux/sched.h:1535:20: error: static declaration of 'clear_tsk_thread_flag' follows non-static declaration
>     In file included from arch/sparc/include/asm/mmu_context.h:5:0,
>                      from include/linux/mmu_context.h:5,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.h:29,
>                      from drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd.c:23:
>     arch/sparc/include/asm/mmu_context_64.h:159:4: note: previous implicit declaration of 'clear_tsk_thread_flag' was here
>         clear_tsk_thread_flag(prev, TIF_MCDPER);
>         ^~~~~~~~~~~~~~~~~~~~~
>     cc1: some warnings being treated as errors
> 
> vim +157 arch/sparc/include/asm/mmu_context_64.h
> 
>       8	
>     > 9	#include <linux/spinlock.h>
>      10	#include <linux/mm_types.h>
>      11	#include <linux/smp.h>
>      12	
>      13	#include <asm/spitfire.h>
>      14	#include <asm/adi_64.h>
>      15	#include <asm-generic/mm_hooks.h>
>      16	#include <asm/percpu.h>
>      17	
>      18	static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>      19	{
>      20	}
>      21	
>      22	extern spinlock_t ctx_alloc_lock;
>      23	extern unsigned long tlb_context_cache;
>      24	extern unsigned long mmu_context_bmap[];
>      25	
>      26	DECLARE_PER_CPU(struct mm_struct *, per_cpu_secondary_mm);
>      27	void get_new_mmu_context(struct mm_struct *mm);
>      28	int init_new_context(struct task_struct *tsk, struct mm_struct *mm);
>      29	void destroy_context(struct mm_struct *mm);
>      30	
>      31	void __tsb_context_switch(unsigned long pgd_pa,
>      32				  struct tsb_config *tsb_base,
>      33				  struct tsb_config *tsb_huge,
>      34				  unsigned long tsb_descr_pa,
>      35				  unsigned long secondary_ctx);
>      36	
>      37	static inline void tsb_context_switch_ctx(struct mm_struct *mm,
>      38						  unsigned long ctx)
>      39	{
>      40		__tsb_context_switch(__pa(mm->pgd),
>      41				     &mm->context.tsb_block[MM_TSB_BASE],
>      42	#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
>      43				     (mm->context.tsb_block[MM_TSB_HUGE].tsb ?
>      44				      &mm->context.tsb_block[MM_TSB_HUGE] :
>      45				      NULL)
>      46	#else
>      47				     NULL
>      48	#endif
>      49				     , __pa(&mm->context.tsb_descr[MM_TSB_BASE]),
>      50				     ctx);
>      51	}
>      52	
>      53	#define tsb_context_switch(X) tsb_context_switch_ctx(X, 0)
>      54	
>      55	void tsb_grow(struct mm_struct *mm,
>      56		      unsigned long tsb_index,
>      57		      unsigned long mm_rss);
>      58	#ifdef CONFIG_SMP
>      59	void smp_tsb_sync(struct mm_struct *mm);
>      60	#else
>      61	#define smp_tsb_sync(__mm) do { } while (0)
>      62	#endif
>      63	
>      64	/* Set MMU context in the actual hardware. */
>      65	#define load_secondary_context(__mm) \
>      66		__asm__ __volatile__( \
>      67		"\n661:	stxa		%0, [%1] %2\n" \
>      68		"	.section	.sun4v_1insn_patch, \"ax\"\n" \
>      69		"	.word		661b\n" \
>      70		"	stxa		%0, [%1] %3\n" \
>      71		"	.previous\n" \
>      72		"	flush		%%g6\n" \
>      73		: /* No outputs */ \
>      74		: "r" (CTX_HWBITS((__mm)->context)), \
>      75		  "r" (SECONDARY_CONTEXT), "i" (ASI_DMMU), "i" (ASI_MMU))
>      76	
>      77	void __flush_tlb_mm(unsigned long, unsigned long);
>      78	
>      79	/* Switch the current MM context. */
>      80	static inline void switch_mm(struct mm_struct *old_mm, struct mm_struct *mm, struct task_struct *tsk)
>      81	{
>      82		unsigned long ctx_valid, flags;
>      83		int cpu = smp_processor_id();
>      84	
>      85		per_cpu(per_cpu_secondary_mm, cpu) = mm;
>      86		if (unlikely(mm == &init_mm))
>      87			return;
>      88	
>      89		spin_lock_irqsave(&mm->context.lock, flags);
>      90		ctx_valid = CTX_VALID(mm->context);
>      91		if (!ctx_valid)
>      92			get_new_mmu_context(mm);
>      93	
>      94		/* We have to be extremely careful here or else we will miss
>      95		 * a TSB grow if we switch back and forth between a kernel
>      96		 * thread and an address space which has it's TSB size increased
>      97		 * on another processor.
>      98		 *
>      99		 * It is possible to play some games in order to optimize the
>     100		 * switch, but the safest thing to do is to unconditionally
>     101		 * perform the secondary context load and the TSB context switch.
>     102		 *
>     103		 * For reference the bad case is, for address space "A":
>     104		 *
>     105		 *		CPU 0			CPU 1
>     106		 *	run address space A
>     107		 *	set cpu0's bits in cpu_vm_mask
>     108		 *	switch to kernel thread, borrow
>     109		 *	address space A via entry_lazy_tlb
>     110		 *					run address space A
>     111		 *					set cpu1's bit in cpu_vm_mask
>     112		 *					flush_tlb_pending()
>     113		 *					reset cpu_vm_mask to just cpu1
>     114		 *					TSB grow
>     115		 *	run address space A
>     116		 *	context was valid, so skip
>     117		 *	TSB context switch
>     118		 *
>     119		 * At that point cpu0 continues to use a stale TSB, the one from
>     120		 * before the TSB grow performed on cpu1.  cpu1 did not cross-call
>     121		 * cpu0 to update it's TSB because at that point the cpu_vm_mask
>     122		 * only had cpu1 set in it.
>     123		 */
>     124		tsb_context_switch_ctx(mm, CTX_HWBITS(mm->context));
>     125	
>     126		/* Any time a processor runs a context on an address space
>     127		 * for the first time, we must flush that context out of the
>     128		 * local TLB.
>     129		 */
>     130		if (!ctx_valid || !cpumask_test_cpu(cpu, mm_cpumask(mm))) {
>     131			cpumask_set_cpu(cpu, mm_cpumask(mm));
>     132			__flush_tlb_mm(CTX_HWBITS(mm->context),
>     133				       SECONDARY_CONTEXT);
>     134		}
>     135		spin_unlock_irqrestore(&mm->context.lock, flags);
>     136	}
>     137	
>     138	#define deactivate_mm(tsk,mm)	do { } while (0)
>     139	#define activate_mm(active_mm, mm) switch_mm(active_mm, mm, NULL)
>     140	
>     141	#define  __HAVE_ARCH_START_CONTEXT_SWITCH
>     142	static inline void arch_start_context_switch(struct task_struct *prev)
>     143	{
>     144		/* Save the current state of MCDPER register for the process
>     145		 * we are switching from
>     146		 */
>     147		if (adi_capable()) {
>     148			register unsigned long tmp_mcdper;
>     149	
>     150			__asm__ __volatile__(
>     151				".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
>     152				"mov %%g1, %0\n\t"
>     153				: "=r" (tmp_mcdper)
>     154				:
>     155				: "g1");
>     156			if (tmp_mcdper)
>   > 157				set_tsk_thread_flag(prev, TIF_MCDPER);
>     158			else
>   > 159				clear_tsk_thread_flag(prev, TIF_MCDPER);
>     160		}
>     161	}
>     162	
>     163	#define finish_arch_post_lock_switch	finish_arch_post_lock_switch
>     164	static inline void finish_arch_post_lock_switch(void)
>     165	{
>     166		/* Restore the state of MCDPER register for the new process
>     167		 * just switched to.
>     168		 */
>     169		if (adi_capable()) {
>     170			register unsigned long tmp_mcdper;
>     171	
>     172			tmp_mcdper = test_thread_flag(TIF_MCDPER);
>     173			__asm__ __volatile__(
>     174				"mov %0, %%g1\n\t"
>     175				".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" */
>     176				".word 0xaf902001\n\t"	/* wrpr %g0, 1, %pmcdper */
>     177				:
>     178				: "ir" (tmp_mcdper)
>     179				: "g1");
>   > 180			if (current && current->mm && current->mm->context.adi) {
>     181				struct pt_regs *regs;
>     182	
>   > 183				regs = task_pt_regs(current);
>     184				regs->tstate |= TSTATE_MCDE;
>     185			}
>     186		}
>     187	}
>     188	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
