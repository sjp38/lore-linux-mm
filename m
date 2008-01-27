Received: by py-out-1112.google.com with SMTP id f47so1316980pye.20
        for <linux-mm@kvack.org>; Sat, 26 Jan 2008 22:54:07 -0800 (PST)
Message-ID: <2f11576a0801262254i55cb2c96q40023aa0e53bffce@mail.gmail.com>
Date: Sun, 27 Jan 2008 15:54:06 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <20080126171803.GA29252@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
	 <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123102332.GB21455@csn.ul.ie>
	 <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
	 <20080126171803.GA29252@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi Mel

> > my patch stack is
> >   2.6.24-rc7 +
> >   http://lkml.org/lkml/2007/8/24/220 +
>
> Can you replace this patch with the patch below instead and try again
> please? This is the patch that is actually in git-x86. Out of
> curiousity, have you tried the latest mm branch from git-x86?

to be honest, I didn't understand usage of git, sorry.
I learned method of git checkout today and test again (head of git-x86
+ your previous patch).

result
       -> panic again.

-------------------------------------------------------------------------------------------
  Booting 'kosatest'

root (hd0,0)
 Filesystem type is ext2fs, partition type 0x83
kernel /vmlinuz-kosatest ro root=/dev/VolGroup00/LogVol00 rhgb quiet console=tt
y0 console=ttyS0,9600n8r
   [Linux-bzImage, setup=0x2800, size=0x27bd58]
initrd /initrd-kosatest.img
   [Linux-initrd @ 0x1f3bc000, 0x2c052c bytes]

Bad page state in process 'swapper'
page:c13ecfa0 flags:0x00000000 mapping:00000000 mapcount:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Bad page state in process 'swapper'
page:c13ecfc0 flags:0x00000000 mapping:00000000 mapcount:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Bad page state in process 'swapper'
page:c13ecfe0 flags:0x00000000 mapping:00000000 mapcount:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Bad page state in process 'swapper'
page:c13ed000 flags:0xfffedb08 mapping:00000000 mapcount:1 count:-268393021
Trying to fix it up, but a reboot is needed
Backtrace:
BUG: unable to handle kernel paging request at virtual address f000a5c7
printing eip: c014d9b8 *pdpt = 0000000000004001 *pde = 0000000000000000
Oops: 0002 [#1] SMP
Modules linked in:

Pid: 0, comm: swapper Tainted: G    B   (2.6.24-g34984208-dirty #3)
EIP: 0060:[<c014d9b8>] EFLAGS: 00010016 CPU: 0
EIP is at free_hot_cold_page+0xe8/0x14b
EAX: c13ed018 EBX: c13ed000 ECX: 0000000c EDX: f000a5c3
ESI: 00000000 EDI: 00000246 EBP: 00000c00 ESP: c059bf24
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c059a000 task=c05443a0 task.ti=c059a000)
Stack: 00000000 c13ed000 00000fff 0001f680 00000001 c05b19cb c0686000 c05fa520
       0001f680 0001e590 0001f68c 00000001 00000000 00000000 00000000 00000020
       c05ae9dd c04d59e6 c059bf7c c059bf7c c05b2eca c04d59e6 c04d7a11 00008000
Call Trace:
 [<c05b19cb>] free_all_bootmem_core+0x115/0x1b1
 [<c05ae9dd>] mem_init+0x7f/0x368
 [<c05b2eca>] alloc_large_system_hash+0x226/0x251
 [<c05b3dfc>] inode_init_early+0x49/0x72
 [<c05a15ca>] start_kernel+0x281/0x30c
 [<c05a10e0>] unknown_bootoption+0x0/0x195
 =======================
Code: 75 7a 6b f7 14 64 a1 08 40 5e c0 03 74 85 28 9c 5f fa 64 8b 15
10 61 5e c0 b8 40 74 5e c0 ff 44 02 20 8b 56 0c 8d 43 18 8d 4e 0c <89>
42 04 89 53 18 89 48 04 89 46 0c 31 c0 83 3d 98 83 59 c0 00
EIP: [<c014d9b8>] free_hot_cold_page+0xe8/0x14b SS:ESP 0068:c059bf24
---[ end trace ca143223eefdc828 ]---
Kernel panic - not syncing: Attempted to kill the idle task!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
