Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 406726B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 02:13:41 -0500 (EST)
Date: Wed, 26 Dec 2012 08:13:38 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [3.8-rc1+] BUG: unable to handle kernel NULL pointer
 dereference, wait_iff_congested+0x45/0xdd
Message-ID: <20121226071338.GA11555@liondog.tnic>
References: <27934635.301401356500288241.JavaMail.weblogic@epml05>
 <CAHdPZaMGtDGW-yBULuTkJxMSUXLZRQd22S-bsFG-jqR+5LyB6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHdPZaMGtDGW-yBULuTkJxMSUXLZRQd22S-bsFG-jqR+5LyB6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "devendra.aaru" <devendra.aaru@gmail.com>
Cc: jongman.heo@samsung.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

+ linux-mm.

There's that kswapd deal again.

On Wed, Dec 26, 2012 at 11:12:45AM +0530, devendra.aaru wrote:
> Hello,
> 
> On Wed, Dec 26, 2012 at 11:08 AM, Jongman Heo <jongman.heo@samsung.com> wrote:
> >
> > Hi,
> >
> > During SVN checkout (means heavy I/O), I hit this kernel BUG with current linus git (637704cb : Merge branch 'i2c-embedded/for-next'), in my VMWare Linux guest.
> >
> i can too with the make -j144 on kernel source code, attached the .config.
> 
> > [ 9141.015123] BUG: unable to handle kernel NULL pointer dereference at 00000280
> > [ 9141.017870] IP: [<c04ba69c>] wait_iff_congested+0x45/0xdd
> > [ 9141.034799] *pde = 00000000
> > [ 9141.034803] Oops: 0000 [#1] SMP
> > [ 9141.044282] Modules linked in: vmwgfx ttm drm
> > [ 9141.044331] Pid: 42, comm: kswapd0 Not tainted 3.8.0-rc1+ #120 VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform
> > [ 9141.044334] EIP: 0060:[<c04ba69c>] EFLAGS: 00010202 CPU: 3
> > [ 9141.044342] EIP is at wait_iff_congested+0x45/0xdd
> > [ 9141.044343] EAX: 00000001 EBX: 00000000 ECX: 00000000 EDX: 00000000
> > [ 9141.044345] ESI: 0000001e EDI: f633fec0 EBP: f633fecc ESP: f633fea8
> > [ 9141.044347]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > [ 9141.044348] CR0: 8005003b CR2: 00000280 CR3: 33ab7000 CR4: 000007d0
> > [ 9141.045817] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> > [ 9141.045834] DR6: ffff0ff0 DR7: 00000400
> > [ 9141.045836] Process kswapd0 (pid: 42, ti=f633e000 task=f6331920 task.ti=f633e000)
> > [ 9141.045838] Stack:
> > [ 9141.045839]  002889e6 00000000 f6331920 c04462a2 f633feb8 f633feb8 c0beba54 c0bead00
> > [ 9141.045844]  00000003 f633ff68 c04b3ffb 00000002 00000000 000086d1 f6331920 f633ff58
> > [ 9141.045849]  00000000 f6331920 00037b92 00000000 00000045 00000000 00000038 00000001
> > [ 9141.045854] Call Trace:
> > [ 9141.045934]  [<c04462a2>] ? remove_wait_queue+0x27/0x27
> > [ 9141.045939]  [<c04b3ffb>] kswapd+0x5ef/0x705
> > [ 9141.045942]  [<c04462a2>] ? remove_wait_queue+0x27/0x27
> > [ 9141.045945]  [<c0445cbc>] kthread+0x6b/0x70
> > [ 9141.045947]  [<c04b3a0c>] ? shrink_lruvec+0x492/0x492
> > [ 9141.083149]  [<c0907637>] ret_from_kernel_thread+0x1b/0x28
> > [ 9141.083166]  [<c0445c51>] ? kthread_freezable_should_stop+0x36/0x36
> > [ 9141.083169] Code: 89 45 dc 31 c0 f3 ab 64 a1 58 66 c7 c0 89 45 e4 8d 45 ec 89 45 ec 89 45 f0 8b 04 95 24 2b cf c0 c7 45 e8 a2 62 44 c0 85 c0 74 0a <8b> 83 80 02 00 00 a8 04 75 1b e8 e9 6f 44 00 a1 40 9a b8 c0 8b
> > [ 9141.089753] EIP: [<c04ba69c>] wait_iff_congested+0x45/0xdd SS:ESP 0068:f633fea8
> > [ 9141.089764] CR2: 0000000000000280
> > [ 9141.090296] ---[ end trace 58a34900f079b57e ]---



-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
