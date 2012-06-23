Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D3FF06B0293
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 01:58:32 -0400 (EDT)
Received: by lbbgj3 with SMTP id gj3so4886852lbb.11
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 22:58:30 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 23 Jun 2012 11:28:30 +0530
Message-ID: <CAJ7qFSdiGw1krDbWg6HvwBymp2gwrYKb8UuA00wSP0rgZi-EMw@mail.gmail.com>
Subject: Crash with VMALLOC api
From: "R, Sricharan" <r.sricharan@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-omap@vger.kernel.org

Hi,
  I am observing a below crash with VMALLOC call on mainline kernel.
  The issue happens when there is insufficent vmalloc space.
  Isn't it expected that the API should return a NULL instead of crashing when
  there is not enough memory?. This can be reproduced with succesive vmalloc
  calls for a size of about say 10MB, without a vfree, thus exhausting
the memory.

 Strangely when vmalloc is requested for a large chunk, then at that time API
 does not crash instead returns a NULL correctly.

  Please correct me if my understanding is not correct..

--------------------------------------------------------------------------------------

[  345.059841] Unable to handle kernel paging request at virtual
address 90011000
[  345.067063] pgd = ebc34000
[  345.069793] [90011000] *pgd=00000000
[  345.073383] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
[  345.078685] Modules linked in: bcmdhd cfg80211 inv_mpu_ak8975
inv_mpu_kxtf9 mpu3050
[  345.086380] CPU: 0    Tainted: G        W     (3.4.0-rc1-05660-g0d4b175 #1)
[  345.093351] PC is at vmap_page_range_noflush+0xf0/0x200
[  345.098569] LR is at vmap_page_range+0x14/0x50
[  345.103005] pc : [<c01091c8>]    lr : [<c01092ec>]    psr: 80000013
[  345.103009] sp : ebc41e38  ip : fe000fff  fp : 00002000
[  345.114472] r10: c0a78480  r9 : 90011000  r8 : c096e2ac
[  345.119685] r7 : 90011000  r6 : 00000000  r5 : fe000000  r4 : 00000000
[  345.126198] r3 : 50011452  r2 : f385c400  r1 : fe000fff  r0 : f385c400
[  345.132713] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[  345.139835] Control: 10c5387d  Table: abc3404a  DAC: 00000015

Thanks,
 Sricharan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
