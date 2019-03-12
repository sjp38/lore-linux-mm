Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99CD1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45B58205C9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:55:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OLhnbQDK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45B58205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B66FB8E0003; Tue, 12 Mar 2019 13:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B16958E0002; Tue, 12 Mar 2019 13:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A06398E0003; Tue, 12 Mar 2019 13:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4928D8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:55:42 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t133so853696wmg.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=Wwv4OC/5UKkx+hi7JxDLNFBGMRfe7Oq9haS0eC+cjr8=;
        b=h+oKyRuvE7O77VpdovLqnZxTLDJcYfSfhse6Y9wz/UuvfGKNF3QjLiyFJvZFlwApHo
         9kWw/kfunNtvXY7K4BnGMcUbKjMseDKLI9QDSMjmxNtzoAh05FIQ8nykxkC8RNHpynC+
         WvV/i4t8THOwasr0058V/FPjnBr/aBrD0R6tUK3xVIsSNs/E4fppK77EkNkt+TAlNOAW
         u02lZ9Oi0zwpczwVUCK4oxo5ZjICmwA+S2sdIQlOkdQ81C337W7NUjXeZ9RRgh6dpN7+
         ktTmUA5qD5+OXduYzdTnR3+qBqIUbtF6JWrafZ/xlfnSB+DSZ58YQy6gUJE5GQV2MZLV
         G+6g==
X-Gm-Message-State: APjAAAVXJML2vrZU2kcJKu9kXArTxbGbA/8Gy+e/0mPXF3WjhNEidtmQ
	DnFjifrdk6G5Oi8qkN97ahhphRiURcW5G+2yLS3wyRokC3XJP19ZL+5dWrjMn10/rhi4A/+VG17
	FXmwxEVU+iciYgw/f2Mp5gkp2yqKteO+kiROmB/MycDOb91y6IIlieFAEOnQeYYiQIw==
X-Received: by 2002:a7b:c41a:: with SMTP id k26mr3525904wmi.6.1552413341411;
        Tue, 12 Mar 2019 10:55:41 -0700 (PDT)
X-Received: by 2002:a7b:c41a:: with SMTP id k26mr3525832wmi.6.1552413339836;
        Tue, 12 Mar 2019 10:55:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552413339; cv=none;
        d=google.com; s=arc-20160816;
        b=VtMZYPjBQcYwF594ImDz7MGUECygW+9QMZxIQnZWNvwUHSHAFuyEUIK+R/4icLRUeV
         lqzRfzp5XVwq6C9axVjm3072ZQ5vdggWpTCp/mFiwT8EmItVnjB9rLXFfGKdvbgjKtat
         lZEWXzdbFigcmO3eyhkXTEYSj4eU8aBpqw6GVrf+J5d8vo7QgIJtIrXyokH0v7wHe8tl
         Gc1EuNGLZ/BnEhQoubVq0bqtUUjDYW9rMoJI2XhABy4tr6KGZbROKRiyxuJEI7wgK/hA
         UCkzK8WPt4srwayc7004f7gpLVEBT0yRfugcjU1Qts2Ponz8XbIs2x2EooSCQCM0/2HT
         GOFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=Wwv4OC/5UKkx+hi7JxDLNFBGMRfe7Oq9haS0eC+cjr8=;
        b=fF+GZ7F6outKsytRl666KQe4vpy++PVRl8exWHR10gCVeUDZ3jeYrhFOeE/NApQhUU
         VW947KXNLeDr/t2br/ltNjgyM7k2FlE1Ls333YzHZzwwy4UyG/sQL/tWvSWfEedvKX93
         ymw/nE6Wc3OqiZr+WG46DJn+R8P5G58Ci2TqpkLlEohT2lma4u+D6vM985A4VYAiKHsL
         gJeUyzCUv0TYPDgxoVVItXGnhhKaDokBiiiBXWDXUDDVtl6yVWof+wgOARHLIA87UsnQ
         a//nYMiSOq/xKNjMlWf+QXIsvCMOqEXpaVxeKw6RS3zT0syw2w+SrYvVIZDd/hagYeYT
         L7dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OLhnbQDK;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor1654960wru.27.2019.03.12.10.55.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 10:55:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OLhnbQDK;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=Wwv4OC/5UKkx+hi7JxDLNFBGMRfe7Oq9haS0eC+cjr8=;
        b=OLhnbQDKTFwW7rbhdfodrticak5jfV1/nlf6gF/G9jzt5kKvIL95B+zdnYhyN1GKEs
         2W0PF4VrfRUsce+wJaJs3EvZGr9Di4vb3h2KXGNvL1EDikxMxZ5yD1i9PczSKiEJQyqO
         w4osIiBFDjrAbc18UuYMhp302JJT8vUBet6dVrxt4Z8nEfHUQ64HChzv5gv3RQIVYmTJ
         776dqQ66RLF7HTitqgAkGwcfi9EQWOEWu99KJrgTq94vYSCmNWxUIzEkJJfpn4SzJlvr
         F96pGtEu3ThDXWUn/OM81ZeR1H+At70t9Ef/W1dd+/ZdWrhlt2mO1nY4WXzWHxgsugia
         vSZg==
X-Google-Smtp-Source: APXvYqz89FavtsZg/+uFfjZ1Yw2bJe5QT0wK+td0E1luKxixjMEdWvhGWWsz5XxW++KlnEIlQcHlvdBG93zxW4xpGnI=
X-Received: by 2002:a5d:5510:: with SMTP id b16mr5515580wrv.163.1552413338806;
 Tue, 12 Mar 2019 10:55:38 -0700 (PDT)
MIME-Version: 1.0
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 12 Mar 2019 22:55:27 +0500
Message-ID: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
Subject: kernel BUG at include/linux/mm.h:1020!
To: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks.
I am observed kernel panic after updated to git commit 610cd4eadec4.
I am did not make git bisect because this crashes occurs spontaneously
and I not have exactly instruction how reproduce it.

Hope backtrace below could help understand how fix it:

page:ffffef46607ce000 is uninitialized and poisoned
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
------------[ cut here ]------------
kernel BUG at include/linux/mm.h:1020!
invalid opcode: 0000 [#1] SMP NOPTI
CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
5.1.0-0.rc0.git4.1.fc31.x86_64 #1
Hardware name: System manufacturer System Product Name/ROG STRIX
X470-I GAMING, BIOS 1201 12/07/2018
RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
Code: fe 06 e8 cf 8d fc ff 44 0f b6 4c 24 04 48 85 c0 0f 85 dc fe ff
ff e9 68 fe ff ff 48 c7 c6 70 cd 2e 8c 4c 89 ff e8 ec 74 00 00 <0f> 0b
48 c7 c6 70 cd 2e 8c e8 de 74 00 00 0f 0b 48 89 fa 41 b8 01
RSP: 0018:ffffbe2d43f1fde8 EFLAGS: 00010246
RAX: 0000000000000034 RBX: 000000000081f380 RCX: ffff9a1e3cfd6c20
RDX: 0000000000000000 RSI: 0000000000000006 RDI: ffff9a1e3cfd6c20
RBP: 0000000000000001 R08: 000004bdd8f302a3 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000100000
R13: 0000000000100000 R14: 0000000000000001 R15: ffffef46607ce000
FS:  0000000000000000(0000) GS:ffff9a1e3ce00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000038d164286000 CR3: 000000056c4ca000 CR4: 00000000003406e0
Call Trace:
 __reset_isolation_suitable+0x62/0x120
 reset_isolation_suitable+0x3b/0x40
 kswapd+0x147/0x540
 ? finish_wait+0x90/0x90
 kthread+0x108/0x140
 ? balance_pgdat+0x560/0x560
 ? kthread_park+0x90/0x90
 ret_from_fork+0x27/0x50
Modules linked in: macvtap macvlan tap uinput fuse rfcomm
ipt_MASQUERADE tun bridge stp llc xt_conntrack nf_conntrack_netbios_ns
nf_conntrack_broadcast xt_CT ebtable_nat iptable_nat nf_nat
iptable_mangle iptable_raw iptable_security nf_conntrack
nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c cmac ip_set nfnetlink
ebtable_filter ebtables bnep sunrpc vfat fat edac_mce_amd arc4 kvm_amd
kvm r8822be(C) irqbypass uvcvideo eeepc_wmi asus_wmi videobuf2_vmalloc
joydev sparse_keymap videobuf2_memops video snd_hda_codec_realtek
wmi_bmof videobuf2_v4l2 mac80211 snd_hda_codec_generic
videobuf2_common ledtrig_audio videodev snd_hda_codec_hdmi
crct10dif_pclmul crc32_pclmul snd_usb_audio media snd_hda_intel
snd_hda_codec snd_usbmidi_lib btusb snd_rawmidi btrtl snd_hda_core
btbcm ghash_clmulni_intel btintel snd_hwdep bluetooth snd_seq
snd_seq_device cfg80211 k10temp snd_pcm ecdh_generic rfkill snd_timer
snd sp5100_tco soundcore ccp i2c_piix4 pcc_cpufreq gpio_amdpt
gpio_generic acpi_cpufreq binfmt_misc
 hid_sony ff_memless amdgpu hid_logitech_hidpp chash amd_iommu_v2
gpu_sched ttm drm_kms_helper drm crc32c_intel igb nvme dca
i2c_algo_bit hid_logitech_dj nvme_core wmi pinctrl_amd
---[ end trace 44c9a3d09c80c5ae ]---
RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
Code: fe 06 e8 cf 8d fc ff 44 0f b6 4c 24 04 48 85 c0 0f 85 dc fe ff
ff e9 68 fe ff ff 48 c7 c6 70 cd 2e 8c 4c 89 ff e8 ec 74 00 00 <0f> 0b
48 c7 c6 70 cd 2e 8c e8 de 74 00 00 0f 0b 48 89 fa 41 b8 01
RSP: 0018:ffffbe2d43f1fde8 EFLAGS: 00010246
RAX: 0000000000000034 RBX: 000000000081f380 RCX: ffff9a1e3cfd6c20
RDX: 0000000000000000 RSI: 0000000000000006 RDI: ffff9a1e3cfd6c20
RBP: 0000000000000001 R08: 000004bdd8f302a3 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000100000
R13: 0000000000100000 R14: 0000000000000001 R15: ffffef46607ce000
FS:  0000000000000000(0000) GS:ffff9a1e3ce00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000038d164286000 CR3: 000000056c4ca000 CR4: 00000000003406e0
------------[ cut here ]------------
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<0000000088e85547>] prepare_to_wait+0x3a/0xc0
WARNING: CPU: 1 PID: 118 at kernel/sched/core.c:6136 __might_sleep+0x6c/0x70
Modules linked in: macvtap macvlan tap uinput fuse rfcomm
ipt_MASQUERADE tun bridge stp llc xt_conntrack nf_conntrack_netbios_ns
nf_conntrack_broadcast xt_CT ebtable_nat iptable_nat nf_nat
iptable_mangle iptable_raw iptable_security nf_conntrack
nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c cmac ip_set nfnetlink
ebtable_filter ebtables bnep sunrpc vfat fat edac_mce_amd arc4 kvm_amd
kvm r8822be(C) irqbypass uvcvideo eeepc_wmi asus_wmi videobuf2_vmalloc
joydev sparse_keymap videobuf2_memops video snd_hda_codec_realtek
wmi_bmof videobuf2_v4l2 mac80211 snd_hda_codec_generic
videobuf2_common ledtrig_audio videodev snd_hda_codec_hdmi
crct10dif_pclmul crc32_pclmul snd_usb_audio media snd_hda_intel
snd_hda_codec snd_usbmidi_lib btusb snd_rawmidi btrtl snd_hda_core
btbcm ghash_clmulni_intel btintel snd_hwdep bluetooth snd_seq
snd_seq_device cfg80211 k10temp snd_pcm ecdh_generic rfkill snd_timer
snd sp5100_tco soundcore ccp i2c_piix4 pcc_cpufreq gpio_amdpt
gpio_generic acpi_cpufreq binfmt_misc
 hid_sony ff_memless amdgpu hid_logitech_hidpp chash amd_iommu_v2
gpu_sched ttm drm_kms_helper drm crc32c_intel igb nvme dca
i2c_algo_bit hid_logitech_dj nvme_core wmi pinctrl_amd
CPU: 1 PID: 118 Comm: kswapd0 Tainted: G      D  C
5.1.0-0.rc0.git4.1.fc31.x86_64 #1
Hardware name: System manufacturer System Product Name/ROG STRIX
X470-I GAMING, BIOS 1201 12/07/2018
RIP: 0010:__might_sleep+0x6c/0x70
Code: 41 5c 41 5d e9 35 fe ff ff 48 8b 90 48 2e 00 00 48 8b 70 10 48
c7 c7 80 73 2f 8c c6 05 b5 ea 7c 01 01 48 89 d1 e8 fd be fc ff <0f> 0b
eb c8 0f 1f 44 00 00 48 8b 87 a0 0a 00 00 8b 97 08 0b 00 00
RSP: 0018:ffffbe2d43f1fea0 EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff9a1e2f47b2c0 RCX: ffff9a1e3cfd6c20
RDX: 0000000000000007 RSI: 0000000000000006 RDI: ffff9a1e3cfd6c20
RBP: ffffffff8c2f1eae R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000022
R13: 0000000000000000 R14: ffff9a1e2f47b2c0 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff9a1e3ce00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000038d164286000 CR3: 000000056c4ca000 CR4: 00000000003406e0
Call Trace:
 exit_signals+0x30/0x240
 ? finish_wait+0x90/0x90
 do_exit+0xbc/0xd20
 ? kthread+0x108/0x140
 rewind_stack_do_exit+0x17/0x20
irq event stamp: 18264061
hardirqs last  enabled at (18264061): [<ffffffff8b02b87a>]
do_error_trap+0xda/0x120
hardirqs last disabled at (18264060): [<ffffffff8b0037fa>]
trace_hardirqs_off_thunk+0x1a/0x1c
softirqs last  enabled at (18263974): [<ffffffff8be0035f>]
__do_softirq+0x35f/0x46a
softirqs last disabled at (18263967): [<ffffffff8b0eddb2>] irq_exit+0x102/0x110
---[ end trace 44c9a3d09c80c5af ]---
------------[ cut here ]------------
kernel BUG at kernel/sched/core.c:3536!



Thanks.

--
Best Regards,
Mike Gavrilov.

