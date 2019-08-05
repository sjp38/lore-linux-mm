Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C26C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 03:21:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FB372075C
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 03:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FB372075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F172C6B0003; Sun,  4 Aug 2019 23:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC7B86B0005; Sun,  4 Aug 2019 23:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8E416B0006; Sun,  4 Aug 2019 23:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF646B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 23:21:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e33so9777546pgm.20
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 20:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=/6gJKLQBdYfNayTPGlX4GGG3EMNNEc2z1RlFDvjLX1Q=;
        b=IuZHtzcg/TxO8crbDa0prhelJ9ZWu25xssx5vfvC4+MxQcb1xrk4Vr/5PuQMmtWnTV
         WncEFZ23Z2aFk2H+y7MAeTGyLL68XxAKM+cyeFxQYtP/z/rA6wIqpCO9FruHUqOfyVY9
         yfa5N9SMQQ08PQlX7TG0MgxdbwascgBkYi0ikRIh9PO7OFJZ3xjIlW55Il6B0owCf+ry
         8AaPmGgJjRC+mSOzCvhMcTZ38H0gE74+8LvAFtpqeiddoBK3kruFFYJpnUF7h0ZGQXDk
         g6DjiLyNTAOFBPDNVg4Z9nwd9FGiKzlvxURyv5OXvu0jlCc5mnVBWiVdCkJvFRhE+MsW
         +ijw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXxXUxMHQS+blcaTkDXm4qHTC+Rh8EPni+amBN4l46aJ3PpDScm
	7He4Y2rDw6qVurPck33HEgJdjCXQXkv5/j026FcDQpytnKWXbVLgHIJtDSTPBtyTSTcXaa1CkrA
	PaIdPTiKC+cb4YejQ3zbe+5DlrW4qE5tDBFQJpcSn6bytA2uH5KElNv2qC3sFydCeQQ==
X-Received: by 2002:a17:90a:ff17:: with SMTP id ce23mr15942735pjb.47.1564975291172;
        Sun, 04 Aug 2019 20:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfI7DZTOaoW0SIJBc07PlSITW/Y58PvKvIsrx8RqQg0N1arHc+Nc3B6XQMUhnfhG1YR058
X-Received: by 2002:a17:90a:ff17:: with SMTP id ce23mr15942671pjb.47.1564975289684;
        Sun, 04 Aug 2019 20:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564975289; cv=none;
        d=google.com; s=arc-20160816;
        b=qUuXrMwuXlP5miSPvpmAtnYA0OSMR8BotStY9fZssbhrn0V/W4BdlSlCD/PMXCbHp1
         kJ7ShLHl3SvCOktJx1BYaGqdwpl5OiQC5YD34VRdManqiHbEJQsrEP8SPILAYBuc4+1B
         2WKOsGNFodhYYCmOKU1Gqz1qH7gQTBJ3PVwKbTxypeceUeRTi3tuiUbgkkaFoHffvwve
         xX86IcFrzuq1l+Jh3SkeroiCz6MBltv375fb0U4c09dvinkOJpHNd9XtvxRl/ACYnObs
         qacZlMPk1qN5q4iNhKytRA5kUQtzsClewKlo+j1KNTK4I3ylPnjfhIfJQ/mNvpJBokaZ
         Z9nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=/6gJKLQBdYfNayTPGlX4GGG3EMNNEc2z1RlFDvjLX1Q=;
        b=A1kklXOaIWL+ptJHo26rOl5Man8oz8SuwDJ6v2AFNcA0EpYf4OiBMBdV4Fy0wTVvVF
         yTfBVmwm5VBv/DOBW46uJNZIJei6r1Dp4qq/PWsekenJR0iVLHnN9ny5TVYMPdMar9mi
         bup4z1XF8s2seooFJYlxQJuZ7AbHVlDLVoE7naMXcdb3rpoPJTha8bvKhaDpA1DaGtQM
         jF42aKoj0Nk4IGCkPJMg+uBYxdwmUblDBGHSEPbNF0WrwAtT7u51LdRvXI/yCe4oA7rS
         MRgU3B0QZMjfkKVe1YUo4lrIpwY8ObelNrcdwCAItC2sAsl2pYB2Hl/w8uzf5Wl4gbVb
         VQqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id 12si49153517pgu.469.2019.08.04.20.21.28
        for <linux-mm@kvack.org>;
        Sun, 04 Aug 2019 20:21:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D47A0B500003E06; Mon, 5 Aug 2019 11:21:27 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 72876245090273
From: Hillf Danton <hdanton@sina.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Dave Airlie <airlied@gmail.com>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	"Koenig, Christian" <Christian.Koenig@amd.com>,
	Harry Wentland <harry.wentland@amd.com>,
	amd-gfx list <amd-gfx@lists.freedesktop.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
Date: Mon,  5 Aug 2019 11:21:14 +0800
Message-Id: <20190805032114.8740-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 5 Aug 2019 at 08:23, Mikhail Gavrilov wrote:
> Hi folks,
> Two weeks ago when commit 22051d9c4a57 coming to my system.
> Started happen randomly errors:
> "gnome-shell: page allocation failure: order:4,
> mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> nodemask=3D(null),cpuset=3D/,mems_allowed=3D0"
> Symptoms:
> The screen goes out as in energy saving.
> And it is impossible to wake the computer in a few minutes.
>=20
> I am making bisect and looks like the first bad commit is 476e955dd679.
> Here full bisect logs: https://mega.nz/#F!kgYFxAIb!v1tcHANPy2ns1lh4LQLeIg
>=20
> I wrote about my find to the amd-gfx mailing list, but no one answer me.
> Until yesterday, I thought it was a bug in the amdgpu driver.
> But yesterday, after the next occurrence of an error, the system hangs
> completely already with another error.

[pruned]

> [ 3225.313209] Xorg: page allocation failure: order:4, mode:0x40dc0(GFP_K=
ERNEL|__GFP_COMP|__GFP_ZERO), nodemask=3D(null),cpuset=3D/,mems_allowed=3D0
> [ 3225.313300] CPU: 2 PID: 12717 Comm: Xorg Not tainted 5.3.0-0.rc2.git4.=
1.fc31.x86_64 #1
> [ 3225.313303] Hardware name: System manufacturer System Product Name/ROG=
 STRIX X470-I GAMING, BIOS 2406 06/21/2019
> [ 3225.313306] Call Trace:
> [ 3225.313315]  dump_stack+0x85/0xc0
> [ 3225.313321]  warn_alloc.cold+0x7b/0xfb
> [ 3225.313329]  ? _cond_resched+0x15/0x30
> [ 3225.313333]  ? __alloc_pages_direct_compact+0x181/0x1a0
> [ 3225.313341]  __alloc_pages_slowpath+0xfe1/0x1020
> [ 3225.313348]  ? __lock_acquire+0x247/0x1910
> [ 3225.313365]  __alloc_pages_nodemask+0x37f/0x400
> [ 3225.313374]  kmalloc_order+0x20/0x60
> [ 3225.313378]  kmalloc_order_trace+0x1d/0x120
> [ 3225.313498]  dc_create_state+0x1f/0x60 [amdgpu]
> [ 3225.313582]  amdgpu_dm_atomic_commit_tail+0xbd7/0x1cf0 [amdgpu]
> [ 3225.313596]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.313615]  ? debug_check_no_obj_freed+0x107/0x1d8
> [ 3225.313685]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.313778]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.313786]  ? kfree+0x1b6/0x3b0
> [ 3225.313860]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.313875]  ? __lock_acquire+0x247/0x1910
> [ 3225.313891]  ? find_held_lock+0x32/0x90
> [ 3225.313898]  ? mark_held_locks+0x50/0x80
> [ 3225.313907]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.313911]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.313921]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.313928]  ? wait_for_completion_timeout+0x75/0x190
> [ 3225.313958]  ? commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.313972]  commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.313984]  drm_atomic_helper_commit+0xe3/0x150 [drm_kms_helper]
> [ 3225.313994]  drm_atomic_helper_disable_plane+0x82/0xb0 [drm_kms_helper]
> [ 3225.314043]  drm_mode_cursor_universal+0x12c/0x240 [drm]
> [ 3225.314147]  drm_mode_cursor_common+0xd8/0x230 [drm]
> [ 3225.314194]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.314209]  drm_mode_cursor_ioctl+0x4d/0x70 [drm]
> [ 3225.314244]  drm_ioctl_kernel+0xaa/0xf0 [drm]
> [ 3225.314260]  drm_ioctl+0x208/0x390 [drm]
> [ 3225.314275]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.314297]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.314376]  amdgpu_drm_ioctl+0x49/0x80 [amdgpu]
> [ 3225.314384]  do_vfs_ioctl+0x411/0x750
> [ 3225.314395]  ksys_ioctl+0x5e/0x90
> [ 3225.314413]  __x64_sys_ioctl+0x16/0x20
> [ 3225.314417]  do_syscall_64+0x5c/0xb0
> [ 3225.314422]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 3225.314425] RIP: 0033:0x7fdde5b4007b
> [ 3225.314477] Code: 0f 1e fa 48 8b 05 0d 9e 0c 00 64 c7 00 26 00 00 00 4=
8 c7 c0
> ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <48> 3d=
 01 f0
> ff ff 73 01 c3 48 8b 0d dd 9d 0c 00 f7 d8 64 89 01 48
> [ 3225.314485] RSP: 002b:00007ffec481a6d8 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000010
> [ 3225.314490] RAX: ffffffffffffffda RBX: 00007ffec481a710 RCX: 00007fdde=
5b4007b
> [ 3225.314494] RDX: 00007ffec481a710 RSI: 00000000c01c64a3 RDI: 000000000=
000000e
> [ 3225.314496] RBP: 00000000c01c64a3 R08: 0000000000000080 R09: 000000000=
0000000
> [ 3225.314499] R10: 0000000000000004 R11: 0000000000000246 R12: 000000000=
00006f1
> [ 3225.314502] R13: 000000000000000e R14: 000056201b5b5490 R15: 000056201=
bbe7820
> [ 3225.314992] Mem-Info:
> [ 3225.315020] active_anon:2784941 inactive_anon:601242 isolated_anon:0
>                 active_file:1926790 inactive_file:1763177 isolated_file:0
>                 unevictable:16 dirty:2244 writeback:0 unstable:0
>                 slab_reclaimable:542021 slab_unreclaimable:135707
>                 mapped:525720 shmem:421336 pagetables:32066 bounce:0
>                 free:81471 free_pcp:299 free_cma:0
> [ 3225.315026] Node 0 active_anon:11139764kB inactive_anon:2404968kB acti=
ve_file:7707160kB inactive_file:7052264kB unevictable:64kB isolated(anon):0=
kB isolated(file):0kB mapped:2102880kB dirty:8976kB writeback:0kB shmem:168=
5344kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2222080kB writeback_tm=
p:0kB unstable:0kB all_unreclaimable? no
> [ 3225.315030] Node 0 DMA free:15892kB min:32kB low:44kB high:56kB active=
_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15996kB managed:15896kB mlocked:0kB kernel_stac=
k:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [ 3225.315036] lowmem_reserve[]: 0 3393 31872 31872 31872
> [ 3225.315042] Node 0 DMA32 free:121024kB min:7188kB low:10660kB high:141=
32kB active_anon:544688kB inactive_anon:161072kB active_file:730232kB inact=
ive_file:1649412kB unevictable:0kB writepending:120kB present:3575768kB man=
aged:3575580kB mlocked:0kB kernel_stack:432kB pagetables:2460kB bounce:0kB =
free_pcp:0kB local_pcp:0kB free_cma:0kB
> [ 3225.315048] lowmem_reserve[]: 0 0 28479 28479 28479
> [ 3225.315053] Node 0 Normal free:188968kB min:187332kB low:216492kB high=
:245652kB active_anon:10594804kB inactive_anon:2243364kB active_file:697762=
8kB inactive_file:5403916kB unevictable:64kB writepending:8856kB present:29=
871616kB managed:29173412kB mlocked:64kB kernel_stack:32704kB pagetables:12=
5804kB bounce:0kB free_pcp:1196kB local_pcp:0kB free_cma:0kB
> [ 3225.315059] lowmem_reserve[]: 0 0 0 0 0
> [ 3225.315065] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 0*32kB 2*64kB (U) 1=
*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 1=
5892kB
> [ 3225.315157] Node 0 DMA32: 867*4kB (UME) 1244*8kB (UME) 1093*16kB (UM) =
525*32kB (ME) 219*64kB (UME) 74*128kB (UME) 25*256kB (UM) 6*512kB (UM) 4*10=
24kB (ME) 6*2048kB (UM) 6*4096kB (U) =3D 121628kB
> [ 3225.315254] Node 0 Normal: 3277*4kB (UME) 1459*8kB (UME) 2012*16kB (UM=
E) 1869*32kB (UMEH) 742*64kB (UMEH) 178*128kB (UMEH) 14*256kB (UM) 0*512kB =
0*1024kB 0*2048kB 0*4096kB =3D 190636kB
> [ 3225.315269] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_su=
rp=3D0 hugepages_size=3D1048576kB
> [ 3225.315272] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_su=
rp=3D0 hugepages_size=3D2048kB
> [ 3225.315275] 4111448 total pagecache pages
> [ 3225.315288] 103 pages in swap cache
> [ 3225.315291] Swap cache stats: add 1859, delete 1756, find 67/126
> [ 3225.315294] Free swap  =3D 67100924kB
> [ 3225.315297] Total swap =3D 67108860kB
> [ 3225.315299] 8365845 pages RAM
> [ 3225.315302] 0 pages HighMem/MovableOnly
> [ 3225.315305] 174623 pages reserved
> [ 3225.315307] 0 pages cma reserved
> [ 3225.315310] 0 pages hwpoisoned
> [ 3225.315325] ------------[ cut here ]------------
> [ 3225.315738] WARNING: CPU: 2 PID: 12717 at drivers/gpu/drm/amd/amdgpu/.=
./display/amdgpu_dm/amdgpu_dm.c:6109 amdgpu_dm_atomic_commit_tail.cold+0x96=
/0xe1 [amdgpu]
> [ 3225.315742] Modules linked in: macvtap macvlan tap rfcomm xt_CHECKSUM =
xt_MASQUERADE nf_nat_tftp nf_conntrack_tftp tun bridge stp llc nf_conntrack=
_netbios_ns nf_conntrack_broadcast xt_CT ip6t_REJECT nf_reject_ipv6 ip6t_rp=
filter ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ip6table_nat ip6t=
able_mangle ip6table_raw ip6table_security iptable_nat nf_nat iptable_mangl=
e iptable_raw iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 l=
ibcrc32c ip_set nfnetlink ebtable_filter ebtables ip6table_filter ip6_table=
s iptable_filter cmac bnep sunrpc vfat fat snd_hda_codec_realtek edac_mce_a=
md snd_hda_codec_generic ledtrig_audio kvm_amd rtwpci snd_hda_codec_hdmi rt=
w88 kvm snd_hda_intel snd_usb_audio snd_hda_codec mac80211 snd_hda_core snd=
_usbmidi_lib irqbypass snd_rawmidi uvcvideo snd_hwdep snd_seq videobuf2_vma=
lloc videobuf2_memops btusb videobuf2_v4l2 crct10dif_pclmul snd_seq_device =
videobuf2_common btrtl crc32_pclmul eeepc_wmi snd_pcm btbcm btintel asus_wm=
i xpad snd_timer sparse_keymap
> [ 3225.315797]  videodev ff_memless bluetooth joydev ghash_clmulni_intel =
cfg80211 video snd mc k10temp wmi_bmof soundcore ecdh_generic sp5100_tco ec=
c rfkill ccp i2c_piix4 libarc4 gpio_amdpt gpio_generic acpi_cpufreq binfmt_=
misc ip_tables hid_logitech_hidpp amdgpu amd_iommu_v2 gpu_sched ttm drm_kms=
_helper drm igb crc32c_intel dca i2c_algo_bit hid_logitech_dj nvme nvme_cor=
e wmi pinctrl_amd
> [ 3225.315974] CPU: 2 PID: 12717 Comm: Xorg Not tainted 5.3.0-0.rc2.git4.=
1.fc31.x86_64 #1
> [ 3225.315977] Hardware name: System manufacturer System Product Name/ROG=
 STRIX X470-I GAMING, BIOS 2406 06/21/2019
> [ 3225.316201] RIP: 0010:amdgpu_dm_atomic_commit_tail.cold+0x96/0xe1 [amd=
gpu]
> [ 3225.316234] Code: ff 48 c7 c7 70 81 76 c0 e8 04 77 ac f6 0f 0b 83 7b 0=
8 00 0f 85 f0 62 f1 ff e9 08 63 f1 ff 48 c7 c7 70 81 76 c0 e8 e7 76 ac f6 <=
0f> 0b 48 8b 85 b8 fd ff ff 31 f6 48 8b b8 f8 53 01 00 e8 42 d5 fd
> [ 3225.316238] RSP: 0018:ffffb439c3e37800 EFLAGS: 00010246
> [ 3225.316242] RAX: 0000000000000024 RBX: ffffffffc08380b0 RCX: 000000000=
0000006
> [ 3225.316245] RDX: 0000000000000000 RSI: ffff9b0b187c4038 RDI: ffff9b0bb=
a5d9e00
> [ 3225.316248] RBP: ffffb439c3e37ab0 R08: 000002eef3c694b7 R09: 000000000=
0000000
> [ 3225.316250] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000=
0000000
> [ 3225.316253] R13: ffff9b0bb5381000 R14: ffff9b09acc68598 R15: ffff9b09a=
cc68540
> [ 3225.316257] FS:  00007fdde56cbf00(0000) GS:ffff9b0bba400000(0000) knlG=
S:0000000000000000
> [ 3225.316259] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3225.316262] CR2: 00007f1b48b29000 CR3: 00000007382ee000 CR4: 000000000=
03406e0
> [ 3225.316265] Call Trace:
> [ 3225.316276]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.316287]  ? debug_check_no_obj_freed+0x107/0x1d8
> [ 3225.316492]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.316736]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.316743]  ? kfree+0x1b6/0x3b0
> [ 3225.316992]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.317008]  ? __lock_acquire+0x247/0x1910
> [ 3225.317018]  ? find_held_lock+0x32/0x90
> [ 3225.317024]  ? mark_held_locks+0x50/0x80
> [ 3225.317056]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.317097]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.317115]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.317118]  ? wait_for_completion_timeout+0x75/0x190
> [ 3225.317135]  ? commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.317143]  commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.317153]  drm_atomic_helper_commit+0xe3/0x150 [drm_kms_helper]
> [ 3225.317185]  drm_atomic_helper_disable_plane+0x82/0xb0 [drm_kms_helper]
> [ 3225.317226]  drm_mode_cursor_universal+0x12c/0x240 [drm]
> [ 3225.317251]  drm_mode_cursor_common+0xd8/0x230 [drm]
> [ 3225.317275]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.317289]  drm_mode_cursor_ioctl+0x4d/0x70 [drm]
> [ 3225.317302]  drm_ioctl_kernel+0xaa/0xf0 [drm]
> [ 3225.317315]  drm_ioctl+0x208/0x390 [drm]
> [ 3225.317335]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.317346]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.317405]  amdgpu_drm_ioctl+0x49/0x80 [amdgpu]
> [ 3225.317413]  do_vfs_ioctl+0x411/0x750
> [ 3225.317425]  ksys_ioctl+0x5e/0x90
> [ 3225.317430]  __x64_sys_ioctl+0x16/0x20
> [ 3225.317437]  do_syscall_64+0x5c/0xb0
> [ 3225.317441]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 3225.317445] RIP: 0033:0x7fdde5b4007b
> [ 3225.317450] Code: 0f 1e fa 48 8b 05 0d 9e 0c 00 64 c7 00 26 00 00 00 4=
8 c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <=
48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d dd 9d 0c 00 f7 d8 64 89 01 48
> [ 3225.317455] RSP: 002b:00007ffec481a6d8 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000010
> [ 3225.317459] RAX: ffffffffffffffda RBX: 00007ffec481a710 RCX: 00007fdde=
5b4007b
> [ 3225.317461] RDX: 00007ffec481a710 RSI: 00000000c01c64a3 RDI: 000000000=
000000e
> [ 3225.317465] RBP: 00000000c01c64a3 R08: 0000000000000080 R09: 000000000=
0000000
> [ 3225.317469] R10: 0000000000000004 R11: 0000000000000246 R12: 000000000=
00006f1
> [ 3225.317472] R13: 000000000000000e R14: 000056201b5b5490 R15: 000056201=
bbe7820
> [ 3225.317500] irq event stamp: 97442804
> [ 3225.317507] hardirqs last  enabled at (97442803): [<ffffffffb71713db>]=
 console_unlock+0x46b/0x5d0
> [ 3225.317512] hardirqs last disabled at (97442804): [<ffffffffb700383a>]=
 trace_hardirqs_off_thunk+0x1a/0x20
> [ 3225.317517] softirqs last  enabled at (97442596): [<ffffffffb7e0035d>]=
 __do_softirq+0x35d/0x45d
> [ 3225.317523] softirqs last disabled at (97442589): [<ffffffffb70f1e27>]=
 irq_exit+0xf7/0x100
> [ 3225.317526] ---[ end trace baab6af74a9fa531 ]---
> [ 3225.317560] BUG: unable to handle page fault for address: 000000000000=
c9f4
> [ 3225.317562] #PF: supervisor read access in kernel mode
> [ 3225.317563] #PF: error_code(0x0000) - not-present page
> [ 3225.317565] PGD 0 P4D 0
> [ 3225.317567] Oops: 0000 [#1] SMP NOPTI
> [ 3225.317571] CPU: 2 PID: 12717 Comm: Xorg Tainted: G        W         5=
.3.0-0.rc2.git4.1.fc31.x86_64 #1
> [ 3225.317572] Hardware name: System manufacturer System Product Name/ROG=
 STRIX X470-I GAMING, BIOS 2406 06/21/2019
> [ 3225.317625] RIP: 0010:dc_resource_state_copy_construct+0x18/0xf0 [amdg=
pu]
> [ 3225.317627] Code: 00 49 83 c4 01 44 39 e0 7f b5 5b 5d 41 5c 41 5d c3 c=
3 0f 1f 44 00 00 41 56 ba f8 c9 00 00 41 55 41 54 49 89 f4 55 4c 89 e5 53 <=
44> 8b ae f4 c9 00 00 48 89 fe 4c 89 e7 e8 16 86 48 f7 49 8d 84 24
> [ 3225.317630] RSP: 0018:ffffb439c3e377d0 EFLAGS: 00010246
> [ 3225.317631] RAX: ffff9b0ba19a0000 RBX: ffffffffc08380b0 RCX: 000000000=
0000006
> [ 3225.317633] RDX: 000000000000c9f8 RSI: 0000000000000000 RDI: ffff9b0ab=
7fc0000
> [ 3225.317635] RBP: 0000000000000000 R08: 000002eef3c694b7 R09: 000000000=
0000000
> [ 3225.317636] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000=
0000000
> [ 3225.317638] R13: ffff9b0bb5381000 R14: ffff9b09acc68598 R15: ffff9b09a=
cc68540
> [ 3225.317640] FS:  00007fdde56cbf00(0000) GS:ffff9b0bba400000(0000) knlG=
S:0000000000000000
> [ 3225.317641] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3225.317643] CR2: 000000000000c9f4 CR3: 00000007382ee000 CR4: 000000000=
03406e0
> [ 3225.317644] Call Trace:
> [ 3225.317714]  amdgpu_dm_atomic_commit_tail.cold+0xad/0xe1 [amdgpu]
> [ 3225.317719]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.317723]  ? debug_check_no_obj_freed+0x107/0x1d8
> [ 3225.317786]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.317850]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.317855]  ? kfree+0x1b6/0x3b0
> [ 3225.317918]  ? dm_determine_update_type_for_commit+0x34c/0x420 [amdgpu]
> [ 3225.317923]  ? __lock_acquire+0x247/0x1910
> [ 3225.317928]  ? find_held_lock+0x32/0x90
> [ 3225.317931]  ? mark_held_locks+0x50/0x80
> [ 3225.317934]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.317937]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.317939]  ? _raw_spin_unlock_irq+0x29/0x40
> [ 3225.317942]  ? wait_for_completion_timeout+0x75/0x190
> [ 3225.317954]  ? commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.317960]  commit_tail+0x3c/0x70 [drm_kms_helper]
> [ 3225.317968]  drm_atomic_helper_commit+0xe3/0x150 [drm_kms_helper]
> [ 3225.317975]  drm_atomic_helper_disable_plane+0x82/0xb0 [drm_kms_helper]
> [ 3225.317994]  drm_mode_cursor_universal+0x12c/0x240 [drm]
> [ 3225.318011]  drm_mode_cursor_common+0xd8/0x230 [drm]
> [ 3225.318026]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.318038]  drm_mode_cursor_ioctl+0x4d/0x70 [drm]
> [ 3225.318049]  drm_ioctl_kernel+0xaa/0xf0 [drm]
> [ 3225.318061]  drm_ioctl+0x208/0x390 [drm]
> [ 3225.318075]  ? drm_mode_setplane+0x1a0/0x1a0 [drm]
> [ 3225.318079]  ? lockdep_hardirqs_on+0xf0/0x180
> [ 3225.318145]  amdgpu_drm_ioctl+0x49/0x80 [amdgpu]
> [ 3225.318164]  do_vfs_ioctl+0x411/0x750
> [ 3225.318175]  ksys_ioctl+0x5e/0x90
> [ 3225.318179]  __x64_sys_ioctl+0x16/0x20
> [ 3225.318188]  do_syscall_64+0x5c/0xb0
> [ 3225.318191]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 3225.318194] RIP: 0033:0x7fdde5b4007b
> [ 3225.318203] Code: 0f 1e fa 48 8b 05 0d 9e 0c 00 64 c7 00 26 00 00 00 4=
8 c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <=
48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d dd 9d 0c 00 f7 d8 64 89 01 48
> [ 3225.318209] RSP: 002b:00007ffec481a6d8 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000010
> [ 3225.318213] RAX: ffffffffffffffda RBX: 00007ffec481a710 RCX: 00007fdde=
5b4007b
> [ 3225.318215] RDX: 00007ffec481a710 RSI: 00000000c01c64a3 RDI: 000000000=
000000e
> [ 3225.318217] RBP: 00000000c01c64a3 R08: 0000000000000080 R09: 000000000=
0000000
> [ 3225.318218] R10: 0000000000000004 R11: 0000000000000246 R12: 000000000=
00006f1
> [ 3225.318220] R13: 000000000000000e R14: 000056201b5b5490 R15: 000056201=
bbe7820
> [ 3225.318225] Modules linked in: macvtap macvlan tap rfcomm xt_CHECKSUM =
xt_MASQUERADE nf_nat_tftp nf_conntrack_tftp tun bridge stp llc nf_conntrack=
_netbios_ns nf_conntrack_broadcast xt_CT ip6t_REJECT nf_reject_ipv6 ip6t_rp=
filter ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ip6table_nat ip6t=
able_mangle ip6table_raw ip6table_security iptable_nat nf_nat iptable_mangl=
e iptable_raw iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 l=
ibcrc32c ip_set nfnetlink ebtable_filter ebtables ip6table_filter ip6_table=
s iptable_filter cmac bnep sunrpc vfat fat snd_hda_codec_realtek edac_mce_a=
md snd_hda_codec_generic ledtrig_audio kvm_amd rtwpci snd_hda_codec_hdmi rt=
w88 kvm snd_hda_intel snd_usb_audio snd_hda_codec mac80211 snd_hda_core snd=
_usbmidi_lib irqbypass snd_rawmidi uvcvideo snd_hwdep snd_seq videobuf2_vma=
lloc videobuf2_memops btusb videobuf2_v4l2 crct10dif_pclmul snd_seq_device =
videobuf2_common btrtl crc32_pclmul eeepc_wmi snd_pcm btbcm btintel asus_wm=
i xpad snd_timer sparse_keymap
> [ 3225.318261]  videodev ff_memless bluetooth joydev ghash_clmulni_intel =
cfg80211 video snd mc k10temp wmi_bmof soundcore ecdh_generic sp5100_tco ec=
c rfkill ccp i2c_piix4 libarc4 gpio_amdpt gpio_generic acpi_cpufreq binfmt_=
misc ip_tables hid_logitech_hidpp amdgpu amd_iommu_v2 gpu_sched ttm drm_kms=
_helper drm igb crc32c_intel dca i2c_algo_bit hid_logitech_dj nvme nvme_cor=
e wmi pinctrl_amd
> [ 3225.318283] CR2: 000000000000c9f4
> [ 3225.318286] ---[ end trace baab6af74a9fa532 ]---
> [ 3225.318346] RIP: 0010:dc_resource_state_copy_construct+0x18/0xf0 [amdg=
pu]
> [ 3225.318348] Code: 00 49 83 c4 01 44 39 e0 7f b5 5b 5d 41 5c 41 5d c3 c=
3 0f 1f 44 00 00 41 56 ba f8 c9 00 00 41 55 41 54 49 89 f4 55 4c 89 e5 53 <=
44> 8b ae f4 c9 00 00 48 89 fe 4c 89 e7 e8 16 86 48 f7 49 8d 84 24
> [ 3225.318350] RSP: 0018:ffffb439c3e377d0 EFLAGS: 00010246
> [ 3225.318352] RAX: ffff9b0ba19a0000 RBX: ffffffffc08380b0 RCX: 000000000=
0000006
> [ 3225.318354] RDX: 000000000000c9f8 RSI: 0000000000000000 RDI: ffff9b0ab=
7fc0000
> [ 3225.318355] RBP: 0000000000000000 R08: 000002eef3c694b7 R09: 000000000=
0000000
> [ 3225.318357] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000=
0000000
> [ 3225.318358] R13: ffff9b0bb5381000 R14: ffff9b09acc68598 R15: ffff9b09a=
cc68540
> [ 3225.318360] FS:  00007fdde56cbf00(0000) GS:ffff9b0bba400000(0000) knlG=
S:0000000000000000
> [ 3225.318361] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3225.318363] CR2: 000000000000c9f4 CR3: 00000007382ee000 CR4: 000000000=
03406e0
> [ 3225.318368] BUG: sleeping function called from invalid context at incl=
ude/linux/percpu-rwsem.h:38
> [ 3225.318373] in_atomic(): 0, irqs_disabled(): 1, pid: 12717, name: Xorg
> [ 3225.318376] INFO: lockdep is turned off.
> [ 3225.318379] irq event stamp: 97442818
> [ 3225.318383] hardirqs last  enabled at (97442817): [<ffffffffb700381a>]=
 trace_hardirqs_on_thunk+0x1a/0x20
> [ 3225.318385] hardirqs last disabled at (97442818): [<ffffffffb700383a>]=
 trace_hardirqs_off_thunk+0x1a/0x20
> [ 3225.318387] softirqs last  enabled at (97442816): [<ffffffffb7e0035d>]=
 __do_softirq+0x35d/0x45d
> [ 3225.318390] softirqs last disabled at (97442807): [<ffffffffb70f1e27>]=
 irq_exit+0xf7/0x100
> [ 3225.318393] CPU: 2 PID: 12717 Comm: Xorg Tainted: G      D W         5=
.3.0-0.rc2.git4.1.fc31.x86_64 #1
> [ 3225.318395] Hardware name: System manufacturer System Product Name/ROG=
 STRIX X470-I GAMING, BIOS 2406 06/21/2019
> [ 3225.318396] Call Trace:
> [ 3225.318401]  dump_stack+0x85/0xc0
> [ 3225.318405]  ___might_sleep.cold+0xac/0xbc
> [ 3225.318408]  exit_signals+0x30/0x330
> [ 3225.318411]  do_exit+0xcb/0xcd0
> [ 3225.318414]  ? ksys_ioctl+0x5e/0x90
> [ 3225.318418]  rewind_stack_do_exit+0x17/0x20
>=20

[ 3225.313209] Xorg: page allocation failure: order:4, mode:0x40dc0(GFP_KER=
NEL|__GFP_COMP|__GFP_ZERO), nodemask=3D(null),cpuset=3D/,mems_allowed=3D0

Try to fix the failure above using vmalloc + kmalloc.

--- a/drivers/gpu/drm/amd/display/dc/core/dc.c
+++ b/drivers/gpu/drm/amd/display/dc/core/dc.c
@@ -1174,8 +1174,12 @@ struct dc_state *dc_create_state(struct
 	struct dc_state *context =3D kzalloc(sizeof(struct dc_state),
 					   GFP_KERNEL);
=20
-	if (!context)
-		return NULL;
+	if (!context) {
+		context =3D kvzalloc(sizeof(struct dc_state),
+					   GFP_KERNEL);
+		if (!context)
+			return NULL;
+	}
 	/* Each context must have their own instance of VBA and in order to
 	 * initialize and obtain IP and SOC the base DML instance from DC is
 	 * initially copied into every context
@@ -1195,8 +1199,13 @@ struct dc_state *dc_copy_state(struct dc
 	struct dc_state *new_ctx =3D kmemdup(src_ctx,
 			sizeof(struct dc_state), GFP_KERNEL);
=20
-	if (!new_ctx)
-		return NULL;
+	if (!new_ctx) {
+		new_ctx =3D kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
+		if (new_ctx)
+			*new_ctx =3D *src_ctx;
+		else
+			return NULL;
+	}
=20
 	for (i =3D 0; i < MAX_PIPES; i++) {
 			struct pipe_ctx *cur_pipe =3D &new_ctx->res_ctx.pipe_ctx[i];
@@ -1230,7 +1239,7 @@ static void dc_state_free(struct kref *k
 {
 	struct dc_state *context =3D container_of(kref, struct dc_state, refcount=
);
 	dc_resource_state_destruct(context);
-	kfree(context);
+	kvfree(context);
 }
=20
 void dc_release_state(struct dc_state *context)
--

