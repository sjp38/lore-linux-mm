Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 807246B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 01:44:32 -0500 (EST)
Date: Tue, 15 Jan 2013 07:44:27 +0100
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [next-20130114] Call-trace in LTP (lite) madvise02 test
 (block|mm|vfs related?)
Message-ID: <20130115064427.GB30331@kernel.dk>
References: <CA+icZUW1+BzWCfGkbBiekKO8b6KiyAiyXWAHFmVUey2dHnSTzw@mail.gmail.com>
 <50F454C2.6000509@kernel.dk>
 <CA+icZUX_uKSzvdhd4tMtgb+vUxqC=fS7tfSHhs29+xD_XQQjBQ@mail.gmail.com>
 <CA+icZUV_dz2Bvu6o=YRFu6324ccVr1MaOEpRcw0rguppR5rQQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUV_dz2Bvu6o=YRFu6324ccVr1MaOEpRcw0rguppR5rQQg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: linux-next <linux-next@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Jan 14 2013, Sedat Dilek wrote:
> On Mon, Jan 14, 2013 at 8:28 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> > On Mon, Jan 14, 2013 at 7:56 PM, Jens Axboe <axboe@kernel.dk> wrote:
> >> On 2013-01-14 19:33, Sedat Dilek wrote:
> >>> Hi,
> >>>
> >>> while running LTP lite on my next-20130114 kernel I hit this
> >>> call-trace (file attached).
> >>>
> >>> Looks to me like problem in the block layer, but not sure.
> >>> Might one of the experts have look at it?
> >>
> >> Really? 600kb of data to look through? Can't you just paste the actual
> >> error, I can't even find it...
> >>
> >
> > $ cat call-trace_ltplite_madvise02_next-20130114.txt
> > Jan 14 17:47:14 fambox kernel: [ 1263.965957] ------------[ cut here
> > ]------------
> > Jan 14 17:47:14 fambox kernel: [ 1263.965989] Kernel BUG at
> > ffffffff81328b2b [verbose debug info unavailable]
> > Jan 14 17:47:14 fambox kernel: [ 1263.966022] invalid opcode: 0000 [#1] SMP
> > Jan 14 17:47:14 fambox kernel: [ 1263.966046] Modules linked in:
> > snd_hda_codec_hdmi snd_hda_codec_realtek joydev coretemp kvm_intel kvm
> > snd_hda_intel snd_hda_codec arc4 iwldvm snd_hwdep snd_pcm
> > ghash_clmulni_intel mac80211 aesni_intel i915 snd_page_alloc xts
> > snd_seq_midi aes_x86_64 snd_seq_midi_event uvcvideo lrw gf128mul
> > iwlwifi snd_rawmidi ablk_helper snd_seq i2c_algo_bit cryptd
> > drm_kms_helper snd_timer videobuf2_vmalloc drm snd_seq_device
> > videobuf2_memops psmouse parport_pc snd cfg80211 btusb rfcomm
> > videobuf2_core bnep microcode ppdev soundcore videodev samsung_laptop
> > wmi lp bluetooth serio_raw mei mac_hid hid_generic video lpc_ich
> > parport usbhid hid r8169
> > Jan 14 17:47:14 fambox kernel: [ 1263.966377] CPU 3
> > Jan 14 17:47:14 fambox kernel: [ 1263.966388] Pid: 7803, comm:
> > madvise02 Not tainted 3.8.0-rc3-next20130114-5-iniza-generic #1
> > SAMSUNG ELECTRONICS CO., LTD.
> > 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH
> > Jan 14 17:47:14 fambox kernel: [ 1263.966450] RIP:
> > 0010:[<ffffffff81328b2b>]  [<ffffffff81328b2b>]
> > blk_flush_plug_list+0x1eb/0x210
> > Jan 14 17:47:14 fambox kernel: [ 1263.966508] RSP:
> > 0018:ffff88000d933e58  EFLAGS: 00010287
> > Jan 14 17:47:14 fambox kernel: [ 1263.966532] RAX: 0000000091827364
> > RBX: ffff88000d933e68 RCX: 0000000000000000
> > Jan 14 17:47:14 fambox kernel: [ 1263.966566] RDX: 0000000000000000
> > RSI: 0000000000000000 RDI: ffff88000d933f10
> > Jan 14 17:47:14 fambox kernel: [ 1263.966614] RBP: ffff88000d933eb8
> > R08: 0000000000000003 R09: 0000000000000000
> > Jan 14 17:47:14 fambox kernel: [ 1263.966656] R10: 00007fff3d62c9b0
> > R11: 0000000000000206 R12: 0000000000000000
> > Jan 14 17:47:14 fambox kernel: [ 1263.966696] R13: 0000000000001000
> > R14: ffff88000d933f10 R15: ffff88000d933f10
> > Jan 14 17:47:14 fambox kernel: [ 1263.966736] FS:
> > 00007f56bcbc2700(0000) GS:ffff88011fac0000(0000)
> > knlGS:0000000000000000
> > Jan 14 17:47:14 fambox kernel: [ 1263.966780] CS:  0010 DS: 0000 ES:
> > 0000 CR0: 0000000080050033
> > Jan 14 17:47:14 fambox kernel: [ 1263.966813] CR2: 00007f56bc6ec060
> > CR3: 000000000bf66000 CR4: 00000000000407e0
> > Jan 14 17:47:14 fambox kernel: [ 1263.966848] DR0: 0000000000000000
> > DR1: 0000000000000000 DR2: 0000000000000000
> > Jan 14 17:47:14 fambox kernel: [ 1263.966885] DR3: 0000000000000000
> > DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Jan 14 17:47:14 fambox kernel: [ 1263.966921] Process madvise02 (pid:
> > 7803, threadinfo ffff88000d932000, task ffff88000d9f2e40)
> > Jan 14 17:47:14 fambox kernel: [ 1263.966963] Stack:
> > Jan 14 17:47:14 fambox kernel: [ 1263.966978]  0000000000000001
> > 0000000000000001 ffff88000d933e68 ffff88000d933e68
> > Jan 14 17:47:14 fambox kernel: [ 1263.967024]  ffff88000d933ef8
> > ffffffff8114b77c ffff88000d933ec0 ffff88000d933f10
> > Jan 14 17:47:14 fambox kernel: [ 1263.967071]  0000000000000000
> > 0000000000001000 0000000000010000 ffff88000d933f10
> > Jan 14 17:47:14 fambox kernel: [ 1263.967118] Call Trace:
> > Jan 14 17:47:14 fambox kernel: [ 1263.967137]  [<ffffffff8114b77c>] ?
> > vm_mmap_pgoff+0xbc/0xe0
> > Jan 14 17:47:14 fambox kernel: [ 1263.967173]  [<ffffffff81328b68>]
> > blk_finish_plug+0x18/0x50
> > Jan 14 17:47:14 fambox kernel: [ 1263.967209]  [<ffffffff811544d8>]
> > sys_madvise+0xc8/0x3a0
> > Jan 14 17:47:14 fambox kernel: [ 1263.967247]  [<ffffffff816ba0e9>] ?
> > do_page_fault+0x39/0x50
> > Jan 14 17:47:14 fambox kernel: [ 1263.967288]  [<ffffffff816be79d>]
> > system_call_fastpath+0x1a/0x1f
> > Jan 14 17:47:14 fambox kernel: [ 1263.967331] Code: 4d 85 ff 74 0d 44
> > 89 e2 89 c6 4c 89 ff e8 be b5 ff ff 4c 89 ef 57 9d 66 66 90 66 90 48
> > 83 c4 38 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> 0b 31 d2 be ed ff ff ff
> > 4c 89 f7 89 45 a8 e8 91 f9 ff ff 8b
> > Jan 14 17:47:14 fambox kernel: [ 1263.967589] RIP
> > [<ffffffff81328b2b>] blk_flush_plug_list+0x1eb/0x210
> > Jan 14 17:47:14 fambox kernel: [ 1263.967630]  RSP <ffff88000d933e58>
> > Jan 14 17:47:14 fambox kernel: [ 1263.989553] ---[ end trace
> > 19e1575014ab42a7 ]---
> >
> 
> Looks like this is the fix from Sasha [1].
> Culprit commit is [2].
> Testing...
> 
> - Sedat -
> 
> [1] https://patchwork.kernel.org/patch/1973481/
> [2] http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=0d18d770b9180ffc2c3f63b9eb8406ef80105e05

It does indeed, let us know if it doesn't fix it.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
