Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F67C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EC86216F4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:20:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="YTEoLGpt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EC86216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFFDB6B0008; Fri, 17 May 2019 10:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A891F6B000A; Fri, 17 May 2019 10:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DFA96B000C; Fri, 17 May 2019 10:20:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDC26B0008
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:20:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e21so10911398edr.18
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:20:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=VP/eUKUuR8TLoMvlYCX2nSbX4hUIzlmOciIWsva7XC4=;
        b=eUtLijlnwYuqe5M+DEMBvVSQB+Z59wNJjLLdO99yNfKZcH5mUGnGumHI4K/aNAYcsh
         8YgkjDMZZHQofvvyiWSFL8GprHJdZgEGfb+SatIAe42j2S4QRvP4OCE9oRjzC8LjxgWh
         1w/5IcDPLwxG2ksH1RFcLZ5F0mwnswjwbKiEVVehJYhdBbXqBjAM2VhWUcNuR5jK/29I
         aDnoq/YsjK5IfS5xQTgRfp4zKBS3HcBw0xav/TuYQnnMV2OpCcYwIO30Egv9DFwtRO5+
         vx30MesLSgAaRI/oHGnT87kSlaINlPmyDK8rCtPHFoDXhp8Vm8VP/1ScfFZv0pBKHECj
         6SFw==
X-Gm-Message-State: APjAAAVDVlIUcmBT/LioLJ0YGCC6S2tGyybPjswYlkvToT6c4IG9L+7k
	KSih0tU7WsiU6haQiDF1p9Muujnn+ASbcHUxQAsoFvJiRs7oP1Cjk740DztXy/UXRf6f6RN3GQv
	w2CEOfVLoCdTRFsDaw5QPGlsy52NFCZMm0m05habO43Ngovse2GqV3gqrYqah4Zq6ug==
X-Received: by 2002:a50:87ee:: with SMTP id 43mr58720585edz.238.1558102853430;
        Fri, 17 May 2019 07:20:53 -0700 (PDT)
X-Received: by 2002:a50:87ee:: with SMTP id 43mr58720350edz.238.1558102851299;
        Fri, 17 May 2019 07:20:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558102851; cv=none;
        d=google.com; s=arc-20160816;
        b=wo+t7waGkuuX8UIzOvUEu5o0G3Xqlp4HUo/9OeBUZMqfqaayoLJvm+zZMHGKifeLFE
         1Kg6XaPuWKPZRdYw5brFZPYeFIpkWlJVX/HyfCz4xmB5glqa3whVdDGsZVmDzU9U+KWa
         51QFoMyvRhgcW0KSsfcGgdtxuY4N2G0EFBZt3yl7irRjTzxezLZoGBPPWCqtvAmPYjZ2
         SCb+81E25Unepdx4KgHoeMP3uOcdqmt5upsHqbj+eHJE3N3nJ+NpUYL9g+1FMHol6im+
         wo+Ralv19FkOaj3f6JIpu+7SRiAv6yKYvu5PqDaTb/Gr5fak5OwpSejlIZpxPY7LEtbf
         vrRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=VP/eUKUuR8TLoMvlYCX2nSbX4hUIzlmOciIWsva7XC4=;
        b=gGcjF7qIqEKn+RZ6yZtXJAOGw+W73iN4EliEShbTOzeZD48uWz6k4PtyZJlQmr4l2g
         VbrX1WEHwkq5QbkS2v5rReSwUAmiGVz7smdGz0K6wm3l/NQ/V5S/L7NxeNV9+H7eu5i7
         13jzzu2GOjttsm5Y0Q+49H1QWoF4JKodEiF/jHc9mwiMH1h8IwJBITYXDit1z7VYjnWI
         b/+17TbiufMBF6Miv6541SHjbAFfKa2h2NKPGN6aSUPGry6FGCDikqc6JUk9XAiiHtHW
         nL125HX2+YFYOvRqySy9zBJEs+LtMjPMthOGGLFa/EN2CKBfkkIzUCfoYTDUnAqzeavF
         h/VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=YTEoLGpt;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m52sor7946855edc.21.2019.05.17.07.20.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 07:20:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=YTEoLGpt;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:from:date:message-id:subject:to;
        bh=VP/eUKUuR8TLoMvlYCX2nSbX4hUIzlmOciIWsva7XC4=;
        b=YTEoLGpt3gJPpHqgPs16i1Ei3RCbZf4C8pAQyiN4tBjMhme88ezguBEaoeZnfo5FWR
         sQwLdt1Is+kzXygN84M39ZWlLh47iKBEIRClO7oef6hlgFzdEfao5LU0LnhhLgHiokz8
         2z5676sE0ghFYREKmrC340/1CSoXSlYdvtdXGqyxqh9/efcGlFFeRPv4kC9KfzAJKMYT
         +WcKD+khWbY89mkXhA7FL0j12Xs03yYBWqpZaYfd26mfew7QLpZajHBw5Umzoi7vcLyJ
         FlyOWtWrbEVxDoSb5RXGF+k1mA/dw2mg+2H0n7uJgkcvTCZWXifP5o0S4YIKBeYaKL4Y
         4m6Q==
X-Google-Smtp-Source: APXvYqyBFCC2pD/8hnX5yHyYTnSwQ9dcl5Qi9Cn99mPL58e9GnCtNGgU1KalPEEF0oyxGvvSM0Jwxiz23Sgycf843Tw=
X-Received: by 2002:a50:ce5b:: with SMTP id k27mr5654685edj.48.1558102850640;
 Fri, 17 May 2019 07:20:50 -0700 (PDT)
MIME-Version: 1.0
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 17 May 2019 10:20:38 -0400
Message-ID: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
Subject: NULL pointer dereference during memory hotremove
To: "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, 
	"Jiang, Dave" <dave.jiang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, 
	"Busch, Keith" <keith.busch@intel.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Content-Type: multipart/mixed; boundary="000000000000efcea00589161685"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000efcea00589161685
Content-Type: text/plain; charset="UTF-8"

This panic is unrelated to circular lock issue that I reported in a
separate thread, that also happens during memory hotremove.

xakep ~/x/linux$ git describe
v5.1-12317-ga6a4b66bd8f4

Config is attached, qemu script is following:

qemu-system-x86_64                                                      \
        -enable-kvm                                                     \
        -cpu host                                                       \
        -parallel none                                                  \
        -echr 1                                                         \
        -serial none                                                    \
        -chardev stdio,id=console,signal=off,mux=on                     \
        -serial chardev:console                                         \
        -mon chardev=console                                            \
        -vga none                                                       \
        -display none                                                   \
        -kernel pmem/native/arch/x86/boot/bzImage                       \
        -m 8G,slots=1,maxmem=16G                                        \
        -smp 8                                                          \
        -fsdev local,id=virtfs1,path=/,security_model=none              \
        -device virtio-9p-pci,fsdev=virtfs1,mount_tag=hostfs            \
        -append 'earlyprintk=serial,ttyS0,115200 console=ttyS0
TERM=xterm ip=dhcp memmap=2G!6G loglevel=7'

The unusual case with this script is that 2G reserved for pmem device:
memmap=2G!6G. Otherwise, it is a normal layout. Unfortunately, it does
not happen every time, but I have hit it a couple times.


# QEMU 4.0.0 monitor - type 'help' for more information
(qemu) object_add memory-backend-ram,id=mem1,size=1G
(qemu) device_add pc-dimm,id=dimm1,memdev=mem1
# echo online_movable > /sys/devices/system/memory/memory79/state
[   40.219090] Built 1 zonelists, mobility grouping on.  Total pages: 1529279
[   40.223258] Policy zone: Normal
# (qemu) device_del dimm1
(qemu) [   49.624600] Offlined Pages 32768
[   49.625796] Built 1 zonelists, mobility grouping on.  Total pages: 1516352
[   49.627841] Policy zone: Normal
[   49.630932] BUG: kernel NULL pointer dereference, address: 0000000000000698
[   49.633704] #PF: supervisor read access in kernel mode
[   49.635689] #PF: error_code(0x0000) - not-present page
[   49.637620] PGD 8000000236b59067 P4D 8000000236b59067 PUD 2358fe067 PMD 0
[   49.640163] Oops: 0000 [#1] SMP PTI
[   49.641223] CPU: 0 PID: 7 Comm: kworker/u16:0 Not tainted 5.1.0_pt_pmem #38
[   49.643183] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.12.0-20181126_142135-anatol 04/01/2014
[   49.645858] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[   49.647101] RIP: 0010:__remove_pages+0x1a/0x460
[   49.648165] Code: e9 bb a9 fd ff 0f 0b 66 0f 1f 84 00 00 00 00 00
41 57 48 89 f8 49 89 ff 41 56 49 89 f6 41 55 41 54 55 53 48 89 d3 48
83 ec 50 <48> 2b 47 58 48 89 4c 24 48 48 3d 00 19 00 00 75 09 48 85 c9
0f 85
[   49.651925] RSP: 0018:ffffbd1000c8fcb8 EFLAGS: 00010286
[   49.652857] RAX: 0000000000000640 RBX: 0000000000040000 RCX: 0000000000000000
[   49.654139] RDX: 0000000000040000 RSI: 0000000000240000 RDI: 0000000000000640
[   49.655393] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000040000000
[   49.656523] R10: 0000000040000000 R11: 0000000240000000 R12: 0000000040000000
[   49.657654] R13: 0000000240000000 R14: 0000000000240000 R15: 0000000000000640
[   49.658828] FS:  0000000000000000(0000) GS:ffff9b4bf9800000(0000)
knlGS:0000000000000000
[   49.660178] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   49.661033] CR2: 0000000000000698 CR3: 00000002382e0006 CR4: 0000000000360ef0
[   49.662114] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   49.663172] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   49.664243] Call Trace:
[   49.664622]  ? memblock_isolate_range+0xc4/0x139
[   49.665290]  ? firmware_map_add_hotplug+0x7e/0xde
[   49.665908]  ? memblock_remove_region+0x30/0x74
[   49.666498]  arch_remove_memory+0x6f/0xa0
[   49.667012]  __remove_memory+0xab/0x130
[   49.667492]  ? walk_memory_range+0xa1/0xe0
[   49.668008]  acpi_memory_device_remove+0x67/0xe0
[   49.668595]  acpi_bus_trim+0x50/0x90
[   49.669051]  acpi_device_hotplug+0x2fa/0x3e0
[   49.669590]  acpi_hotplug_work_fn+0x15/0x20
[   49.670116]  process_one_work+0x2a0/0x650
[   49.670577]  worker_thread+0x34/0x3d0
[   49.670997]  ? process_one_work+0x650/0x650
[   49.671503]  kthread+0x118/0x130
[   49.671879]  ? kthread_create_on_node+0x60/0x60
[   49.672411]  ret_from_fork+0x3a/0x50
[   49.672836] Modules linked in:
[   49.673190] CR2: 0000000000000698
[   49.673583] ---[ end trace 6b727d3a8ce48aa1 ]---
[   49.674120] RIP: 0010:__remove_pages+0x1a/0x460
[   49.674624] Code: e9 bb a9 fd ff 0f 0b 66 0f 1f 84 00 00 00 00 00
41 57 48 89 f8 49 89 ff 41 56 49 89 f6 41 55 41 54 55 53 48 89 d3 48
83 ec 50 <48> 2b 47 58 48 89 4c 24 48 48 3d 00 19 00 00 75 09 48 85 c9
0f 85
[   49.676600] RSP: 0018:ffffbd1000c8fcb8 EFLAGS: 00010286
[   49.677159] RAX: 0000000000000640 RBX: 0000000000040000 RCX: 0000000000000000
[   49.677960] RDX: 0000000000040000 RSI: 0000000000240000 RDI: 0000000000000640
[   49.678813] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000040000000
[   49.679633] R10: 0000000040000000 R11: 0000000240000000 R12: 0000000040000000
[   49.680455] R13: 0000000240000000 R14: 0000000000240000 R15: 0000000000000640
[   49.681243] FS:  0000000000000000(0000) GS:ffff9b4bf9800000(0000)
knlGS:0000000000000000
[   49.682168] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   49.682813] CR2: 0000000000000698 CR3: 00000002382e0006 CR4: 0000000000360ef0
[   49.683573] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   49.684239] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   49.684901] BUG: sleeping function called from invalid context at
include/linux/percpu-rwsem.h:34
[   49.685690] in_atomic(): 0, irqs_disabled(): 1, pid: 7, name: kworker/u16:0
[   49.686314] INFO: lockdep is turned off.
[   49.686684] irq event stamp: 22546
[   49.687003] hardirqs last  enabled at (22545): [<ffffffff8c1fe5ba>]
kfree+0xba/0x230
[   49.687692] hardirqs last disabled at (22546): [<ffffffff8c001b53>]
trace_hardirqs_off_thunk+0x1a/0x1c
[   49.688561] softirqs last  enabled at (22526): [<ffffffff8ce0033e>]
__do_softirq+0x33e/0x455
[   49.689348] softirqs last disabled at (22519): [<ffffffff8c06ea36>]
irq_exit+0xb6/0xc0
[   49.690088] CPU: 0 PID: 7 Comm: kworker/u16:0 Tainted: G      D
      5.1.0_pt_pmem #38
[   49.690811] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.12.0-20181126_142135-anatol 04/01/2014
[   49.691704] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[   49.692185] Call Trace:
[   49.692398]  dump_stack+0x67/0x90
[   49.692690]  ___might_sleep.cold.87+0x9f/0xaf
[   49.693099]  exit_signals+0x2b/0x240
[   49.693453]  do_exit+0xab/0xc10
[   49.693770]  ? process_one_work+0x650/0x650
[   49.694160]  ? kthread+0x118/0x130
[   49.694487]  rewind_stack_do_exit+0x17/0x20
[   77.418619] random: fast init done

--000000000000efcea00589161685
Content-Type: application/x-bzip; name="x86.config.bz2"
Content-Disposition: attachment; filename="x86.config.bz2"
Content-Transfer-Encoding: base64
Content-ID: <f_jvs5zabs0>
X-Attachment-Id: f_jvs5zabs0

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
4fPN29Q8IPr//F3JFOFCQDq2o1A=
--000000000000efcea00589161685--

