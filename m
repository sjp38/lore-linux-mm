Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E74306B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 01:07:47 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so2087334pdi.7
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 22:07:47 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id wh10si4151920pab.307.2014.03.05.22.07.43
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 22:07:47 -0800 (PST)
Date: Thu, 06 Mar 2014 14:07:19 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 449/471] arch/powerpc/mm/stab.c:138:1930: error:
 lvalue required as left operand of assignment
Message-ID: <53181097.1/AXUdnYumG1peap%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: f6d4db312108dac3960ea8c20f00a06ee6815d7a [449/471] powerpc: rep=
lace __get_cpu_var uses
config: make ARCH=3Dpowerpc allmodconfig

All error/warnings:

   arch/powerpc/mm/stab.c: In function '__ste_allocate':
>> arch/powerpc/mm/stab.c:138:1930: error: lvalue required as left oper=
and of assignment
       __this_cpu_read(stab_cache[offset++]) =3D stab_entry;
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                ^
--
   kernel/softirq.c: In function '__do_softirq':
>> kernel/softirq.c:252:2067: error: lvalue required as left operand of=
 assignment
     set_softirq_pending(0);
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
           ^
   kernel/softirq.c: In function '__raise_softirq_irqoff':
>> kernel/softirq.c:427:2067: error: lvalue required as left operand of=
 assignment
     or_softirq_pending(1UL << nr);
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
                                                                       =
           ^

vim +138 arch/powerpc/mm/stab.c

   132=09
   133=09=09stab_entry =3D make_ste(get_paca()->stab_addr, GET_ESID(ea)=
, vsid);
   134=09
   135=09=09if (!is_kernel_addr(ea)) {
   136=09=09=09offset =3D __this_cpu_read(stab_cache_ptr);
   137=09=09=09if (offset < NR_STAB_CACHE_ENTRIES)
 > 138=09=09=09=09__this_cpu_read(stab_cache[offset++]) =3D stab_entry;
   139=09=09=09else
   140=09=09=09=09offset =3D NR_STAB_CACHE_ENTRIES+1;
   141=09=09=09__this_cpu_write(stab_cache_ptr, offset);

---
0-DAY kernel build testing backend              Open Source Technology =
Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corpo=
ration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
