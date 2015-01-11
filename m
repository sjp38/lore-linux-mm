Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 78DCF6B007B
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 05:50:20 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id hs14so20368768lab.8
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 02:50:19 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id lu3si18417308lac.6.2015.01.11.02.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 02:50:19 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so13926358lbv.0
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 02:50:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54B117C9.5080805@winsoft.pl>
References: <54B117C9.5080805@winsoft.pl>
Date: Sun, 11 Jan 2015 14:50:18 +0400
Message-ID: <CALYGNiOm4-jSUBM=mVB6KJJD3YYwU52WK1T408kyj8ujW2dABw@mail.gmail.com>
Subject: Re: probably commit b3d574ae ( Linus github 10-01-2015) causes oops
 after run Android SDK Manager from Eclipse
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kolasa <kkolasa@winsoft.pl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

More likely that was me. Please see this thread:
lkml.kernel.org/r/CALYGNiOpw75TJhXX5czdkEsver0HVf+oGX3d8qVKNPRNLygUpQ@mail.gmail.com

On Sat, Jan 10, 2015 at 3:15 PM, Krzysztof Kolasa <kkolasa@winsoft.pl> wrote:
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320920] ------------[ cut here
> ]------------
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320927] Kernel BUG at
> ffffffff81187f1f [verbose debug info unavailable]
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320929] invalid opcode: 0000
> [#3] SMP
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320932] Modules linked in:
> dm_crypt(E) pci_stub(E) vboxpci(OE) vboxnetadp(OE) vboxnetflt(OE)
> vboxdrv(OE) c
> use(E) arc4(E) md4(E) bnep(E) rfcomm(E) bluetooth(E) nls_utf8(E) cifs(E)
> fscache(E) binfmt_misc(E) fglrx(OE) uvcvideo(E) videobuf2_vmalloc(E)
> x86_pkg_
> temp_thermal(E) videobuf2_memops(E) videobuf2_core(E) hp_wmi(E)
> v4l2_common(E) wl(POE) kvm_intel(E) sparse_keymap(E) videodev(E) kvm(E)
> ghash_clmulni_
> intel(E) aesni_intel(E) aes_x86_64(E) lrw(E) gf128mul(E)
> snd_hda_codec_idt(E) snd_hda_codec_hdmi(E) snd_hda_codec_generic(E)
> glue_helper(E) ablk_helpe
> r(E) snd_hda_intel(E) cryptd(E) snd_hda_controller(E) snd_hda_codec(E)
> snd_hwdep(E) snd_pcm(E) snd_seq_midi(E) snd_seq_midi_event(E) microcode(E)
> snd_
> rawmidi(E) snd_seq(E) snd_seq_device(E) snd_timer(E) snd(E) cfg80211(E)
> soundcore(E) joydev(E) lpc_ich(E) hp_accel(E) wmi(E) serio_raw(E)
> tpm_infineon
> (E) lis3lv02d(E) amd_iommu_v2(E) input_polldev(E) video(E) tpm_tis(E)
> mac_hid(E) parport_pc(E) ppdev(E) coretemp(E) lp(E) parport(E)
> hid_generic(E) us
> bhid(E) hid(E) mmc_block(E) psmouse(E) firewire_ohci(E) ahci(E) libahci(E)
> sdhci_pci(E) e1000e(E) firewire_core(E) sdhci(E) crc_itu_t(E) ptp(E) pps_co
> re(E)
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320979] CPU: 1 PID: 6871 Comm:
> Sweeper thread Tainted: P      D    OE 3.19.0-rc3-winsoft-x64+ #10
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320981] Hardware name:
> Hewlett-Packard HP ProBook 6560b/1619, BIOS 68SCE Ver. F.50 08/04/2014
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320983] task: ffff88005d95b1c0
> ti: ffff88018ee18000 task.ti: ffff88018ee18000
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320985] RIP:
> 0010:[<ffffffff81187f1f>]  [<ffffffff81187f1f>] unlink_anon_vmas+0x1af/0x200
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320993] RSP:
> 0018:ffff88018ee1bba8  EFLAGS: 00010286
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320994] RAX: ffff880182a47c50
> RBX: ffff880182a47c40 RCX: ffff8801b9e1d638
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320996] RDX: 00000000ffffffff
> RSI: ffff8801abb60630 RDI: ffff8801abb605f0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320998] RBP: ffff88018ee1bbe8
> R08: 00000000f70a2000 R09: 0000000000000000
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321000] R10: ffff880182a47c60
> R11: ffffea00060a91c0 R12: ffff8801b9e1d628
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321001] R13: ffff8801b9e1d638
> R14: ffff8801abb605f0 R15: ffff8801abb605f0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321003] FS:
> 0000000000000000(0000) GS:ffff88023f440000(0000) knlGS:0000000000000000
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321005] CS:  0010 DS: 002b ES:
> 002b CR0: 0000000080050033
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321007] CR2: 00000000f653e70c
> CR3: 0000000001c12000 CR4: 00000000000407e0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321008] Stack:
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321010] ffff8801b9e1d5c0
> ffff8801abb605f0 ffff88018ee1bbe8 ffff88006a1d70b8
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321013] 00000000a3255000
> 0000000000000000 ffff88018ee1bc58 ffff8801b9e1d5c0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321016] ffff88018ee1bc38
> ffffffff81179b58 ffff88018ee1bc38 0000000000000000
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321019] Call Trace:
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321025] [<ffffffff81179b58>]
> free_pgtables+0xa8/0x120
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321029] [<ffffffff81183e5f>]
> exit_mmap+0xdf/0x170
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321033] [<ffffffff81055984>]
> mmput+0x64/0x130
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321036] [<ffffffff8105ab2f>]
> do_exit+0x26f/0xb10
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321039] [<ffffffff8105b45f>]
> do_group_exit+0x3f/0xa0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321044] [<ffffffff81066d48>]
> get_signal+0x1d8/0x5f0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321047] [<ffffffff81002e10>]
> do_signal+0x20/0x120
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321052] [<ffffffff810d0d01>] ?
> compat_SyS_futex+0x71/0x140
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321055] [<ffffffff81002f80>]
> do_notify_resume+0x70/0xa0
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321059] [<ffffffff8171ebc7>]
> int_signal+0x12/0x17
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321061] Code: 44 24 10 48 8d 50
> f0 49 8d 44 24 10 49 39 c5 75 9b 48 83 c4 18 5b 41 5c 41 5d 41 5e 41 5f 5d
>  c3 0f 1f 40 00 e8 c3 fa ff ff eb 99 <0f> 0b 80 3d ea 8e b6 00 00 74 16 49
> 8d 7e 08 48 89 55 c8 e8 09
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321088] RIP [<ffffffff81187f1f>]
> unlink_anon_vmas+0x1af/0x200
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321091]  RSP <ffff88018ee1bba8>
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321094] ---[ end trace
> 1c9e464233c6be56 ]---
> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321096] Fixing recursive fault
> but reboot is needed!
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
