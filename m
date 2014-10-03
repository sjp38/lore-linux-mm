Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 49CDE6B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 01:49:31 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so2060445pdb.30
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 22:49:30 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id zl2si5993874pbb.28.2014.10.02.22.49.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 22:49:29 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so989986pab.20
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 22:49:29 -0700 (PDT)
Date: Thu, 2 Oct 2014 22:49:23 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2014-10-02-16-22 uploaded
Message-ID: <20141003054923.GA13328@roeck-us.net>
References: <542dde4c.uoQAbw1Ng2akSWKx%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <542dde4c.uoQAbw1Ng2akSWKx%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Thu, Oct 02, 2014 at 04:22:52PM -0700, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-10-02-16-22 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
Build summary:
	total: 133 pass: 127 fail: 6
Failed builds:
	arm:cm_x2xx_defconfig
	avr32:defconfig
	m68k:allmodconfig
	mn10300:asb2303_defconfig
	sparc64:allmodconfig
	um:defconfig

Qemu tests:
	total: 26 pass: 26 fail: 0

---
avr32:defconfig has a new build failure.

drivers/input/leds.o: In function `init_module':
leds.c:(.init.text+0x0): multiple definition of `init_module'
drivers/input/input.o:input.c:(.init.text+0x0): first defined here
drivers/input/leds.o: In function `cleanup_module':
leds.c:(.exit.text+0x0): multiple definition of `cleanup_module'
drivers/input/input.o:input.c:(.exit.text+0x0): first defined here
make[2]: *** [drivers/input/input-core.o] Error 1

---
powerpc qemu tests create a number of tracebacks, all similar to the following.

------------[ cut here ]------------
WARNING: at kernel/workqueue.c:1360
Modules linked in:
CPU: 0 PID: 32 Comm: kadbprobe Not tainted 3.17.0-rc7-mm1-yocto-standard+ #1
task: c79f29a0 ti: c7ac2000 task.ti: c7ac2000
NIP: c0045274 LR: c004533c CTR: c04af658
REGS: c7ac3ae0 TRAP: 0700   Not tainted  (3.17.0-rc7-mm1-yocto-standard+)
MSR: 00021032 <ME,IR,DR,RI>  CR: 82008082  XER: 00000000

GPR00: c004533c c7ac3b90 c79f29a0 00000001 00000000 c099c140 00000000 c0900000 
GPR08: 00000000 00000001 00000002 00000000 82008082 00000000 c004bdd8 c79d1a20 
GPR16: 00000000 00000000 00000000 00000003 00000000 c79daa5c 00000001 c08e89e4 
GPR24: c08e7fa4 00000000 c08f784c c7ac2000 c099c144 c781cc00 c0aab500 c099c140 
NIP [c0045274] __queue_work+0xf8/0x3e8
LR [c004533c] __queue_work+0x1c0/0x3e8
Call Trace:
[c7ac3b90] [c004533c] __queue_work+0x1c0/0x3e8 (unreliable)
[c7ac3bc0] [c00455cc] queue_work_on+0x68/0x88
[c7ac3bd0] [c05113dc] led_trigger_event+0x4c/0xa8
[c7ac3bf0] [c0434660] kbd_ledstate_trigger_activate+0x7c/0xa4
[c7ac3c00] [c0511594] led_trigger_set+0x15c/0x1dc
[c7ac3c30] [c0511840] led_trigger_set_default+0x90/0xd4
[c7ac3c50] [c0511004] led_classdev_register+0x108/0x12c
[c7ac3c60] [c04af8fc] input_led_connect+0xd4/0x250
[c7ac3ca0] [c04ac350] input_register_device+0x42c/0x4b4
[c7ac3cc0] [c045ecac] adbhid_input_register+0x4e0/0x62c
[c7ac3d00] [c045eea0] adbhid_input_reregister+0xa8/0xac
[c7ac3d20] [c045efdc] adbhid_probe+0x138/0x4fc
[c7ac3de0] [c045f860] adb_message_handler+0x30/0xec
[c7ac3e00] [c004ceb8] notifier_call_chain+0x78/0xc0
[c7ac3e20] [c004d424] __blocking_notifier_call_chain+0x5c/0x80
[c7ac3e40] [c0460eb0] do_adb_reset_bus+0x11c/0x3c4
[c7ac3ee0] [c0461180] adb_probe_task+0x28/0x58
[c7ac3ef0] [c004bea0] kthread+0xc8/0xdc
[c7ac3f40] [c00106fc] ret_from_kernel_thread+0x5c/0x64
Instruction dump:
419e019c 3f40c08f 3b5a784c 813a0018 2f890000 419d021c 813f0004 3b9f0004 
7f894a78 7d290034 5529d97e 69290001 <0f090000> 2f890000 409e008c 80be0008 
---[ end trace 76dca08f6b486638 ]---

---

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
