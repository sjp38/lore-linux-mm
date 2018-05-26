Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB186B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 03:14:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j75-v6so3906105oib.5
        for <linux-mm@kvack.org>; Sat, 26 May 2018 00:14:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 9-v6sor13575018otd.131.2018.05.26.00.14.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 00:14:56 -0700 (PDT)
MIME-Version: 1.0
From: Mathieu Malaterre <malat@debian.org>
Date: Sat, 26 May 2018 09:14:35 +0200
Message-ID: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
Subject: WARNING: CPU: 0 PID: 21 at ../mm/page_alloc.c:4258 __alloc_pages_nodemask+0xa88/0xfec
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org

Hi Michal,

For the last couple of days, I am seeing the following appearing in
dmesg (*). I am a happy kmemleak user on an oldish Mac Mini G4
(ppc32), it has been working great. What does this new warning checks:

    /*
     * All existing users of the __GFP_NOFAIL are blockable, so warn
     * of any new users that actually require GFP_NOWAIT
     */
    if (WARN_ON_ONCE(!can_direct_reclaim))
      goto fail;

Thanks,

(*)
[  269.038911] WARNING: CPU: 0 PID: 21 at ../mm/page_alloc.c:4258
__alloc_pages_nodemask+0xa88/0xfec
[  269.038931] Modules linked in: ctr ccm uinput arc4 b43 bcma
mac80211 sha256_generic snd_aoa_codec_toonie cfg80211
snd_aoa_fabric_layout snd_aoa snd_aoa_i2sbus snd_aoa_soundbus snd_pcm
evdev snd_timer snd sg ssb soundcore usb_storage autofs4 ext4
crc32c_generic crc16 mbcache jbd2 fscrypto usbhid ohci_pci ohci_hcd
ehci_pci ehci_hcd usbcore firewire_ohci sd_mod sr_mod cdrom
firewire_core sungem sungem_phy crc_itu_t nls_base usb_common
[  269.039026] CPU: 0 PID: 21 Comm: kswapd0 Tainted: G        W
 4.17.0-rc6+ #18
[  269.039032] NIP:  c020e8f8 LR: c020e2e0 CTR: c020b514
[  269.039038] REGS: dde3b6a0 TRAP: 0700   Tainted: G        W
 (4.17.0-rc6+)
[  269.039042] MSR:  00021032 <ME,IR,DR,RI>  CR: 22224484  XER: 00000000
[  269.039056]
               GPR00: c020e2e0 dde3b750 df6ab480 00000000 00000001
00000000 00000004 00000040
               GPR08: 00000800 22224484 00000040 01ffffff 42224482
00000000 00000040 01011a00
               GPR16: c0a864bc 00000040 c0c5a730 01011a00 c0c2f5cc
00000000 00000000 c0c318c4
               GPR24: c0c6ba20 00000001 c0a84158 01011a00 c0ce065c
c0a84158 00000000 00000000
[  269.039118] NIP [c020e8f8] __alloc_pages_nodemask+0xa88/0xfec
[  269.039124] LR [c020e2e0] __alloc_pages_nodemask+0x470/0xfec
[  269.039128] Call Trace:
[  269.039136] [dde3b750] [c020e2e0]
__alloc_pages_nodemask+0x470/0xfec (unreliable)
[  269.039146] [dde3b820] [c0288c14] new_slab+0x53c/0x970
[  269.039155] [dde3b880] [c028b61c] ___slab_alloc.constprop.23+0x28c/0x468
[  269.039163] [dde3b920] [c028c754] kmem_cache_alloc+0x290/0x3dc
[  269.039177] [dde3b990] [c02a6030] create_object+0x50/0x3d0
[  269.039185] [dde3b9e0] [c028c7a8] kmem_cache_alloc+0x2e4/0x3dc
[  269.039193] [dde3ba50] [c0200f88] mempool_alloc+0x7c/0x164
[  269.039205] [dde3bab0] [c03e33c0] bio_alloc_bioset+0x130/0x298
[  269.039216] [dde3baf0] [c0278694] get_swap_bio+0x34/0xe8
[  269.039223] [dde3bb30] [c0278fb4] __swap_writepage+0x22c/0x644
[  269.039237] [dde3bbb0] [c022528c] pageout.isra.13+0x238/0x52c
[  269.039246] [dde3bc10] [c02288a0] shrink_page_list+0x9d4/0x1768
[  269.039254] [dde3bcb0] [c022a264] shrink_inactive_list+0x2c4/0xa34
[  269.039262] [dde3bd40] [c022b454] shrink_node_memcg+0x344/0xe34
[  269.039270] [dde3bde0] [c022c068] shrink_node+0x124/0x73c
[  269.039277] [dde3be50] [c022d78c] kswapd+0x318/0xb2c
[  269.039291] [dde3bf10] [c008e264] kthread+0x138/0x1f0
[  269.039300] [dde3bf40] [c001b2e4] ret_from_kernel_thread+0x5c/0x64
[  269.039304] Instruction dump:
[  269.039311] 7f44d378 7fa3eb78 4802bd95 4bfff9f4 485d7309 4bfff998
7f03c378 7fc5f378
[  269.039326] 7f44d378 4802bd79 7c781b78 4bfffd48 <0fe00000> 8081002c
3ca0c08b 7fe6fb78
[  269.039343] ---[ end trace c255e24f03e28d77 ]---
[  269.039351] kmemleak: Cannot allocate a kmemleak_object structure
[  269.039373] kmemleak: Kernel memory leak detector disabled
[  269.039412] kmemleak: Automatic memory scanning thread ended
