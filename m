Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 36EBD6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:35:20 -0400 (EDT)
Received: by oicf142 with SMTP id f142so39748131oic.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:35:19 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id f18si3807845oem.54.2015.03.26.06.35.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 06:35:18 -0700 (PDT)
Message-ID: <55140869.7060507@huawei.com>
Date: Thu, 26 Mar 2015 21:23:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: arm/ksm: Unable to handle kernel paging request in get_ksm_page()
 and ksm_scan_thread()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, neilb@suse.de, heiko.carstens@de.ibm.com, dhowells@redhat.com, hughd@google.com, izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Here are two panic logs from smart phone test, and the kernel version is v3.10.

log1 is "Unable to handle kernel paging request at virtual address c0704da020", it should be ffffffc0704da020, right?
and log2 is "Unable to handle kernel paging request at virtual address 1e000796", it should be ffffffc01e000796, right?

I cann't repeat the panic by test, so could anyone tell me this is the 
bug of ksm or other reason?

Thanks,
Xishi Qiu


log 1:
[139399.132049s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]Unable to handle kernel paging request at virtual address c0704da020
[139399.132080s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]pgd = ffffffc07d50a000
[139399.132080s][2015:02:09 02:51:36][pid:863,cpu0,ksmd][c0704da020] *pgd=0000000000000000
[139399.132110s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]Internal error: Oops: 96000004 [#1] PREEMPT SMP
[139399.132141s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]Modules linked in:
[139399.132141s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]CPU: 0 PID: 863 Comm: ksmd Tainted: G        W    3.10.61-g8efbf1c-dirty #1
[139399.132171s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]task: ffffffc0bc5ce300 ti: ffffffc0baaf4000 task.ti: ffffffc0baaf4000
[139399.132202s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]PC is at get_ksm_page+0x34/0x150
[139399.132232s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]LR is at remove_rmap_item_from_tree+0x7c/0x18c
[139399.132232s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]pc : [<ffffffc0007790a8>] lr : [<ffffffc000779240>] pstate: a0000145
[139399.132263s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]sp : ffffffc0baaf7ce0
[139399.132263s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x29: ffffffc0baaf7ce0 x28: 0000000075a04000 
[139399.132293s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x27: ffffffbc02794c28 x26: ffffffc001099000 
[139399.132324s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x25: ffffffc0b8b74e70 x24: ffffffc0baaf4000 
[139399.132324s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x23: 000000c0704da003 x22: 000000c0704da000 
[139399.132354s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x21: 000000c0704da000 x20: 0000000000000001 
[139399.132354s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x19: ffffffc09cdc0080 x18: 0000000000000000 
[139399.132385s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x17: 0000007f861ebb88 x16: ffffffc000797ecc 
[139399.132415s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x15: 0000000066666667 x14: 000000000000000a 
[139399.132415s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x13: 0000007f6dcb49f0 x12: 0ab00f52159a6215 
[139399.132446s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x11: 0000000000000330 x10: 0000000000000001 
[139399.132476s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x9 : ffffffc0baaf7b60 x8 : ffffffc0bc5ce840 
[139399.132476s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x7 : 0000000000000063 x6 : 0000000000000001 
[139399.132507s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x5 : ffffffc097939d10 x4 : 00000000000bffff 
[139399.132537s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x3 : 0000000000000001 x2 : ffffffbc02794c44 
[139399.132537s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]x1 : 0000000000000001 x0 : 000000c0704da000 
[139399.132568s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]
[139399.132568s]PC: 0xffffffc000779028:
[139399.132598s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]9028  912a42b5 f9400a83 d2804001 f2a00401 d2802002 f9000483 f2a00202 f9000064
[139399.132629s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]9048  f94016a0 f9000682 f9000a81 aa1403e1 94001c51 f94013f5 a94153f3 a8c37bfd
[139399.132659s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]9068  d65f03c0 d0009215 17ffffd4 a9bc7bfd 910003fd a90153f3 a9025bf5 f9001bf7
[139399.132690s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]9088  aa0003f6 53001c34 91000c17 14000005 d50339bf f94012c0 eb15001f 54000600
[139399.132720s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]90a8  f94012d5 d2dff782 f2ffffe2 d37ae6b3 cb150e73 8b020273 91007263 f9400660
[139399.132751s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]90c8  eb17001f 54fffe61 b9401e64 34000304 11000485 d5033bbf 885f7c62 6b04005f
[139399.132781s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]90e8  54000061 88007c65 35ffff80 d5033bbf 6b02009f 54000181 14000010 d5033bbf
[139399.132843s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]9108  885f7c65 6b0200bf 54000061 88067c64 35ffff86 d5033bbf 6b0200bf 2a0503e2
...
[139399.136749s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]Call trace:
[139399.136779s][2015:02:09 02:51:36][pid:863,cpu0,ksmd][<ffffffc0007790a8>] get_ksm_page+0x34/0x150
[139399.136779s][2015:02:09 02:51:36][pid:863,cpu0,ksmd][<ffffffc00077923c>] remove_rmap_item_from_tree+0x78/0x18c
[139399.136810s][2015:02:09 02:51:36][pid:863,cpu0,ksmd][<ffffffc00077a74c>] ksm_scan_thread+0x888/0xce0
[139399.136840s][2015:02:09 02:51:36][pid:863,cpu0,ksmd][<ffffffc0006bdd20>] kthread+0xb4/0xc0
[139399.136840s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]Code: d50339bf f94012c0 eb15001f 54000600 (f94012d5) 
[139399.136993s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]rdr:onlyDumpMem,dontSave,id:0x81000001
[139399.136993s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]rdr:rdr_system_dump() enter, begin to dump mem.
[139399.137023s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]rdr:ap excep,nofify cp(ipc),iom3(nmi),lpm3(ipc)
[139399.151153s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]rdr:exception datetime:20150209025136, uptime:42744.716300
[139399.151214s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]sysreboot reason: ARM EXCE AP, tick: 20150209025136_42744.716300, systemError para: ModId=0x7, Arg1=1, Arg2=0
[139399.165893s][2015:02:09 02:51:36][pid:863,cpu0,ksmd]---[ end trace 468fbf69c0311dd3 ]---


log2:
<1>[  492.102661s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]Unable to handle kernel paging request at virtual address 1e000796
<1>[  492.102722s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]pgd = ffffffc001ed2000
<1>[  492.102752s][2015:02:08 15:08:50][pid:866,cpu2,ksmd][1e000796] *pgd=0000000000246003, *pmd=0000000000000000
<0>[  492.102813s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]Internal error: Oops: 96000006 [#1] PREEMPT SMP
<4>[  492.102844s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]Modules linked in:
<4>[  492.102905s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]CPU: 2 PID: 866 Comm: ksmd Not tainted 3.10.61-g8efbf1c-dirty #1
<4>[  492.102935s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]task: ffffffc0bc011600 ti: ffffffc0bab5c000 task.ti: ffffffc0bab5c000
<4>[  492.102996s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]PC is at ksm_scan_thread+0x4ac/0xce0
<4>[  492.103057s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]LR is at ksm_scan_thread+0x49c/0xce0
<4>[  492.103118s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]pc : [<ffffffc00077a370>] lr : [<ffffffc00077a360>] pstate: 80000105
<4>[  492.103149s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]sp : ffffffc0bab5fd50
<4>[  492.103179s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x29: ffffffc0bab5fd50 x28: 0000000073872000 
<4>[  492.103240s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x27: ffffffbc023c07c8 x26: ffffffc001099000 
<4>[  492.103302s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x25: ffffffc0aa9c0270 x24: ffffffc0bab5c000 
<4>[  492.103332s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x23: ffffffc0019bba90 x22: ffffffc0bab5fdf8 
<4>[  492.103393s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x21: ffffffc062121000 x20: 000000001e00077e 
<4>[  492.103454s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x19: ffffffc001890f08 x18: 0000000000000000 
<4>[  492.103485s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x17: 0000000000000000 x16: 0000000000000000 
<4>[  492.103546s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x15: 0000000000000000 x14: 0000000000000000 
<4>[  492.103576s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x13: 0000000000000000 x12: 0000000034c5d83d 
<4>[  492.103637s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x11: 0000000000000000 x10: 00000000b977b732 
<4>[  492.103668s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x9 : 00000000691c739b x8 : 0000000000000000 
<4>[  492.103729s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x7 : ffffffc05f87dd28 x6 : 00000000604af94d 
<4>[  492.103759s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x5 : ffffffc0b31ebb00 x4 : 00000000000bffff 
<4>[  492.103820s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x3 : 0000000000000001 x2 : 0000000000000001 
<4>[  492.103881s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]x1 : 0000000000100051 x0 : ffffffbc023c07c8 
<4>[  492.103942s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]
<4>[  492.103942s]PC: 0xffffffc00077a2f0:
<4>[  492.103973s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a2f0  f9400b00 f9400400 f9400000 3607fdc0 91028260 aa1603e1 97fd11a5 f9400b01
<4>[  492.104064s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a310  b9401420 12017800 b9001420 d5033bbf f940d75a f9400b00 b9400341 34ffdfc1
<4>[  492.104156s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a330  97fda358 53001c00 34ffdf60 52800000 97fda373 17fffef8 f0007ec0 b9466800
<4>[  492.104217s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a350  97fc9942 94245303 17fffef3 97fc6a79 f9400a75 f940067c f94002b4 b4002a14
<4>[  492.104309s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a370  f9400e80 9274cc01 eb01039f 540019a0 eb00039f 54002943 b0009200 f9003fa0
<4>[  492.104400s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a390  14000007 f9400e80 9274cc01 eb01039f 54001860 eb00039f 540001c3 f9400281
<4>[  492.104492s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a3b0  aa1403e0 f90002a1 97fffb83 f9000a9f f94002e2 aa1403e1 f9401ee0 d1000442
<4>[  492.104583s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]a3d0  f90002e2 94001772 f94002b4 b5fffdd4 f9403fa0 52901a01 912a4000 f9401c00
...
<4>[  492.114837s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]Call trace:
<4>[  492.114898s][2015:02:08 15:08:50][pid:866,cpu2,ksmd][<ffffffc00077a370>] ksm_scan_thread+0x4ac/0xce0
<4>[  492.114959s][2015:02:08 15:08:50][pid:866,cpu2,ksmd][<ffffffc0006bdd20>] kthread+0xb4/0xc0
<0>[  492.114990s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]Code: f9400a75 f940067c f94002b4 b4002a14 (f9400e80) 
<6>[  492.115112s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]rdr:onlyDumpMem,dontSave,id:0x81000001
<6>[  492.115203s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]rdr:rdr_system_dump() enter, begin to dump mem.
<6>[  492.115264s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]rdr:ap excep,nofify cp(ipc),iom3(nmi),lpm3(ipc)
<6>[  492.155975s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]rdr:exception datetime:20150208150850, uptime:00503.926075
<6>[  492.156066s][2015:02:08 15:08:50][pid:866,cpu2,ksmd]sysreboot reason: ARM EXCE AP, tick: 20150208150850_00503.926075, systemError para: ModId=0x7, Arg1=1, Arg2=0
<4>[  492.199157s][2015:02:08 15:08:50][pid:866,cpu1,ksmd]---[ end trace 10d7afe1b1671be2 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
