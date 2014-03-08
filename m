Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 880F16B0031
	for <linux-mm@kvack.org>; Sat,  8 Mar 2014 18:20:45 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr13so5723727pbb.39
        for <linux-mm@kvack.org>; Sat, 08 Mar 2014 15:20:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qy5si12426839pab.195.2014.03.08.15.20.44
        for <linux-mm@kvack.org>;
        Sat, 08 Mar 2014 15:20:44 -0800 (PST)
Date: Sun, 09 Mar 2014 07:20:38 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 440/471] arch/x86/oprofile/op_model_p4.c:375:37:
 sparse: incorrect type in initializer (different address spaces)
Message-ID: <531ba5c6.iQnW1preQQEhB3Bv%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: 07e5ae0b24fb7e704e91414c30a2321e703e7764 [440/471] x86: replace __get_cpu_var uses
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/oprofile/op_model_p4.c:375:37: sparse: incorrect type in initializer (different address spaces)
   arch/x86/oprofile/op_model_p4.c:375:37:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/oprofile/op_model_p4.c:375:37:    got struct cpumask *<noident>
--
   arch/x86/xen/time.c:141:33: sparse: implicit cast to nocast type
>> arch/x86/xen/time.c:161:15: sparse: incorrect type in initializer (different address spaces)
   arch/x86/xen/time.c:161:15:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/xen/time.c:161:15:    got struct pvclock_vcpu_time_info *<noident>
   arch/x86/xen/time.c:178:43: sparse: cannot dereference this type
--
>> arch/x86/kernel/apic/x2apic_cluster.c:45:24: sparse: incorrect type in initializer (different address spaces)
   arch/x86/kernel/apic/x2apic_cluster.c:45:24:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/kernel/apic/x2apic_cluster.c:45:24:    got struct cpumask *<noident>
--
   arch/x86/kernel/cpu/perf_event_p4.c:593:3: sparse: symbol 'p4_event_aliases' was not declared. Should it be static?
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>
>> arch/x86/include/asm/perf_event_p4.h:192:45: sparse: incorrect type in initializer (different address spaces)
   arch/x86/include/asm/perf_event_p4.h:192:45:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/include/asm/perf_event_p4.h:192:45:    got struct cpumask *<noident>

vim +375 arch/x86/oprofile/op_model_p4.c

   359	#define CCCR_SET_ESCR_SELECT(cccr, sel) ((cccr) |= (((sel) & 0x07) << 13))
   360	#define CCCR_SET_PMI_OVF_0(cccr) ((cccr) |= (1<<26))
   361	#define CCCR_SET_PMI_OVF_1(cccr) ((cccr) |= (1<<27))
   362	#define CCCR_SET_ENABLE(cccr) ((cccr) |= (1<<12))
   363	#define CCCR_SET_DISABLE(cccr) ((cccr) &= ~(1<<12))
   364	#define CCCR_OVF_P(cccr) ((cccr) & (1U<<31))
   365	#define CCCR_CLEAR_OVF(cccr) ((cccr) &= (~(1U<<31)))
   366	
   367	
   368	/* this assigns a "stagger" to the current CPU, which is used throughout
   369	   the code in this module as an extra array offset, to select the "even"
   370	   or "odd" part of all the divided resources. */
   371	static unsigned int get_stagger(void)
   372	{
   373	#ifdef CONFIG_SMP
   374		int cpu = smp_processor_id();
 > 375		return cpu != cpumask_first(this_cpu_ptr(cpu_sibling_map));
   376	#endif
   377		return 0;
   378	}
   379	
   380	
   381	/* finally, mediate access to a real hardware counter
   382	   by passing a "virtual" counter numer to this macro,
   383	   along with your stagger setting. */

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
