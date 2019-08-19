Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1CA6C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A865E2082C
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:28:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cSS7eYaF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A865E2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 356736B0007; Mon, 19 Aug 2019 11:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30A706B0010; Mon, 19 Aug 2019 11:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 095F76B0266; Mon, 19 Aug 2019 11:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id A256C6B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:28:03 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3D5EE440B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:28:03 +0000 (UTC)
X-FDA: 75839558046.21.day32_45a4ca1cd6430
X-HE-Tag: day32_45a4ca1cd6430
X-Filterd-Recvd-Size: 300446
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com [209.85.167.67])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:27:58 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id c19so1700286lfm.10
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:27:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=r/PSFmWxHm6701iLOLpO3k8IvfzRd/p3R3/ZShvSzRI=;
        b=cSS7eYaFgRzEz8gIIWGyC26oIMOCZA9aloxTjZ1Gw6VVhakEvUFPPZRbe62F7AwXVy
         LpEARyTgDlroKbtrQCUbbvxAtB/+kKF5zEgwxC2UUpjt4mnL14RitNgrpSG6IHs/OgdZ
         +MjfEhvKp3RzHn1WJjM0RXVGEkfz8ShDwL8I1GCrb7b2E/lwXEQ/qeMH0CxjIXYToVa2
         Jyskl0Bb3+zs17+1TPOPvzAnH+2Eh4ovtBVySLm1pWvvYmUAN2wnJ+gzhbGriXApqwv+
         Vhui+eFUiljsFd/8b4O7PgjgnOFIDqc4sL9nUztg4FvjjdVcrRB7xrVgKyjnZYJ+fDvD
         NJMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=r/PSFmWxHm6701iLOLpO3k8IvfzRd/p3R3/ZShvSzRI=;
        b=fsTuyCx/FHpKc61Vv9fDG3AO4mo8X8Ax3Wa1wFsG4CF3Ud3Ml5l+9bL9Xm9xOBAU9C
         e6GlNtM1GyZeI95JeGd/2A7DylsTqHHdtk8s0+STJJOpRuptww+ByQJlZBQAdXsNJxBK
         CNrSXwyfxpIRRpf1BLl8aCU+iU13yt1CnThN7a95sdvrBbzRTasxCt+Z7Fcksl2xTVIv
         DP82/+UaKF3IVg5bPmcxeibmwd/gEp8S3D7Bgt63EWr8WEh5CVQpNb4ljD3fny1WXYcM
         /h+x+9p97vraH8CZYXsWVRXLegnwrLY6tQcMOL+jwv9RcU0nMcaJ8X1UNmHPT4ywRJ87
         hdjA==
X-Gm-Message-State: APjAAAUfp6OMtuc//B0AtsZ4xqC6+AirOXHv1dYTo8GmIIWWlD9IUFrC
	+DJ1fTp/u844nDH0x1lY17Odyl1zkdp6dyfYY9s=
X-Google-Smtp-Source: APXvYqwt8iEM3pUXynwvtIO5jfIVLgFl4vepDog9DX6zRYBJzAmmTWQNxW3oCztpr0RnB5yLuPjHI7N6ZJJ7AVTJock=
X-Received: by 2002:ac2:4242:: with SMTP id m2mr7480468lfl.121.1566228475296;
 Mon, 19 Aug 2019 08:27:55 -0700 (PDT)
MIME-Version: 1.0
References: <CAH6yVy3s6Z6EH+7QRcN740pZe6CP-kkC83VwYd4RvbRm6LF4OQ@mail.gmail.com>
 <20190819073456.GC3111@dhcp22.suse.cz> <CAMJBoFPGT0_GqZLuOxLWPtrYkwM2WLvZ9=8F7phnGEoGYSEW8Q@mail.gmail.com>
In-Reply-To: <CAMJBoFPGT0_GqZLuOxLWPtrYkwM2WLvZ9=8F7phnGEoGYSEW8Q@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 19 Aug 2019 17:27:41 +0200
Message-ID: <CAMJBoFN-TPggasbaEnpubXt+77XHQt+AGmu9A9JX2c=h7Tog0Q@mail.gmail.com>
Subject: Re: PROBLEM: zswap with z3fold makes swap stuck
To: Michal Hocko <mhocko@kernel.org>
Cc: Markus Linnala <markus.linnala@gmail.com>, Linux-MM <linux-mm@kvack.org>, 
	Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 4:42 PM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> Hey Michal,
>
> On Mon, Aug 19, 2019 at 9:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > Thanks a lot for a detailed bug report. CC Vitaly.
>
> thanks for CC'ing me.
>
> > The original email preserved for more context.
>
> Thanks Markus for bisecting. That really gave me the clue. I'll come
> up with a patch within hours, would you be up for trying it?

Patch: https://bugzilla.kernel.org/attachment.cgi?id=3D284507&action=3Ddiff

> Best regards,
>    Vitaly
>
> > On Sun 18-08-19 21:36:19, Markus Linnala wrote:
> > > [1.] One line summary of the problem:
> > >
> > > zswap with z3fold makes swap stuck
> > >
> > >
> > > [2.] Full description of the problem/report:
> > >
> > > I've enabled zwswap using kernel parameters: zswap.enabled=3D1 zswap.=
zpool=3Dz3fold
> > > When there is issue, every process using swapping is stuck.
> > >
> > > I can reproduce almost always in vanilla v5.3-rc4 running tool
> > > "stress", repeatedly.
> > >
> > >
> > > Issue starts with these messages:
> > > [   41.818966] BUG: unable to handle page fault for address: fffff54c=
f8000028
> > > [   14.458709] general protection fault: 0000 [#1] SMP PTI
> > > [   14.143173] kernel BUG at lib/list_debug.c:54!
> > > [  127.971860] kernel BUG at include/linux/mm.h:607!
> > >
> > >
> > > [3.] Keywords (i.e., modules, networking, kernel):
> > >
> > > zswap z3fold swapping swap bisect
> > >
> > >
> > > [4.] Kernel information
> > >
> > > [4.1.] Kernel version (from /proc/version):
> > >
> > > $ cat /proc/version
> > > Linux version 5.3.0-rc4 (maage@workstation.lan) (gcc version 9.1.1
> > > 20190503 (Red Hat 9.1.1-1) (GCC)) #69 SMP Fri Aug 16 19:52:23 EEST
> > > 2019
> > >
> > >
> > > [4.2.] Kernel .config file:
> > >
> > > Attached as config-5.3.0-rc4
> > >
> > > My vanilla kernel config is based on Fedora kernel kernel config, but
> > > most drivers not used in testing machine disabled to speed up test
> > > builds.
> > >
> > >
> > > [5.] Most recent kernel version which did not have the bug:
> > >
> > > I'm able to reproduce the issue in vanilla v5.3-rc4 and what ever cam=
e
> > > as bad during git bisect from v5.1 (good) and v5.3-rc4 (bad). And I
> > > can also reproduce issue with some Fedora kernels, at least from
> > > 5.2.1-200.fc30.x86_64 on. About Fedora kernels:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D1740690
> > >
> > > Result from git bisect:
> > >
> > > 7c2b8baa61fe578af905342938ad12f8dbaeae79 is the first bad commit
> > >
> > > commit 7c2b8baa61fe578af905342938ad12f8dbaeae79
> > > Author: Vitaly Wool <vitalywool@gmail.com>
> > > Date:   Mon May 13 17:22:49 2019 -0700
> > >
> > >     mm/z3fold.c: add structure for buddy handles
> > >
> > >     For z3fold to be able to move its pages per request of the memory
> > >     subsystem, it should not use direct object addresses in handles. =
 Instead,
> > >     it will create abstract handles (3 per page) which will contain p=
ointers
> > >     to z3fold objects.  Thus, it will be possible to change these poi=
nters
> > >     when z3fold page is moved.
> > >
> > >     Link: http://lkml.kernel.org/r/20190417103826.484eaf18c1294d68276=
9880f@gmail.com
> > >     Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
> > >     Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > >     Cc: Dan Streetman <ddstreet@ieee.org>
> > >     Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> > >     Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
> > >     Cc: Uladzislau Rezki <urezki@gmail.com>
> > >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> > >
> > > :040000 040000 1a27b311b3ad8556062e45fff84d46a57ba8a4b1
> > > a79e463e14ab8ea271a89fb5f3069c3c84221478 M mm
> > > bisect run success
> > >
> > >
> > > [6.] Output of Oops.. message (if applicable) with symbolic informati=
on
> > >      resolved (see Documentation/admin-guide/bug-hunting.rst)
> > >
> > > 1st Full dmesg attached: dmesg-5.3.0-rc4-1566111932.476354086.txt
> > >
> > > [  105.710330] BUG: unable to handle page fault for address: ffffd2df=
8a000028
> > > [  105.714547] #PF: supervisor read access in kernel mode
> > > [  105.717893] #PF: error_code(0x0000) - not-present page
> > > [  105.721227] PGD 0 P4D 0
> > > [  105.722884] Oops: 0000 [#1] SMP PTI
> > > [  105.725152] CPU: 0 PID: 1240 Comm: stress Not tainted 5.3.0-rc4 #6=
9
> > > [  105.729219] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [  105.734756] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [  105.737801] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00
> > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e
> > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 1=
0
> > > 4c 89
> > > [  105.749901] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > [  105.753230] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX: 00000=
00000000000
> > > [  105.757754] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI: ffff9=
0edb5fdd600
> > > [  105.762362] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09: 00000=
00000000000
> > > [  105.766973] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
0edbab538d8
> > > [  105.771577] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15: ffffa=
82d809a3438
> > > [  105.776190] FS:  00007ff6a887b740(0000) GS:ffff90edbe400000(0000)
> > > knlGS:0000000000000000
> > > [  105.780549] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  105.781436] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4: 00000=
00000160ef0
> > > [  105.782365] Call Trace:
> > > [  105.782668]  zswap_writeback_entry+0x50/0x410
> > > [  105.783199]  z3fold_zpool_shrink+0x4a6/0x540
> > > [  105.783717]  zswap_frontswap_store+0x424/0x7c1
> > > [  105.784329]  __frontswap_store+0xc4/0x162
> > > [  105.784815]  swap_writepage+0x39/0x70
> > > [  105.785282]  pageout.isra.0+0x12c/0x5d0
> > > [  105.785730]  shrink_page_list+0x1124/0x1830
> > > [  105.786335]  shrink_inactive_list+0x1da/0x460
> > > [  105.786882]  ? lruvec_lru_size+0x10/0x130
> > > [  105.787472]  shrink_node_memcg+0x202/0x770
> > > [  105.788011]  ? sched_clock_cpu+0xc/0xc0
> > > [  105.788594]  shrink_node+0xdc/0x4a0
> > > [  105.789012]  do_try_to_free_pages+0xdb/0x3c0
> > > [  105.789528]  try_to_free_pages+0x112/0x2e0
> > > [  105.790009]  __alloc_pages_slowpath+0x422/0x1000
> > > [  105.790547]  ? __lock_acquire+0x247/0x1900
> > > [  105.791040]  __alloc_pages_nodemask+0x37f/0x400
> > > [  105.791580]  alloc_pages_vma+0x79/0x1e0
> > > [  105.792064]  __read_swap_cache_async+0x1ec/0x3e0
> > > [  105.792639]  swap_cluster_readahead+0x184/0x330
> > > [  105.793194]  ? find_held_lock+0x32/0x90
> > > [  105.793681]  swapin_readahead+0x2b4/0x4e0
> > > [  105.794182]  ? sched_clock_cpu+0xc/0xc0
> > > [  105.794668]  do_swap_page+0x3ac/0xc30
> > > [  105.795658]  __handle_mm_fault+0x8dd/0x1900
> > > [  105.796729]  handle_mm_fault+0x159/0x340
> > > [  105.797723]  do_user_addr_fault+0x1fe/0x480
> > > [  105.798736]  do_page_fault+0x31/0x210
> > > [  105.799700]  page_fault+0x3e/0x50
> > > [  105.800597] RIP: 0033:0x56076f49e298
> > > [  105.801561] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d
> > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39
> > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0=
f
> > > 89 de
> > > [  105.804770] RSP: 002b:00007ffe5fc72e70 EFLAGS: 00010206
> > > [  105.805931] RAX: 00000000013ad000 RBX: ffffffffffffffff RCX: 00007=
ff6a8974156
> > > [  105.807300] RDX: 0000000000000000 RSI: 000000000b78d000 RDI: 00000=
00000000000
> > > [  105.808679] RBP: 00007ff69d0ee010 R08: 00007ff69d0ee010 R09: 00000=
00000000000
> > > [  105.810055] R10: 00007ff69e49a010 R11: 0000000000000246 R12: 00005=
6076f4a0004
> > > [  105.811383] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b78cc00
> > > [  105.812713] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > net_failover intel_agp failover intel_gtt qxl drm_kms_helper
> > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> > > serio_raw agpgart virtio_blk virtio_console qemu_fw_cfg
> > > [  105.821561] CR2: ffffd2df8a000028
> > > [  105.822552] ---[ end trace d5f24e2cb83a2b76 ]---
> > > [  105.823659] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [  105.824785] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00
> > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e
> > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 1=
0
> > > 4c 89
> > > [  105.828082] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > [  105.829287] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX: 00000=
00000000000
> > > [  105.830713] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI: ffff9=
0edb5fdd600
> > > [  105.832157] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09: 00000=
00000000000
> > > [  105.833607] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
0edbab538d8
> > > [  105.835054] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15: ffffa=
82d809a3438
> > > [  105.836489] FS:  00007ff6a887b740(0000) GS:ffff90edbe400000(0000)
> > > knlGS:0000000000000000
> > > [  105.838103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  105.839405] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4: 00000=
00000160ef0
> > > [  105.840883] ------------[ cut here ]------------
> > >
> > >
> > > (gdb) l *zswap_writeback_entry+0x50
> > > 0xffffffff812e8490 is in zswap_writeback_entry (/src/linux/mm/zswap.c=
:858).
> > > 853 .sync_mode =3D WB_SYNC_NONE,
> > > 854 };
> > > 855
> > > 856 /* extract swpentry from data */
> > > 857 zhdr =3D zpool_map_handle(pool, handle, ZPOOL_MM_RO);
> > > 858 swpentry =3D zhdr->swpentry; /* here */
> > > 859 zpool_unmap_handle(pool, handle);
> > > 860 tree =3D zswap_trees[swp_type(swpentry)];
> > > 861 offset =3D swp_offset(swpentry);
> > >
> > >
> > > (gdb) l *z3fold_zpool_map+0x52
> > > 0xffffffff81337b32 is in z3fold_zpool_map
> > > (/src/linux/arch/x86/include/asm/bitops.h:207).
> > > 202 return GEN_BINARY_RMWcc(LOCK_PREFIX __ASM_SIZE(btc), *addr, c, "I=
r", nr);
> > > 203 }
> > > 204
> > > 205 static __always_inline bool constant_test_bit(long nr, const
> > > volatile unsigned long *addr)
> > > 206 {
> > > 207 return ((1UL << (nr & (BITS_PER_LONG-1))) &
> > > 208 (addr[nr >> _BITOPS_LONG_SHIFT])) !=3D 0;
> > > 209 }
> > > 210
> > > 211 static __always_inline bool variable_test_bit(long nr, volatile
> > > const unsigned long *addr)
> > >
> > >
> > > (gdb) l *z3fold_zpool_shrink+0x4a6
> > > 0xffffffff81338796 is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:=
1173).
> > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > 1169 if (ret)
> > > 1170 goto next;
> > > 1171 }
> > > 1172 if (last_handle) {
> > > 1173 ret =3D pool->ops->evict(pool, last_handle);
> > > 1174 if (ret)
> > > 1175 goto next;
> > > 1176 }
> > > 1177 next:
> > >
> > >
> > > Because of test setup and swapping, usually ssh/shell etc are stuck
> > > and it is not possible to get dmesg of other situations. So I've used
> > > console logging. It misses other boot messages though. They should be
> > > about the same as 1st case.
> > >
> > >
> > > 2st console log attached: console-1566133726.340057021.log
> > >
> > > [   14.324867] general protection fault: 0000 [#1] SMP PTI
> > > [   14.330269] CPU: 1 PID: 150 Comm: kswapd0 Tainted: G        W
> > >   5.3.0-rc4 #69
> > > [   14.331359] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [   14.332511] RIP: 0010:handle_to_buddy+0x20/0x30
> > > [   14.333478] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 53
> > > 48 89 fb 83 e7 01 0f 85 01 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00
> > > f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 0=
0
> > > 00 55
> > > [   14.336310] RSP: 0000:ffffb6cc0019f820 EFLAGS: 00010206
> > > [   14.337112] RAX: 00ffff8b24c22ed0 RBX: fffff46a4008bb40 RCX: 00000=
00000000000
> > > [   14.338174] RDX: 00ffff8b24c22000 RSI: ffff8b24fe7d89c8 RDI: ffff8=
b24fe7d89c8
> > > [   14.339112] RBP: ffff8b24c22ed000 R08: ffff8b24fe7d89c8 R09: 00000=
00000000000
> > > [   14.340407] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
b24c22ed001
> > > [   14.341445] R13: ffff8b24c22ed010 R14: ffff8b24f5f70a00 R15: ffffb=
6cc0019f868
> > > [   14.342439] FS:  0000000000000000(0000) GS:ffff8b24fe600000(0000)
> > > knlGS:0000000000000000
> > > [   14.343937] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   14.344771] CR2: 00007f37563d4010 CR3: 0000000008212005 CR4: 00000=
00000160ee0
> > > [   14.345816] Call Trace:
> > > [   14.346182]  z3fold_zpool_map+0x76/0x110
> > > [   14.347111]  zswap_writeback_entry+0x50/0x410
> > > [   14.347828]  z3fold_zpool_shrink+0x3c4/0x540
> > > [   14.348457]  zswap_frontswap_store+0x424/0x7c1
> > > [   14.349134]  __frontswap_store+0xc4/0x162
> > > [   14.349746]  swap_writepage+0x39/0x70
> > > [   14.350292]  pageout.isra.0+0x12c/0x5d0
> > > [   14.350899]  shrink_page_list+0x1124/0x1830
> > > [   14.351473]  shrink_inactive_list+0x1da/0x460
> > > [   14.352068]  shrink_node_memcg+0x202/0x770
> > > [   14.352697]  shrink_node+0xdc/0x4a0
> > > [   14.353204]  balance_pgdat+0x2e7/0x580
> > > [   14.353773]  kswapd+0x239/0x500
> > > [   14.354241]  ? finish_wait+0x90/0x90
> > > [   14.355003]  kthread+0x108/0x140
> > > [   14.355619]  ? balance_pgdat+0x580/0x580
> > > [   14.356216]  ? kthread_park+0x80/0x80
> > > [   14.356782]  ret_from_fork+0x3a/0x50
> > > [   14.357859] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_net net_failover
> > > virtio_balloon failover intel_agp intel_gtt qxl drm_kms_helper
> > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> > > serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg
> > > [   14.369818] ---[ end trace 351ba6e5814522bd ]---
> > >
> > >
> > > (gdb) l *z3fold_zpool_map+0x76
> > > 0xffffffff81337b56 is in z3fold_zpool_map (/src/linux/mm/z3fold.c:123=
9).
> > > 1234 if (test_bit(PAGE_HEADLESS, &page->private))
> > > 1235 goto out;
> > > 1236
> > > 1237 z3fold_page_lock(zhdr);
> > > 1238 buddy =3D handle_to_buddy(handle);
> > > 1239 switch (buddy) {
> > > 1240 case FIRST:
> > > 1241 addr +=3D ZHDR_SIZE_ALIGNED;
> > > 1242 break;
> > > 1243 case MIDDLE:
> > >
> > > (gdb) l *z3fold_zpool_shrink+0x3c4
> > > 0xffffffff813386b4 is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:=
1168).
> > > 1163 ret =3D pool->ops->evict(pool, middle_handle);
> > > 1164 if (ret)
> > > 1165 goto next;
> > > 1166 }
> > > 1167 if (first_handle) {
> > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > 1169 if (ret)
> > > 1170 goto next;
> > > 1171 }
> > > 1172 if (last_handle) {
> > >
> > > (gdb) l *handle_to_buddy+0x20
> > > 0xffffffff81337550 is in handle_to_buddy (/src/linux/mm/z3fold.c:425)=
.
> > > 420 unsigned long addr;
> > > 421
> > > 422 WARN_ON(handle & (1 << PAGE_HEADLESS));
> > > 423 addr =3D *(unsigned long *)handle;
> > > 424 zhdr =3D (struct z3fold_header *)(addr & PAGE_MASK);
> > > 425 return (addr - zhdr->first_num) & BUDDY_MASK;
> > > 426 }
> > > 427
> > > 428 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_head=
er *zhdr)
> > > 429 {
> > >
> > >
> > > 3st console log attached: console-1566146080.512045588.log
> > >
> > > [ 4180.615506] kernel BUG at lib/list_debug.c:54!
> > > [ 4180.617034] invalid opcode: 0000 [#1] SMP PTI
> > > [ 4180.618059] CPU: 3 PID: 2129 Comm: stress Tainted: G        W
> > >   5.3.0-rc4 #69
> > > [ 4180.619811] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [ 4180.621757] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > [ 4180.623035] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89 fe
> > > 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8 36
> > > 7e bf ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e bf f=
f
> > > 0f 0b
> > > [ 4180.627262] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > [ 4180.628459] RAX: 0000000000000054 RBX: ffff88a102053000 RCX: 00000=
00000000000
> > > [ 4180.630077] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI: ffff8=
8a13bbd89c8
> > > [ 4180.631693] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09: 00000=
00000000000
> > > [ 4180.633271] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13098a200
> > > [ 4180.634899] R13: ffff88a13098a208 R14: 0000000000000000 R15: ffff8=
8a102053010
> > > [ 4180.636539] FS:  00007f86b900e740(0000) GS:ffff88a13ba00000(0000)
> > > knlGS:0000000000000000
> > > [ 4180.638394] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4180.639733] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4: 00000=
00000160ee0
> > > [ 4180.641383] Call Trace:
> > > [ 4180.641965]  z3fold_zpool_malloc+0x106/0xa40
> > > [ 4180.642965]  zswap_frontswap_store+0x2e8/0x7c1
> > > [ 4180.643978]  __frontswap_store+0xc4/0x162
> > > [ 4180.644875]  swap_writepage+0x39/0x70
> > > [ 4180.645695]  pageout.isra.0+0x12c/0x5d0
> > > [ 4180.646553]  shrink_page_list+0x1124/0x1830
> > > [ 4180.647538]  shrink_inactive_list+0x1da/0x460
> > > [ 4180.648564]  shrink_node_memcg+0x202/0x770
> > > [ 4180.649529]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4180.650432]  shrink_node+0xdc/0x4a0
> > > [ 4180.651258]  do_try_to_free_pages+0xdb/0x3c0
> > > [ 4180.652261]  try_to_free_pages+0x112/0x2e0
> > > [ 4180.653217]  __alloc_pages_slowpath+0x422/0x1000
> > > [ 4180.654294]  ? __lock_acquire+0x247/0x1900
> > > [ 4180.655254]  __alloc_pages_nodemask+0x37f/0x400
> > > [ 4180.656312]  alloc_pages_vma+0x79/0x1e0
> > > [ 4180.657169]  __read_swap_cache_async+0x1ec/0x3e0
> > > [ 4180.658197]  swap_cluster_readahead+0x184/0x330
> > > [ 4180.659211]  ? find_held_lock+0x32/0x90
> > > [ 4180.660111]  swapin_readahead+0x2b4/0x4e0
> > > [ 4180.661046]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4180.661949]  do_swap_page+0x3ac/0xc30
> > > [ 4180.662807]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4180.663790]  handle_mm_fault+0x159/0x340
> > > [ 4180.664713]  do_user_addr_fault+0x1fe/0x480
> > > [ 4180.665691]  do_page_fault+0x31/0x210
> > > [ 4180.666552]  page_fault+0x3e/0x50
> > > [ 4180.667818] RIP: 0033:0x555b3127d298
> > > [ 4180.669153] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d
> > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39
> > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0=
f
> > > 89 de
> > > [ 4180.676117] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4180.678515] RAX: 0000000000038000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4180.681657] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4180.684762] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4180.687846] R10: 00007f86ad840010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4180.690919] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> > > [ 4180.693967] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon
> > > net_failover intel_agp failover intel_gtt qxl drm_kms_helper
> > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> > > serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg
> > > [ 4180.715768] ---[ end trace 6eab0ae003d4d2ea ]---
> > > [ 4180.718021] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > [ 4180.720602] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89 fe
> > > 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8 36
> > > 7e bf ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e bf f=
f
> > > 0f 0b
> > > [ 4180.728474] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > [ 4180.730969] RAX: 0000000000000054 RBX: ffff88a102053000 RCX: 00000=
00000000000
> > > [ 4180.734130] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI: ffff8=
8a13bbd89c8
> > > [ 4180.737285] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09: 00000=
00000000000
> > > [ 4180.740442] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13098a200
> > > [ 4180.743609] R13: ffff88a13098a208 R14: 0000000000000000 R15: ffff8=
8a102053010
> > > [ 4180.746774] FS:  00007f86b900e740(0000) GS:ffff88a13ba00000(0000)
> > > knlGS:0000000000000000
> > > [ 4180.750294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4180.752986] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4: 00000=
00000160ee0
> > > [ 4180.756176] ------------[ cut here ]------------
> > >
> > > (gdb) l *z3fold_zpool_malloc+0x106
> > > 0xffffffff81338936 is in z3fold_zpool_malloc
> > > (/src/linux/include/linux/list.h:190).
> > > 185 * list_del_init - deletes entry from list and reinitialize it.
> > > 186 * @entry: the element to delete from the list.
> > > 187 */
> > > 188 static inline void list_del_init(struct list_head *entry)
> > > 189 {
> > > 190 __list_del_entry(entry);
> > > 191 INIT_LIST_HEAD(entry);
> > > 192 }
> > > 193
> > > 194 /**
> > >
> > > (gdb) l *zswap_frontswap_store+0x2e8
> > > 0xffffffff812e8b38 is in zswap_frontswap_store (/src/linux/mm/zswap.c=
:1073).
> > > 1068 goto put_dstmem;
> > > 1069 }
> > > 1070
> > > 1071 /* store */
> > > 1072 hlen =3D zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) : 0;
> > > 1073 ret =3D zpool_malloc(entry->pool->zpool, hlen + dlen,
> > > 1074    __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> > > 1075    &handle);
> > > 1076 if (ret =3D=3D -ENOSPC) {
> > > 1077 zswap_reject_compress_poor++;
> > >
> > >
> > > 4th console log attached: console-1566151496.204958451.log
> > >
> > > [   66.090333] BUG: unable to handle page fault for address: ffffeab2=
e2000028
> > > [   66.091245] #PF: supervisor read access in kernel mode
> > > [   66.091904] #PF: error_code(0x0000) - not-present page
> > > [   66.092552] PGD 0 P4D 0
> > > [   66.092885] Oops: 0000 [#1] SMP PTI
> > > [   66.093332] CPU: 2 PID: 1193 Comm: stress Not tainted 5.3.0-rc4 #6=
9
> > > [   66.094127] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [   66.095204] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.095799] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00
> > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e
> > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 1=
0
> > > 4c 89
> > > [   66.098132] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.098792] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.099685] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.100579] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.101477] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.102367] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.103263] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000)
> > > knlGS:0000000000000000
> > > [   66.104264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.104988] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4: 00000=
00000160ee0
> > > [   66.105878] Call Trace:
> > > [   66.106202]  zswap_writeback_entry+0x50/0x410
> > > [   66.106761]  z3fold_zpool_shrink+0x29d/0x540
> > > [   66.107305]  zswap_frontswap_store+0x424/0x7c1
> > > [   66.107870]  __frontswap_store+0xc4/0x162
> > > [   66.108383]  swap_writepage+0x39/0x70
> > > [   66.108847]  pageout.isra.0+0x12c/0x5d0
> > > [   66.109340]  shrink_page_list+0x1124/0x1830
> > > [   66.109872]  shrink_inactive_list+0x1da/0x460
> > > [   66.110430]  shrink_node_memcg+0x202/0x770
> > > [   66.110955]  shrink_node+0xdc/0x4a0
> > > [   66.111403]  do_try_to_free_pages+0xdb/0x3c0
> > > [   66.111946]  try_to_free_pages+0x112/0x2e0
> > > [   66.112468]  __alloc_pages_slowpath+0x422/0x1000
> > > [   66.113064]  ? __lock_acquire+0x247/0x1900
> > > [   66.113596]  __alloc_pages_nodemask+0x37f/0x400
> > > [   66.114179]  alloc_pages_vma+0x79/0x1e0
> > > [   66.114675]  __handle_mm_fault+0x99c/0x1900
> > > [   66.115218]  handle_mm_fault+0x159/0x340
> > > [   66.115719]  do_user_addr_fault+0x1fe/0x480
> > > [   66.116256]  do_page_fault+0x31/0x210
> > > [   66.116730]  page_fault+0x3e/0x50
> > > [   66.117168] RIP: 0033:0x556945873250
> > > [   66.117624] Code: 0f 84 88 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94
> > > c0 89 04 24 41 83 fd 02 0f 8f f1 00 00 00 31 c0 4d 85 ff 7e 12 0f 1f
> > > 44 00 00 <c6> 44 05 00 5a 4c 01 f0 49 39 c7 7f f3 48 85 db 0f 84 dd 0=
1
> > > 00 00
> > > [   66.120514] RSP: 002b:00007fffa5fc06c0 EFLAGS: 00010206
> > > [   66.121722] RAX: 000000000a0ad000 RBX: ffffffffffffffff RCX: 00007=
f33df724156
> > > [   66.123171] RDX: 0000000000000000 RSI: 000000000b7a4000 RDI: 00000=
00000000000
> > > [   66.124616] RBP: 00007f33d3e87010 R08: 00007f33d3e87010 R09: 00000=
00000000000
> > > [   66.126064] R10: 0000000000000022 R11: 0000000000000246 R12: 00005=
56945875004
> > > [   66.127499] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b7a3000
> > > [   66.128936] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net
> > > net_failover failover intel_gtt qxl drm_kms_helper syscopyarea
> > > sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw
> > > virtio_blk virtio_console agpgart qemu_fw_cfg
> > > [   66.138533] CR2: ffffeab2e2000028
> > > [   66.139562] ---[ end trace bfa9f40a545e4544 ]---
> > > [   66.140733] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.141886] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00
> > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e
> > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 1=
0
> > > 4c 89
> > > [   66.145387] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.146654] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.148137] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.149626] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.151128] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.152606] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.154076] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000)
> > > knlGS:0000000000000000
> > > [   66.155695] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.157020] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4: 00000=
00000160ee0
> > > [   66.158535] ------------[ cut here ]------------
> > >
> > > (gdb) l *z3fold_zpool_shrink+0x29d
> > > 0xffffffff8133858d is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:=
1168).
> > > 1163 ret =3D pool->ops->evict(pool, middle_handle);
> > > 1164 if (ret)
> > > 1165 goto next;
> > > 1166 }
> > > 1167 if (first_handle) {
> > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > 1169 if (ret)
> > > 1170 goto next;
> > > 1171 }
> > > 1172 if (last_handle) {
> > >
> > >
> > > 5th console log is: console-1566152424.019311951.log
> > > [   22.529023] kernel BUG at include/linux/mm.h:607!
> > > [   22.529092] BUG: kernel NULL pointer dereference, address: 0000000=
000000008
> > > [   22.531789] #PF: supervisor read access in kernel mode
> > > [   22.532954] #PF: error_code(0x0000) - not-present page
> > > [   22.533722] PGD 0 P4D 0
> > > [   22.534097] Oops: 0000 [#1] SMP PTI
> > > [   22.534585] CPU: 0 PID: 186 Comm: kworker/u8:4 Not tainted 5.3.0-r=
c4 #69
> > > [   22.535488] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [   22.536633] Workqueue: zswap1 compact_page_work
> > > [   22.537263] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.537868] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00
> > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90
> > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0=
f
> > > 85 98
> > > [   22.540322] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.540953] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.541838] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.542747] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.543660] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.544614] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.545578] FS:  0000000000000000(0000) GS:ffff8d69be400000(0000)
> > > knlGS:0000000000000000
> > > [   22.546662] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.547452] CR2: 0000000000000008 CR3: 0000000035304001 CR4: 00000=
00000160ef0
> > > [   22.548488] Call Trace:
> > > [   22.548845]  do_compact_page+0x31e/0x430
> > > [   22.549406]  process_one_work+0x272/0x5a0
> > > [   22.549972]  worker_thread+0x50/0x3b0
> > > [   22.550488]  kthread+0x108/0x140
> > > [   22.550939]  ? process_one_work+0x5a0/0x5a0
> > > [   22.551531]  ? kthread_park+0x80/0x80
> > > [   22.552034]  ret_from_fork+0x3a/0x50
> > > [   22.552554] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > net_failover intel_agp intel_gtt failover qxl drm_kms_helper
> > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> > > serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg
> > > [   22.559889] CR2: 0000000000000008
> > > [   22.560328] ---[ end trace cfa4596e38137687 ]---
> > > [   22.560330] invalid opcode: 0000 [#2] SMP PTI
> > > [   22.560981] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.561515] CPU: 2 PID: 1063 Comm: stress Tainted: G      D
> > >   5.3.0-rc4 #69
> > > [   22.562143] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00
> > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90
> > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0=
f
> > > 85 98
> > > [   22.563034] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> > > BIOS 1.12.0-2.fc30 04/01/2014
> > > [   22.565759] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.565760] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.565761] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.565761] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.565762] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.565763] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.565765] FS:  0000000000000000(0000) GS:ffff8d69be400000(0000)
> > > knlGS:0000000000000000
> > > [   22.565766] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.565766] CR2: 0000000000000008 CR3: 0000000035304001 CR4: 00000=
00000160ef0
> > > [   22.565797] note: kworker/u8:4[186] exited with preempt_count 3
> > > [   22.581957] RIP: 0010:__free_pages+0x2d/0x30
> > > [   22.583146] Code: 00 00 8b 47 34 85 c0 74 15 f0 ff 4f 34 75 09 85
> > > f6 75 06 e9 75 ff ff ff c3 e9 4f e2 ff ff 48 c7 c6 e8 8c 0a bb e8 d3
> > > 7f fd ff <0f> 0b 90 0f 1f 44 00 00 89 f1 41 bb 01 00 00 00 49 89 fa 4=
1
> > > d3 e3
> > > [   22.586649] RSP: 0018:ffffa073809ef4d0 EFLAGS: 00010246
> > > [   22.587963] RAX: 000000000000003e RBX: ffff8d6992d10000 RCX: 00000=
00000000006
> > > [   22.589579] RDX: 0000000000000000 RSI: 0000000000000000 RDI: fffff=
fffbb0e5774
> > > [   22.591181] RBP: ffffd090004b4408 R08: 000000053ed5634a R09: 00000=
00000000000
> > > [   22.592781] R10: 0000000000000000 R11: 0000000000000000 R12: ffffd=
090004b4400
> > > [   22.594339] R13: ffff8d69bd0dfca0 R14: ffff8d69bd0dfc00 R15: ffff8=
d69bd0dfc08
> > > [   22.595832] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000)
> > > knlGS:0000000000000000
> > > [   22.598649] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.601196] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4: 00000=
00000160ee0
> > > [   22.603539] Call Trace:
> > > [   22.605103]  z3fold_zpool_shrink+0x25f/0x540
> > > [   22.607218]  zswap_frontswap_store+0x424/0x7c1
> > > [   22.609115]  __frontswap_store+0xc4/0x162
> > > [   22.610819]  swap_writepage+0x39/0x70
> > > [   22.612525]  pageout.isra.0+0x12c/0x5d0
> > > [   22.613957]  shrink_page_list+0x1124/0x1830
> > > [   22.615130]  shrink_inactive_list+0x1da/0x460
> > > [   22.616311]  shrink_node_memcg+0x202/0x770
> > > [   22.617473]  ? sched_clock_cpu+0xc/0xc0
> > > [   22.619145]  shrink_node+0xdc/0x4a0
> > > [   22.620279]  do_try_to_free_pages+0xdb/0x3c0
> > > [   22.621450]  try_to_free_pages+0x112/0x2e0
> > > [   22.622582]  __alloc_pages_slowpath+0x422/0x1000
> > > [   22.623749]  ? __lock_acquire+0x247/0x1900
> > > [   22.624876]  __alloc_pages_nodemask+0x37f/0x400
> > > [   22.626007]  alloc_pages_vma+0x79/0x1e0
> > > [   22.627040]  __read_swap_cache_async+0x1ec/0x3e0
> > > [   22.628143]  swap_cluster_readahead+0x184/0x330
> > > [   22.629234]  ? find_held_lock+0x32/0x90
> > > [   22.630292]  swapin_readahead+0x2b4/0x4e0
> > > [   22.631370]  ? sched_clock_cpu+0xc/0xc0
> > > [   22.632379]  do_swap_page+0x3ac/0xc30
> > > [   22.633356]  __handle_mm_fault+0x8dd/0x1900
> > > [   22.634373]  handle_mm_fault+0x159/0x340
> > > [   22.635714]  do_user_addr_fault+0x1fe/0x480
> > > [   22.636738]  do_page_fault+0x31/0x210
> > > [   22.637674]  page_fault+0x3e/0x50
> > > [   22.638559] RIP: 0033:0x562b503bd298
> > > [   22.639476] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d
> > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39
> > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0=
f
> > > 89 de
> > > [   22.642658] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > [   22.643900] RAX: 0000000000f09000 RBX: ffffffffffffffff RCX: 00007=
f48317b0156
> > > [   22.645242] RDX: 0000000000000000 RSI: 000000000b276000 RDI: 00000=
00000000000
> > > [   22.646571] RBP: 00007f4826441010 R08: 00007f4826441010 R09: 00000=
00000000000
> > > [   22.647888] R10: 00007f4827349010 R11: 0000000000000246 R12: 00005=
62b503bf004
> > > [   22.649210] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b275800
> > > [   22.650518] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > net_failover intel_agp intel_gtt failover qxl drm_kms_helper
> > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> > > serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg
> > > [   22.659276] ---[ end trace cfa4596e38137688 ]---
> > > [   22.660398] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.661493] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00
> > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90
> > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0=
f
> > > 85 98
> > > [   22.664800] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.666779] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.669830] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.672878] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.675920] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.678966] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.682014] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000)
> > > knlGS:0000000000000000
> > > [   22.685399] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.687991] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4: 00000=
00000160ee0
> > > [   22.691068] ------------[ cut here ]------------
> > >
> > > (gdb) l *__list_add_valid+0x3
> > > 0xffffffff81551b43 is in __list_add_valid
> > > (/srv/s_maage/pkg/linux/linux/lib/list_debug.c:23).
> > > 18 */
> > > 19
> > > 20 bool __list_add_valid(struct list_head *new, struct list_head *pre=
v,
> > > 21       struct list_head *next)
> > > 22 {
> > > 23 if (CHECK_DATA_CORRUPTION(next->prev !=3D prev,
> > > 24 "list_add corruption. next->prev should be prev (%px), but was %px=
.
> > > (next=3D%px).\n",
> > > 25 prev, next->prev, next) ||
> > > 26     CHECK_DATA_CORRUPTION(prev->next !=3D next,
> > > 27 "list_add corruption. prev->next should be next (%px), but was %px=
.
> > > (prev=3D%px).\n",
> > >
> > > (gdb) l *do_compact_page+0x31e
> > > 0xffffffff813396fe is in do_compact_page
> > > (/srv/s_maage/pkg/linux/linux/include/linux/list.h:60).
> > > 55 */
> > > 56 static inline void __list_add(struct list_head *new,
> > > 57       struct list_head *prev,
> > > 58       struct list_head *next)
> > > 59 {
> > > 60 if (!__list_add_valid(new, prev, next))
> > > 61 return;
> > > 62
> > > 63 next->prev =3D new;
> > > 64 new->next =3D next;
> > >
> > > (gdb) l *z3fold_zpool_shrink+0x25f
> > > 0xffffffff8133854f is in z3fold_zpool_shrink
> > > (/srv/s_maage/pkg/linux/linux/arch/x86/include/asm/atomic64_64.h:102)=
.
> > > 97 *
> > > 98 * Atomically decrements @v by 1.
> > > 99 */
> > > 100 static __always_inline void arch_atomic64_dec(atomic64_t *v)
> > > 101 {
> > > 102 asm volatile(LOCK_PREFIX "decq %0"
> > > 103      : "=3Dm" (v->counter)
> > > 104      : "m" (v->counter) : "memory");
> > > 105 }
> > > 106 #define arch_atomic64_dec arch_atomic64_dec
> > >
> > > (gdb) l *zswap_frontswap_store+0x424
> > > 0xffffffff812e8c74 is in zswap_frontswap_store
> > > (/srv/s_maage/pkg/linux/linux/mm/zswap.c:955).
> > > 950
> > > 951 pool =3D zswap_pool_last_get();
> > > 952 if (!pool)
> > > 953 return -ENOENT;
> > > 954
> > > 955 ret =3D zpool_shrink(pool->zpool, 1, NULL);
> > > 956
> > > 957 zswap_pool_put(pool);
> > > 958
> > > 959 return ret;
> > >
> > >
> > >
> > > [7.] A small shell script or example program which triggers the
> > > problem (if possible)
> > >
> > > for tmout in 10 10 10 20 20 20 30 120 $((3600/2)) 10; do
> > >     stress --vm $(($(nproc)+2)) --vm-bytes $(($(awk
> > > '"'"'/MemAvail/{print $2}'"'"' /proc/meminfo)*1024/$(nproc)))
> > > --timeout '"$tmout"
> > > done
> > >
> > >
> > > [8.] Environment
> > >
> > > My test machine is Fedora 30 (minimal install) virtual machine runnin=
g
> > > 4 vCPU and 1GiB RAM and 2GiB swap. Origninally I noticed the problem
> > > in other machines (Fedora 30). I guess any amount of memory pressure
> > > and zswap activation can cause problems.
> > >
> > > Test machine does only have whatever comes from install and whatever
> > > is enabled by default. Then I've also enabled serial console
> > > "console=3Dtty0 console=3DttyS0". Enabled passwordless sudo to help
> > > testing and then installed "stress."
> > >
> > > stress package version is stress-1.0.4-22.fc30
> > >
> > >
> > > [8.1.] Software (add the output of the ver_linux script here)
> > >
> > > $ ./ver_linux
> > > If some fields are empty or look unusual you may have an old version.
> > > Compare to the current minimal requirements in Documentation/Changes.
> > >
> > > Linux localhost.localdomain 5.3.0-rc4 #69 SMP Fri Aug 16 19:52:23 EES=
T
> > > 2019 x86_64 x86_64 x86_64 GNU/Linux
> > >
> > > Util-linux          2.33.2
> > > Mount                2.33.2
> > > Module-init-tools    25
> > > E2fsprogs            1.44.6
> > > Linux C Library      2.29
> > > Dynamic linker (ldd) 2.29
> > > Linux C++ Library    6.0.26
> > > Procps              3.3.15
> > > Kbd                  2.0.4
> > > Console-tools        2.0.4
> > > Sh-utils            8.31
> > > Udev                241
> > > Modules Loaded      agpgart crc32c_intel crc32_pclmul crct10dif_pclmu=
l
> > > drm drm_kms_helper failover fb_sys_fops ghash_clmulni_intel intel_agp
> > > intel_gtt ip6table_filter ip6table_mangle ip6table_nat ip6table_raw
> > > ip6_tables ip6table_security ip6t_REJECT ip6t_rpfilter ip_set
> > > iptable_filter iptable_mangle iptable_nat iptable_raw ip_tables
> > > iptable_security ipt_REJECT libcrc32c net_failover nf_conntrack
> > > nf_defrag_ipv4 nf_defrag_ipv6 nf_nat nfnetlink nf_reject_ipv4
> > > nf_reject_ipv6 qemu_fw_cfg qxl serio_raw syscopyarea sysfillrect
> > > sysimgblt ttm virtio_balloon virtio_blk virtio_console virtio_net
> > > xt_conntrack
> > >
> > >
> > > [8.2.] Processor information (from /proc/cpuinfo):
> > >
> > > $ cat /proc/cpuinfo
> > > processor : 0
> > > vendor_id : GenuineIntel
> > > cpu family : 6
> > > model : 60
> > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > stepping : 1
> > > microcode : 0x1
> > > cpu MHz : 3198.099
> > > cache size : 16384 KB
> > > physical id : 0
> > > siblings : 1
> > > core id : 0
> > > cpu cores : 1
> > > apicid : 0
> > > initial apicid : 0
> > > fpu : yes
> > > fpu_exception : yes
> > > cpuid level : 13
> > > wp : yes
> > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm
> > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse3 fm=
a
> > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes
> > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ept
> > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > xsaveopt arat umip md_clear
> > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds =
swapgs
> > > bogomips : 6396.19
> > > clflush size : 64
> > > cache_alignment : 64
> > > address sizes : 40 bits physical, 48 bits virtual
> > > power management:
> > >
> > > processor : 1
> > > vendor_id : GenuineIntel
> > > cpu family : 6
> > > model : 60
> > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > stepping : 1
> > > microcode : 0x1
> > > cpu MHz : 3198.099
> > > cache size : 16384 KB
> > > physical id : 1
> > > siblings : 1
> > > core id : 0
> > > cpu cores : 1
> > > apicid : 1
> > > initial apicid : 1
> > > fpu : yes
> > > fpu_exception : yes
> > > cpuid level : 13
> > > wp : yes
> > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm
> > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse3 fm=
a
> > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes
> > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ept
> > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > xsaveopt arat umip md_clear
> > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds =
swapgs
> > > bogomips : 6468.62
> > > clflush size : 64
> > > cache_alignment : 64
> > > address sizes : 40 bits physical, 48 bits virtual
> > > power management:
> > >
> > > processor : 2
> > > vendor_id : GenuineIntel
> > > cpu family : 6
> > > model : 60
> > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > stepping : 1
> > > microcode : 0x1
> > > cpu MHz : 3198.099
> > > cache size : 16384 KB
> > > physical id : 2
> > > siblings : 1
> > > core id : 0
> > > cpu cores : 1
> > > apicid : 2
> > > initial apicid : 2
> > > fpu : yes
> > > fpu_exception : yes
> > > cpuid level : 13
> > > wp : yes
> > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm
> > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse3 fm=
a
> > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes
> > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ept
> > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > xsaveopt arat umip md_clear
> > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds =
swapgs
> > > bogomips : 6627.92
> > > clflush size : 64
> > > cache_alignment : 64
> > > address sizes : 40 bits physical, 48 bits virtual
> > > power management:
> > >
> > > processor : 3
> > > vendor_id : GenuineIntel
> > > cpu family : 6
> > > model : 60
> > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > stepping : 1
> > > microcode : 0x1
> > > cpu MHz : 3198.099
> > > cache size : 16384 KB
> > > physical id : 3
> > > siblings : 1
> > > core id : 0
> > > cpu cores : 1
> > > apicid : 3
> > > initial apicid : 3
> > > fpu : yes
> > > fpu_exception : yes
> > > cpuid level : 13
> > > wp : yes
> > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm
> > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse3 fm=
a
> > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes
> > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ept
> > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > xsaveopt arat umip md_clear
> > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds =
swapgs
> > > bogomips : 6662.16
> > > clflush size : 64
> > > cache_alignment : 64
> > > address sizes : 40 bits physical, 48 bits virtual
> > > power management:
> > >
> > >
> > > [8.3.] Module information (from /proc/modules):
> > >
> > > $ cat /proc/modules
> > > ip6t_rpfilter 16384 1 - Live 0x0000000000000000
> > > ip6t_REJECT 16384 2 - Live 0x0000000000000000
> > > nf_reject_ipv6 20480 1 ip6t_REJECT, Live 0x0000000000000000
> > > ipt_REJECT 16384 2 - Live 0x0000000000000000
> > > nf_reject_ipv4 16384 1 ipt_REJECT, Live 0x0000000000000000
> > > xt_conntrack 16384 13 - Live 0x0000000000000000
> > > ip6table_nat 16384 1 - Live 0x0000000000000000
> > > ip6table_mangle 16384 1 - Live 0x0000000000000000
> > > ip6table_raw 16384 1 - Live 0x0000000000000000
> > > ip6table_security 16384 1 - Live 0x0000000000000000
> > > iptable_nat 16384 1 - Live 0x0000000000000000
> > > nf_nat 126976 2 ip6table_nat,iptable_nat, Live 0x0000000000000000
> > > iptable_mangle 16384 1 - Live 0x0000000000000000
> > > iptable_raw 16384 1 - Live 0x0000000000000000
> > > iptable_security 16384 1 - Live 0x0000000000000000
> > > nf_conntrack 241664 2 xt_conntrack,nf_nat, Live 0x0000000000000000
> > > nf_defrag_ipv6 24576 1 nf_conntrack, Live 0x0000000000000000
> > > nf_defrag_ipv4 16384 1 nf_conntrack, Live 0x0000000000000000
> > > libcrc32c 16384 2 nf_nat,nf_conntrack, Live 0x0000000000000000
> > > ip_set 69632 0 - Live 0x0000000000000000
> > > nfnetlink 20480 1 ip_set, Live 0x0000000000000000
> > > ip6table_filter 16384 1 - Live 0x0000000000000000
> > > ip6_tables 36864 7
> > > ip6table_nat,ip6table_mangle,ip6table_raw,ip6table_security,ip6table_=
filter,
> > > Live 0x0000000000000000
> > > iptable_filter 16384 1 - Live 0x0000000000000000
> > > ip_tables 32768 5
> > > iptable_nat,iptable_mangle,iptable_raw,iptable_security,iptable_filte=
r,
> > > Live 0x0000000000000000
> > > crct10dif_pclmul 16384 1 - Live 0x0000000000000000
> > > crc32_pclmul 16384 0 - Live 0x0000000000000000
> > > ghash_clmulni_intel 16384 0 - Live 0x0000000000000000
> > > virtio_net 61440 0 - Live 0x0000000000000000
> > > virtio_balloon 24576 0 - Live 0x0000000000000000
> > > net_failover 24576 1 virtio_net, Live 0x0000000000000000
> > > failover 16384 1 net_failover, Live 0x0000000000000000
> > > intel_agp 24576 0 - Live 0x0000000000000000
> > > intel_gtt 24576 1 intel_agp, Live 0x0000000000000000
> > > qxl 77824 0 - Live 0x0000000000000000
> > > drm_kms_helper 221184 3 qxl, Live 0x0000000000000000
> > > syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > ttm 126976 1 qxl, Live 0x0000000000000000
> > > drm 602112 4 qxl,drm_kms_helper,ttm, Live 0x0000000000000000
> > > crc32c_intel 24576 5 - Live 0x0000000000000000
> > > serio_raw 20480 0 - Live 0x0000000000000000
> > > virtio_blk 20480 3 - Live 0x0000000000000000
> > > virtio_console 45056 0 - Live 0x0000000000000000
> > > qemu_fw_cfg 20480 0 - Live 0x0000000000000000
> > > agpgart 53248 4 intel_agp,intel_gtt,ttm,drm, Live 0x0000000000000000
> > >
> > >
> > > [8.4.] Loaded driver and hardware information (/proc/ioports, /proc/i=
omem)
> > >
> > > $ cat /proc/ioports
> > > 0000-0000 : PCI Bus 0000:00
> > >   0000-0000 : dma1
> > >   0000-0000 : pic1
> > >   0000-0000 : timer0
> > >   0000-0000 : timer1
> > >   0000-0000 : keyboard
> > >   0000-0000 : keyboard
> > >   0000-0000 : rtc0
> > >   0000-0000 : dma page reg
> > >   0000-0000 : pic2
> > >   0000-0000 : dma2
> > >   0000-0000 : fpu
> > >   0000-0000 : vga+
> > >   0000-0000 : serial
> > >   0000-0000 : QEMU0002:00
> > >     0000-0000 : fw_cfg_io
> > >   0000-0000 : 0000:00:1f.0
> > >     0000-0000 : ACPI PM1a_EVT_BLK
> > >     0000-0000 : ACPI PM1a_CNT_BLK
> > >     0000-0000 : ACPI PM_TMR
> > >     0000-0000 : ACPI GPE0_BLK
> > >   0000-0000 : 0000:00:1f.3
> > > 0000-0000 : PCI conf1
> > > 0000-0000 : PCI Bus 0000:00
> > >   0000-0000 : PCI Bus 0000:01
> > >   0000-0000 : PCI Bus 0000:02
> > >   0000-0000 : PCI Bus 0000:03
> > >   0000-0000 : PCI Bus 0000:04
> > >   0000-0000 : PCI Bus 0000:05
> > >   0000-0000 : PCI Bus 0000:06
> > >   0000-0000 : PCI Bus 0000:07
> > >   0000-0000 : 0000:00:01.0
> > >   0000-0000 : 0000:00:1f.2
> > >     0000-0000 : ahci
> > >
> > > $ cat /proc/iomem
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : System RAM
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : PCI Bus 0000:00
> > > 00000000-00000000 : Video ROM
> > > 00000000-00000000 : Adapter ROM
> > > 00000000-00000000 : Adapter ROM
> > > 00000000-00000000 : Reserved
> > >   00000000-00000000 : System ROM
> > > 00000000-00000000 : System RAM
> > >   00000000-00000000 : Kernel code
> > >   00000000-00000000 : Kernel data
> > >   00000000-00000000 : Kernel bss
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : PCI MMCONFIG 0000 [bus 00-ff]
> > >   00000000-00000000 : Reserved
> > > 00000000-00000000 : PCI Bus 0000:00
> > >   00000000-00000000 : 0000:00:01.0
> > >   00000000-00000000 : 0000:00:01.0
> > >   00000000-00000000 : PCI Bus 0000:07
> > >   00000000-00000000 : PCI Bus 0000:06
> > >   00000000-00000000 : PCI Bus 0000:05
> > >   00000000-00000000 : PCI Bus 0000:04
> > >     00000000-00000000 : 0000:04:00.0
> > >   00000000-00000000 : PCI Bus 0000:03
> > >     00000000-00000000 : 0000:03:00.0
> > >   00000000-00000000 : PCI Bus 0000:02
> > >     00000000-00000000 : 0000:02:00.0
> > >       00000000-00000000 : xhci-hcd
> > >   00000000-00000000 : PCI Bus 0000:01
> > >     00000000-00000000 : 0000:01:00.0
> > >     00000000-00000000 : 0000:01:00.0
> > >   00000000-00000000 : 0000:00:1b.0
> > >   00000000-00000000 : 0000:00:01.0
> > >   00000000-00000000 : 0000:00:02.0
> > >   00000000-00000000 : 0000:00:02.1
> > >   00000000-00000000 : 0000:00:02.2
> > >   00000000-00000000 : 0000:00:02.3
> > >   00000000-00000000 : 0000:00:02.4
> > >   00000000-00000000 : 0000:00:02.5
> > >   00000000-00000000 : 0000:00:02.6
> > >   00000000-00000000 : 0000:00:1f.2
> > >     00000000-00000000 : ahci
> > >   00000000-00000000 : PCI Bus 0000:07
> > >   00000000-00000000 : PCI Bus 0000:06
> > >     00000000-00000000 : 0000:06:00.0
> > >       00000000-00000000 : virtio-pci-modern
> > >   00000000-00000000 : PCI Bus 0000:05
> > >     00000000-00000000 : 0000:05:00.0
> > >       00000000-00000000 : virtio-pci-modern
> > >   00000000-00000000 : PCI Bus 0000:04
> > >     00000000-00000000 : 0000:04:00.0
> > >       00000000-00000000 : virtio-pci-modern
> > >   00000000-00000000 : PCI Bus 0000:03
> > >     00000000-00000000 : 0000:03:00.0
> > >       00000000-00000000 : virtio-pci-modern
> > >   00000000-00000000 : PCI Bus 0000:02
> > >   00000000-00000000 : PCI Bus 0000:01
> > >     00000000-00000000 : 0000:01:00.0
> > >       00000000-00000000 : virtio-pci-modern
> > > 00000000-00000000 : IOAPIC 0
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : Local APIC
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : Reserved
> > > 00000000-00000000 : PCI Bus 0000:00
> > >
> > >
> > > [8.5.] PCI information ('lspci -vvv' as root)
> > >
> > > Attached as: lspci-vvv-5.3.0-rc4.txt
> > >
> > >
> > > [8.6.] SCSI information (from /proc/scsi/scsi)
> > >
> > > $ cat //proc/scsi/scsi
> > > Attached devices:
> > > Host: scsi0 Channel: 00 Id: 00 Lun: 00
> > >   Vendor: QEMU     Model: QEMU DVD-ROM     Rev: 2.5+
> > >   Type:   CD-ROM                           ANSI  SCSI revision: 05
> > >
> > >
> > > [8.7.] Other information that might be relevant to the problem
> > >
> > > During testing it looks like this:
> > > $ egrep -r ^ /sys/module/zswap/parameters
> > > /sys/module/zswap/parameters/same_filled_pages_enabled:Y
> > > /sys/module/zswap/parameters/enabled:Y
> > > /sys/module/zswap/parameters/max_pool_percent:20
> > > /sys/module/zswap/parameters/compressor:lzo
> > > /sys/module/zswap/parameters/zpool:z3fold
> > >
> > > $ cat /proc/meminfo
> > > MemTotal:         983056 kB
> > > MemFree:          377876 kB
> > > MemAvailable:     660820 kB
> > > Buffers:           14896 kB
> > > Cached:           368028 kB
> > > SwapCached:            0 kB
> > > Active:           247500 kB
> > > Inactive:         193120 kB
> > > Active(anon):      58016 kB
> > > Inactive(anon):      280 kB
> > > Active(file):     189484 kB
> > > Inactive(file):   192840 kB
> > > Unevictable:           0 kB
> > > Mlocked:               0 kB
> > > SwapTotal:       4194300 kB
> > > SwapFree:        4194300 kB
> > > Dirty:                 8 kB
> > > Writeback:             0 kB
> > > AnonPages:         57712 kB
> > > Mapped:            81984 kB
> > > Shmem:               596 kB
> > > KReclaimable:      56272 kB
> > > Slab:             128128 kB
> > > SReclaimable:      56272 kB
> > > SUnreclaim:        71856 kB
> > > KernelStack:        2208 kB
> > > PageTables:         1632 kB
> > > NFS_Unstable:          0 kB
> > > Bounce:                0 kB
> > > WritebackTmp:          0 kB
> > > CommitLimit:     4685828 kB
> > > Committed_AS:     268512 kB
> > > VmallocTotal:   34359738367 kB
> > > VmallocUsed:        9764 kB
> > > VmallocChunk:          0 kB
> > > Percpu:             9312 kB
> > > HardwareCorrupted:     0 kB
> > > AnonHugePages:         0 kB
> > > ShmemHugePages:        0 kB
> > > ShmemPmdMapped:        0 kB
> > > CmaTotal:              0 kB
> > > CmaFree:               0 kB
> > > HugePages_Total:       0
> > > HugePages_Free:        0
> > > HugePages_Rsvd:        0
> > > HugePages_Surp:        0
> > > Hugepagesize:       2048 kB
> > > Hugetlb:               0 kB
> > > DirectMap4k:      110452 kB
> > > DirectMap2M:      937984 kB
> > > DirectMap1G:           0 kB
> > >
> > >
> > > [9.] Other notes
> > >
> > > My workaround is to disable zswap:
> > >
> > > sudo bash -c 'echo 0 > /sys/module/zswap/parameters/enabled'
> > >
> > >
> > > Sometimes stress can die just because it is out of memory. Also some
> > > other programs might die because of page allocation failures etc. But
> > > that is not relevant here.
> > >
> > >
> > > Generally stress command is actually like:
> > >
> > > stress --vm 6 --vm-bytes 228608000 --timeout 10
> > >
> > >
> > > It seems to be essential to start and stop stress runs. Sometimes
> > > problem does not trigger until much later. To be sure there is no
> > > problems I'd suggest running stress at least an hour (--timeout 3600)
> > > and also couple of hundred times with short timeout. I've used 90
> > > minutes as mark of "good" run during bisect (start of). I'm not sure
> > > if this is only one issue here.
> > >
> > > I reboot machine with kernel under test. Run uname -r and collect boo=
t
> > > logs using ssh. And then ssh in with test script. No other commands
> > > are run.
> > >
> > > Some timestamps of errors to give idea how log to wait for test to
> > > give results. Testing starts when machine has been up about 8 or 9
> > > seconds.
> > >
> > >  [   13.805105] general protection fault: 0000 [#1] SMP PTI
> > >  [   14.059768] general protection fault: 0000 [#1] SMP PTI
> > >  [   14.324867] general protection fault: 0000 [#1] SMP PTI
> > >  [   14.458709] general protection fault: 0000 [#1] SMP PTI
> > >  [   41.818966] BUG: unable to handle page fault for address: fffff54=
cf8000028
> > >  [  105.710330] BUG: unable to handle page fault for address: ffffd2d=
f8a000028
> > >  [  135.390332] BUG: unable to handle page fault for address: ffffe5a=
34a000028
> > >  [  166.793041] BUG: unable to handle page fault for address: ffffd1b=
e6f000028
> > >  [  311.602285] BUG: unable to handle page fault for address: fffff7f=
409000028
> >
> > > 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM=
 Controller
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Kernel modules: intel_agp
> > >
> > > 00:01.0 VGA compatible controller: Red Hat, Inc. QXL paravirtual grap=
hic card (rev 04) (prog-if 00 [VGA controller])
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Interrupt: pin A routed to IRQ 21
> > >       Region 0: Memory at f4000000 (32-bit, non-prefetchable) [size=
=3D64M]
> > >       Region 1: Memory at f8000000 (32-bit, non-prefetchable) [size=
=3D64M]
> > >       Region 2: Memory at fce14000 (32-bit, non-prefetchable) [size=
=3D8K]
> > >       Region 3: I/O ports at c040 [size=3D32]
> > >       Expansion ROM at 000c0000 [disabled] [size=3D128K]
> > >       Kernel driver in use: qxl
> > >       Kernel modules: qxl
> > >
> > > 00:02.0 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce16000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00001000-00001fff [size=3D4K]
> > >       Memory behind bridge: fcc00000-fcdfffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fea00000-00000000feb=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #16, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.1 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce17000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00002000-00002fff [size=3D4K]
> > >       Memory behind bridge: fca00000-fcbfffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fe800000-00000000fe9=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #17, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.2 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce18000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00003000-00003fff [size=3D4K]
> > >       Memory behind bridge: fc800000-fc9fffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fe600000-00000000fe7=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #18, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.3 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce19000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00004000-00004fff [size=3D4K]
> > >       Memory behind bridge: fc600000-fc7fffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fe400000-00000000fe5=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #19, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.4 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce1a000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00005000-00005fff [size=3D4K]
> > >       Memory behind bridge: fc400000-fc5fffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fe200000-00000000fe3=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #20, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.5 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce1b000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D06, subordinate=3D06, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00006000-00006fff [size=3D4K]
> > >       Memory behind bridge: fc200000-fc3fffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fe000000-00000000fe1=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #21, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd Off, PwrInd On, Power- Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t+ Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:02.6 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00 [No=
rmal decode])
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fce1c000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Bus: primary=3D00, secondary=3D07, subordinate=3D07, sec-latenc=
y=3D0
> > >       I/O behind bridge: 00007000-00007fff [size=3D4K]
> > >       Memory behind bridge: fc000000-fc1fffff [size=3D2M]
> > >       Prefetchable memory behind bridge: 00000000fde00000-00000000fdf=
fffff [size=3D2M]
> > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
> > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset- Fas=
tB2B-
> > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >                       ExtTag- RBE+
> > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #22, Speed 2.5GT/s, Width x1, ASPM L0s, Ex=
it Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug=
+ Surprise+
> > >                       Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-
> > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+=
 HPIrq+ LinkChg-
> > >                       Control: AttnInd On, PwrInd Off, Power+ Interlo=
ck-
> > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDe=
t- Interlock-
> > >                       Changed: MRL- PresDet- LinkState-
> > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
> > >               RootCap: CRSVisible-
> > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported ARIFwd+
> > >                        AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS=
-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
> > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > >               Vector table: BAR=3D0 offset=3D00000000
> > >               PBA: BAR=3D0 offset=3D00000800
> > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > >       Capabilities: [100 v2] Advanced Error Reporting
> > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr-
> > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvN=
onFatalErr+
> > >               AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn-=
 ECRCChkCap+ ECRCChkEn-
> > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLog=
Cap-
> > >               HeaderLog: 00000000 00000000 00000000 00000000
> > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0
> > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > >       Kernel driver in use: pcieport
> > >
> > > 00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio=
 Controller (rev 03)
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Interrupt: pin A routed to IRQ 10
> > >       Region 0: Memory at fce10000 (32-bit, non-prefetchable) [size=
=3D16K]
> > >       Capabilities: [60] MSI: Enable- Count=3D1/1 Maskable- 64bit+
> > >               Address: 0000000000000000  Data: 0000
> > >
> > > 00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface Co=
ntroller (rev 02)
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >
> > > 00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH=
) 6 port SATA Controller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 31
> > >       Region 4: I/O ports at c060 [size=3D32]
> > >       Region 5: Memory at fce1d000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
> > >               Address: 00000000fee02004  Data: 4023
> > >       Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=3D00000004
> > >       Kernel driver in use: ahci
> > >
> > > 00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controlle=
r (rev 02)
> > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Interrupt: pin A routed to IRQ 10
> > >       Region 4: I/O ports at 0700 [size=3D64]
> > >
> > > 01:00.0 Ethernet controller: Red Hat, Inc. Virtio network device (rev=
 01)
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 1: Memory at fcc40000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Region 4: Memory at fea00000 (64-bit, prefetchable) [size=3D16K=
]
> > >       Expansion ROM at fcc00000 [disabled] [size=3D256K]
> > >       Capabilities: [dc] MSI-X: Enable+ Count=3D3 Masked-
> > >               Vector table: BAR=3D1 offset=3D00000000
> > >               PBA: BAR=3D1 offset=3D00000800
> > >       Capabilities: [c8] Vendor Specific Information: VirtIO: <unknow=
n>
> > >               BAR=3D0 offset=3D00000000 size=3D00000000
> > >       Capabilities: [b4] Vendor Specific Information: VirtIO: Notify
> > >               BAR=3D4 offset=3D00003000 size=3D00001000 multiplier=3D=
00000004
> > >       Capabilities: [a4] Vendor Specific Information: VirtIO: DeviceC=
fg
> > >               BAR=3D4 offset=3D00002000 size=3D00001000
> > >       Capabilities: [94] Vendor Specific Information: VirtIO: ISR
> > >               BAR=3D4 offset=3D00001000 size=3D00001000
> > >       Capabilities: [84] Vendor Specific Information: VirtIO: CommonC=
fg
> > >               BAR=3D4 offset=3D00000000 size=3D00001000
> > >       Capabilities: [7c] Power Management version 3
> > >               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
> > >               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
> > >       Capabilities: [40] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: virtio-pci
> > >
> > > 02:00.0 USB controller: Red Hat, Inc. QEMU XHCI Host Controller (rev =
01) (prog-if 30 [XHCI])
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0-1
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0, Cache Line Size: 64 bytes
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 0: Memory at fca00000 (64-bit, non-prefetchable) [size=
=3D16K]
> > >       Capabilities: [90] MSI-X: Enable+ Count=3D16 Masked-
> > >               Vector table: BAR=3D0 offset=3D00003000
> > >               PBA: BAR=3D0 offset=3D00003800
> > >       Capabilities: [a0] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: xhci_hcd
> > >
> > > 03:00.0 Communication controller: Red Hat, Inc. Virtio console (rev 0=
1)
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0-2
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 1: Memory at fc800000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Region 4: Memory at fe600000 (64-bit, prefetchable) [size=3D16K=
]
> > >       Capabilities: [dc] MSI-X: Enable+ Count=3D2 Masked-
> > >               Vector table: BAR=3D1 offset=3D00000000
> > >               PBA: BAR=3D1 offset=3D00000800
> > >       Capabilities: [c8] Vendor Specific Information: VirtIO: <unknow=
n>
> > >               BAR=3D0 offset=3D00000000 size=3D00000000
> > >       Capabilities: [b4] Vendor Specific Information: VirtIO: Notify
> > >               BAR=3D4 offset=3D00003000 size=3D00001000 multiplier=3D=
00000004
> > >       Capabilities: [a4] Vendor Specific Information: VirtIO: DeviceC=
fg
> > >               BAR=3D4 offset=3D00002000 size=3D00001000
> > >       Capabilities: [94] Vendor Specific Information: VirtIO: ISR
> > >               BAR=3D4 offset=3D00001000 size=3D00001000
> > >       Capabilities: [84] Vendor Specific Information: VirtIO: CommonC=
fg
> > >               BAR=3D4 offset=3D00000000 size=3D00001000
> > >       Capabilities: [7c] Power Management version 3
> > >               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
> > >               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
> > >       Capabilities: [40] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: virtio-pci
> > >
> > > 04:00.0 SCSI storage controller: Red Hat, Inc. Virtio block device (r=
ev 01)
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0-3
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 1: Memory at fc600000 (32-bit, non-prefetchable) [size=
=3D4K]
> > >       Region 4: Memory at fe400000 (64-bit, prefetchable) [size=3D16K=
]
> > >       Capabilities: [dc] MSI-X: Enable+ Count=3D2 Masked-
> > >               Vector table: BAR=3D1 offset=3D00000000
> > >               PBA: BAR=3D1 offset=3D00000800
> > >       Capabilities: [c8] Vendor Specific Information: VirtIO: <unknow=
n>
> > >               BAR=3D0 offset=3D00000000 size=3D00000000
> > >       Capabilities: [b4] Vendor Specific Information: VirtIO: Notify
> > >               BAR=3D4 offset=3D00003000 size=3D00001000 multiplier=3D=
00000004
> > >       Capabilities: [a4] Vendor Specific Information: VirtIO: DeviceC=
fg
> > >               BAR=3D4 offset=3D00002000 size=3D00001000
> > >       Capabilities: [94] Vendor Specific Information: VirtIO: ISR
> > >               BAR=3D4 offset=3D00001000 size=3D00001000
> > >       Capabilities: [84] Vendor Specific Information: VirtIO: CommonC=
fg
> > >               BAR=3D4 offset=3D00000000 size=3D00001000
> > >       Capabilities: [7c] Power Management version 3
> > >               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
> > >               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
> > >       Capabilities: [40] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: virtio-pci
> > >
> > > 05:00.0 Unclassified device [00ff]: Red Hat, Inc. Virtio memory ballo=
on (rev 01)
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0-4
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 4: Memory at fe200000 (64-bit, prefetchable) [size=3D16K=
]
> > >       Capabilities: [c8] Vendor Specific Information: VirtIO: <unknow=
n>
> > >               BAR=3D0 offset=3D00000000 size=3D00000000
> > >       Capabilities: [b4] Vendor Specific Information: VirtIO: Notify
> > >               BAR=3D4 offset=3D00003000 size=3D00001000 multiplier=3D=
00000004
> > >       Capabilities: [a4] Vendor Specific Information: VirtIO: DeviceC=
fg
> > >               BAR=3D4 offset=3D00002000 size=3D00001000
> > >       Capabilities: [94] Vendor Specific Information: VirtIO: ISR
> > >               BAR=3D4 offset=3D00001000 size=3D00001000
> > >       Capabilities: [84] Vendor Specific Information: VirtIO: CommonC=
fg
> > >               BAR=3D4 offset=3D00000000 size=3D00001000
> > >       Capabilities: [7c] Power Management version 3
> > >               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
> > >               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
> > >       Capabilities: [40] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: virtio-pci
> > >
> > > 06:00.0 Unclassified device [00ff]: Red Hat, Inc. Virtio RNG (rev 01)
> > >       Subsystem: Red Hat, Inc. Device 1100
> > >       Physical Slot: 0-5
> > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx-
> > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >       Latency: 0
> > >       Interrupt: pin A routed to IRQ 22
> > >       Region 4: Memory at fe000000 (64-bit, prefetchable) [size=3D16K=
]
> > >       Capabilities: [c8] Vendor Specific Information: VirtIO: <unknow=
n>
> > >               BAR=3D0 offset=3D00000000 size=3D00000000
> > >       Capabilities: [b4] Vendor Specific Information: VirtIO: Notify
> > >               BAR=3D4 offset=3D00003000 size=3D00001000 multiplier=3D=
00000004
> > >       Capabilities: [a4] Vendor Specific Information: VirtIO: DeviceC=
fg
> > >               BAR=3D4 offset=3D00002000 size=3D00001000
> > >       Capabilities: [94] Vendor Specific Information: VirtIO: ISR
> > >               BAR=3D4 offset=3D00001000 size=3D00001000
> > >       Capabilities: [84] Vendor Specific Information: VirtIO: CommonC=
fg
> > >               BAR=3D4 offset=3D00000000 size=3D00001000
> > >       Capabilities: [7c] Power Management version 3
> > >               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
> > >               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
> > >       Capabilities: [40] Express (v2) Endpoint, MSI 00
> > >               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
<64ns, L1 <1us
> > >                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=
 SlotPowerLimit 0.000W
> > >               DevCtl: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPw=
r- TransPend-
> > >               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <64ns
> > >                       ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp=
-
> > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > >                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgm=
t-
> > >               DevCap2: Completion Timeout: Not Supported, TimeoutDis-=
, LTR-, OBFF Not Supported
> > >                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
> > >               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled
> > >                        AtomicOpsCtl: ReqEn-
> > >               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
> > >                        Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
> > >                        Compliance De-emphasis: -6dB
> > >               LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
> > >                        EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
> > >       Kernel driver in use: virtio-pci
> > >
> >
> >
> > > [    0.000000] Linux version 5.3.0-rc4 (maage@workstation.lan) (gcc v=
ersion 9.1.1 20190503 (Red Hat 9.1.1-1) (GCC)) #69 SMP Fri Aug 16 19:52:23 =
EEST 2019
> > > [    0.000000] Command line: BOOT_IMAGE=3D(hd0,msdos1)/vmlinuz-5.3.0-=
rc4 root=3D/dev/mapper/fedora-root ro resume=3D/dev/mapper/fedora-swap rd.l=
vm.lv=3Dfedora/root rd.lvm.lv=3Dfedora/swap rhgb quiet zswap.enabled=3D1 zs=
wap.zpool=3Dz3fold console=3Dtty0 console=3DttyS0
> > > [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating=
 point registers'
> > > [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE register=
s'
> > > [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX register=
s'
> > > [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> > > [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is =
832 bytes, using 'standard' format.
> > > [    0.000000] BIOS-provided physical RAM map:
> > > [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff]=
 usable
> > > [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000003ffdcfff]=
 usable
> > > [    0.000000] BIOS-e820: [mem 0x000000003ffdd000-0x000000003fffffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x00000000b0000000-0x00000000bfffffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff]=
 reserved
> > > [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff]=
 reserved
> > > [    0.000000] NX (Execute Disable) protection: active
> > > [    0.000000] SMBIOS 2.8 present.
> > > [    0.000000] DMI: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.12.0-=
2.fc30 04/01/2014
> > > [    0.000000] tsc: Fast TSC calibration using PIT
> > > [    0.000000] tsc: Detected 3198.113 MHz processor
> > > [    0.001583] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D=
> reserved
> > > [    0.001585] e820: remove [mem 0x000a0000-0x000fffff] usable
> > > [    0.001588] last_pfn =3D 0x3ffdd max_arch_pfn =3D 0x400000000
> > > [    0.001612] MTRR default type: write-back
> > > [    0.001613] MTRR fixed ranges enabled:
> > > [    0.001615]   00000-9FFFF write-back
> > > [    0.001616]   A0000-BFFFF uncachable
> > > [    0.001618]   C0000-FFFFF write-protect
> > > [    0.001619] MTRR variable ranges enabled:
> > > [    0.001620]   0 base 00C0000000 mask FFC0000000 uncachable
> > > [    0.001621]   1 disabled
> > > [    0.001622]   2 disabled
> > > [    0.001623]   3 disabled
> > > [    0.001624]   4 disabled
> > > [    0.001625]   5 disabled
> > > [    0.001626]   6 disabled
> > > [    0.001627]   7 disabled
> > > [    0.001636] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  =
UC- WT
> > > [    0.004595] found SMP MP-table at [mem 0x000f5c10-0x000f5c1f]
> > > [    0.004632] check: Scanning 1 areas for low memory corruption
> > > [    0.004648] Using GB pages for direct mapping
> > > [    0.004651] BRK [0x2dc01000, 0x2dc01fff] PGTABLE
> > > [    0.004653] BRK [0x2dc02000, 0x2dc02fff] PGTABLE
> > > [    0.004654] BRK [0x2dc03000, 0x2dc03fff] PGTABLE
> > > [    0.004674] BRK [0x2dc04000, 0x2dc04fff] PGTABLE
> > > [    0.004765] BRK [0x2dc05000, 0x2dc05fff] PGTABLE
> > > [    0.004774] RAMDISK: [mem 0x344be000-0x36256fff]
> > > [    0.004785] ACPI: Early table checksum verification disabled
> > > [    0.004788] ACPI: RSDP 0x00000000000F5980 000014 (v00 BOCHS )
> > > [    0.004793] ACPI: RSDT 0x000000003FFE218E 000030 (v01 BOCHS  BXPCR=
SDT 00000001 BXPC 00000001)
> > > [    0.004798] ACPI: FACP 0x000000003FFE1FCE 0000F4 (v03 BOCHS  BXPCF=
ACP 00000001 BXPC 00000001)
> > > [    0.004802] ACPI: DSDT 0x000000003FFE0040 001F8E (v01 BOCHS  BXPCD=
SDT 00000001 BXPC 00000001)
> > > [    0.004805] ACPI: FACS 0x000000003FFE0000 000040
> > > [    0.004807] ACPI: APIC 0x000000003FFE20C2 000090 (v01 BOCHS  BXPCA=
PIC 00000001 BXPC 00000001)
> > > [    0.004810] ACPI: MCFG 0x000000003FFE2152 00003C (v01 BOCHS  BXPCM=
CFG 00000001 BXPC 00000001)
> > > [    0.004816] ACPI: Local APIC address 0xfee00000
> > > [    0.004862] No NUMA configuration found
> > > [    0.004863] Faking a node at [mem 0x0000000000000000-0x000000003ff=
dcfff]
> > > [    0.004871] NODE_DATA(0) allocated [mem 0x3ffb2000-0x3ffdcfff]
> > > [    0.007077] Zone ranges:
> > > [    0.007080]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> > > [    0.007082]   DMA32    [mem 0x0000000001000000-0x000000003ffdcfff]
> > > [    0.007084]   Normal   empty
> > > [    0.007085]   Device   empty
> > > [    0.007086] Movable zone start for each node
> > > [    0.007089] Early memory node ranges
> > > [    0.007090]   node   0: [mem 0x0000000000001000-0x000000000009efff=
]
> > > [    0.007092]   node   0: [mem 0x0000000000100000-0x000000003ffdcfff=
]
> > > [    0.007096] Zeroed struct page in unavailable ranges: 98 pages
> > > [    0.007097] Initmem setup node 0 [mem 0x0000000000001000-0x0000000=
03ffdcfff]
> > > [    0.007098] On node 0 totalpages: 262011
> > > [    0.007100]   DMA zone: 64 pages used for memmap
> > > [    0.007101]   DMA zone: 21 pages reserved
> > > [    0.007103]   DMA zone: 3998 pages, LIFO batch:0
> > > [    0.007142]   DMA32 zone: 4032 pages used for memmap
> > > [    0.007143]   DMA32 zone: 258013 pages, LIFO batch:63
> > > [    0.009891] ACPI: PM-Timer IO Port: 0x608
> > > [    0.009896] ACPI: Local APIC address 0xfee00000
> > > [    0.009901] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
> > > [    0.009943] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, =
GSI 0-23
> > > [    0.009946] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl df=
l)
> > > [    0.009948] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high l=
evel)
> > > [    0.009949] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high l=
evel)
> > > [    0.009950] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high=
 level)
> > > [    0.009952] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high=
 level)
> > > [    0.009953] ACPI: IRQ0 used by override.
> > > [    0.009954] ACPI: IRQ5 used by override.
> > > [    0.009955] ACPI: IRQ9 used by override.
> > > [    0.009956] ACPI: IRQ10 used by override.
> > > [    0.009957] ACPI: IRQ11 used by override.
> > > [    0.009960] Using ACPI (MADT) for SMP configuration information
> > > [    0.009965] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
> > > [    0.009977] PM: Registered nosave memory: [mem 0x00000000-0x00000f=
ff]
> > > [    0.009979] PM: Registered nosave memory: [mem 0x0009f000-0x0009ff=
ff]
> > > [    0.009980] PM: Registered nosave memory: [mem 0x000a0000-0x000eff=
ff]
> > > [    0.009981] PM: Registered nosave memory: [mem 0x000f0000-0x000fff=
ff]
> > > [    0.009985] [mem 0x40000000-0xafffffff] available for PCI devices
> > > [    0.009989] clocksource: refined-jiffies: mask: 0xffffffff max_cyc=
les: 0xffffffff, max_idle_ns: 1910969940391419 ns
> > > [    0.076387] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:4 nr_cpu_id=
s:4 nr_node_ids:1
> > > [    0.077507] percpu: Embedded 502 pages/cpu s2018456 r8192 d29544 u=
2097152
> > > [    0.077516] pcpu-alloc: s2018456 r8192 d29544 u2097152 alloc=3D1*2=
097152
> > > [    0.077518] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
> > > [    0.077553] Built 1 zonelists, mobility grouping on.  Total pages:=
 257894
> > > [    0.077554] Policy zone: DMA32
> > > [    0.077561] Kernel command line: BOOT_IMAGE=3D(hd0,msdos1)/vmlinuz=
-5.3.0-rc4 root=3D/dev/mapper/fedora-root ro resume=3D/dev/mapper/fedora-sw=
ap rd.lvm.lv=3Dfedora/root rd.lvm.lv=3Dfedora/swap rhgb quiet zswap.enabled=
=3D1 zswap.zpool=3Dz3fold console=3Dtty0 console=3DttyS0
> > > [    0.077702] Dentry cache hash table entries: 131072 (order: 8, 104=
8576 bytes, linear)
> > > [    0.077730] Inode-cache hash table entries: 65536 (order: 7, 52428=
8 bytes, linear)
> > > [    0.077775] mem auto-init: stack:off, heap alloc:off, heap free:of=
f
> > > [    0.116054] Memory: 946032K/1048044K available (12292K kernel code=
, 2956K rwdata, 4040K rodata, 4600K init, 15360K bss, 102012K reserved, 0K =
cma-reserved)
> > > [    0.116303] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=
=3D4, Nodes=3D1
> > > [    0.116449] Kernel/User page tables isolation: enabled
> > > [    0.116484] ftrace: allocating 34272 entries in 134 pages
> > > [    0.125832] Running RCU self tests
> > > [    0.125834] rcu: Hierarchical RCU implementation.
> > > [    0.125835] rcu:   RCU lockdep checking is enabled.
> > > [    0.125836] rcu:   RCU restricting CPUs from NR_CPUS=3D8192 to nr_=
cpu_ids=3D4.
> > > [    0.125838] rcu:   RCU callback double-/use-after-free debug enabl=
ed.
> > > [    0.125839]        Tasks RCU enabled.
> > > [    0.125840] rcu: RCU calculated value of scheduler-enlistment dela=
y is 100 jiffies.
> > > [    0.125841] rcu: Adjusting geometry for rcu_fanout_leaf=3D16, nr_c=
pu_ids=3D4
> > > [    0.128810] NR_IRQS: 524544, nr_irqs: 456, preallocated irqs: 16
> > > [    0.129132] random: get_random_bytes called from start_kernel+0x39=
f/0x57e with crng_init=3D0
> > > [    0.143705] Console: colour VGA+ 80x25
> > > [    0.143712] printk: console [tty0] enabled
> > > [    0.143758] printk: console [ttyS0] enabled
> > > [    0.143759] Lock dependency validator: Copyright (c) 2006 Red Hat,=
 Inc., Ingo Molnar
> > > [    0.143761] ... MAX_LOCKDEP_SUBCLASSES:  8
> > > [    0.143762] ... MAX_LOCK_DEPTH:          48
> > > [    0.143763] ... MAX_LOCKDEP_KEYS:        8192
> > > [    0.143764] ... CLASSHASH_SIZE:          4096
> > > [    0.143765] ... MAX_LOCKDEP_ENTRIES:     32768
> > > [    0.143766] ... MAX_LOCKDEP_CHAINS:      65536
> > > [    0.143767] ... CHAINHASH_SIZE:          32768
> > > [    0.143768]  memory used by lock dependency info: 6749 kB
> > > [    0.143769]  per task-struct memory footprint: 2688 bytes
> > > [    0.143770] kmemleak: Kernel memory leak detector disabled
> > > [    0.143795] ACPI: Core revision 20190703
> > > [    0.143853] APIC: Switch to symmetric I/O mode setup
> > > [    0.144980] clocksource: tsc-early: mask: 0xffffffffffffffff max_c=
ycles: 0x2e19538478f, max_idle_ns: 440795207229 ns
> > > [    0.144996] Calibrating delay loop (skipped), value calculated usi=
ng timer frequency.. 6396.22 BogoMIPS (lpj=3D3198113)
> > > [    0.144999] pid_max: default: 32768 minimum: 301
> > > [    0.145047] LSM: Security Framework initializing
> > > [    0.145059] Yama: becoming mindful.
> > > [    0.145067] SELinux:  Initializing.
> > > [    0.145095] *** VALIDATE SELinux ***
> > > [    0.145130] Mount-cache hash table entries: 2048 (order: 2, 16384 =
bytes, linear)
> > > [    0.145134] Mountpoint-cache hash table entries: 2048 (order: 2, 1=
6384 bytes, linear)
> > > [    0.145465] *** VALIDATE proc ***
> > > [    0.145596] *** VALIDATE cgroup1 ***
> > > [    0.145598] *** VALIDATE cgroup2 ***
> > > [    0.145699] x86/cpu: User Mode Instruction Prevention (UMIP) activ=
ated
> > > [    0.145750] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> > > [    0.145751] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> > > [    0.145755] Spectre V1 : Mitigation: usercopy/swapgs barriers and =
__user pointer sanitization
> > > [    0.145757] Spectre V2 : Mitigation: Full generic retpoline
> > > [    0.145758] Spectre V2 : Spectre v2 / SpectreRSB mitigation: Filli=
ng RSB on context switch
> > > [    0.145759] Spectre V2 : Enabling Restricted Speculation for firmw=
are calls
> > > [    0.145761] Spectre V2 : mitigation: Enabling conditional Indirect=
 Branch Prediction Barrier
> > > [    0.145763] Speculative Store Bypass: Mitigation: Speculative Stor=
e Bypass disabled via prctl and seccomp
> > > [    0.145768] MDS: Mitigation: Clear CPU buffers
> > > [    0.145931] Freeing SMP alternatives memory: 28K
> > > [    0.145990] TSC deadline timer enabled
> > > [    0.145990] smpboot: CPU0: Intel Core Processor (Haswell, no TSX, =
IBRS) (family: 0x6, model: 0x3c, stepping: 0x1)
> > > [    0.145990] Performance Events: unsupported p6 CPU model 60 no PMU=
 driver, software events only.
> > > [    0.145990] rcu: Hierarchical SRCU implementation.
> > > [    0.145990] NMI watchdog: Perf NMI watchdog permanently disabled
> > > [    0.145990] smp: Bringing up secondary CPUs ...
> > > [    0.146296] x86: Booting SMP configuration:
> > > [    0.146300] .... node  #0, CPUs:      #1
> > > [    0.016909] smpboot: CPU 1 Converting physical 0 to logical die 1
> > > [    0.207282]  #2
> > > [    0.016909] smpboot: CPU 2 Converting physical 0 to logical die 2
> > > [    0.268244]  #3
> > > [    0.016909] smpboot: CPU 3 Converting physical 0 to logical die 3
> > > [    0.329083] smp: Brought up 1 node, 4 CPUs
> > > [    0.329083] smpboot: Max logical packages: 4
> > > [    0.329083] smpboot: Total of 4 processors activated (26265.82 Bog=
oMIPS)
> > > [    0.329402] devtmpfs: initialized
> > > [    0.330082] x86/mm: Memory block size: 128MB
> > > [    0.333126] DMA-API: preallocated 65536 debug entries
> > > [    0.333128] DMA-API: debugging enabled by kernel config
> > > [    0.333131] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xf=
fffffff, max_idle_ns: 1911260446275000 ns
> > > [    0.333138] futex hash table entries: 1024 (order: 5, 131072 bytes=
, linear)
> > > [    0.333586] PM: RTC time: 07:03:45, date: 2019-08-18
> > > [    0.334058] NET: Registered protocol family 16
> > > [    0.334352] audit: initializing netlink subsys (disabled)
> > > [    0.334465] audit: type=3D2000 audit(1566111825.189:1): state=3Din=
itialized audit_enabled=3D0 res=3D1
> > > [    0.334465] cpuidle: using governor menu
> > > [    0.334465] ACPI: bus type PCI registered
> > > [    0.334465] acpiphp: ACPI Hot Plug PCI Controller Driver version: =
0.5
> > > [    0.335006] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xb0=
000000-0xbfffffff] (base 0xb0000000)
> > > [    0.335010] PCI: MMCONFIG at [mem 0xb0000000-0xbfffffff] reserved =
in E820
> > > [    0.335022] PCI: Using configuration type 1 for base access
> > > [    0.339432] HugeTLB registered 1.00 GiB page size, pre-allocated 0=
 pages
> > > [    0.339432] HugeTLB registered 2.00 MiB page size, pre-allocated 0=
 pages
> > > [    0.424065] cryptomgr_test (39) used greatest stack depth: 13944 b=
ytes left
> > > [    0.424442] kworker/u8:0 (42) used greatest stack depth: 13184 byt=
es left
> > > [    0.452355] cryptd: max_cpu_qlen set to 1000
> > > [    0.457338] alg: No test for lzo-rle (lzo-rle-generic)
> > > [    0.457338] alg: No test for lzo-rle (lzo-rle-scomp)
> > > [    0.457338] alg: No test for 842 (842-generic)
> > > [    0.458089] alg: No test for 842 (842-scomp)
> > > [    0.466423] ACPI: Added _OSI(Module Device)
> > > [    0.466423] ACPI: Added _OSI(Processor Device)
> > > [    0.466423] ACPI: Added _OSI(3.0 _SCP Extensions)
> > > [    0.466423] ACPI: Added _OSI(Processor Aggregator Device)
> > > [    0.466423] ACPI: Added _OSI(Linux-Dell-Video)
> > > [    0.466423] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
> > > [    0.466423] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
> > > [    0.470797] ACPI: 1 ACPI AML tables successfully acquired and load=
ed
> > > [    0.472465] ACPI: Interpreter enabled
> > > [    0.472490] ACPI: (supports S0 S5)
> > > [    0.472492] ACPI: Using IOAPIC for interrupt routing
> > > [    0.472537] PCI: Using host bridge windows from ACPI; if necessary=
, use "pci=3Dnocrs" and report a bug
> > > [    0.472800] ACPI: Enabled 1 GPEs in block 00 to 3F
> > > [    0.479462] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> > > [    0.479471] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASP=
M ClockPM Segments MSI HPX-Type3]
> > > [    0.479772] acpi PNP0A08:00: _OSC: platform does not support [LTR]
> > > [    0.480064] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug SH=
PCHotplug PME AER PCIeCapability]
> > > [    0.480415] PCI host bridge to bus 0000:00
> > > [    0.480418] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 =
window]
> > > [    0.480420] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff =
window]
> > > [    0.480421] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x0=
00bffff window]
> > > [    0.480423] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xf=
ebfffff window]
> > > [    0.480425] pci_bus 0000:00: root bus resource [mem 0x100000000-0x=
8ffffffff window]
> > > [    0.480427] pci_bus 0000:00: root bus resource [bus 00-ff]
> > > [    0.480469] pci 0000:00:00.0: [8086:29c0] type 00 class 0x060000
> > > [    0.480886] pci 0000:00:01.0: [1b36:0100] type 00 class 0x030000
> > > [    0.481999] pci 0000:00:01.0: reg 0x10: [mem 0xf4000000-0xf7ffffff=
]
> > > [    0.483998] pci 0000:00:01.0: reg 0x14: [mem 0xf8000000-0xfbffffff=
]
> > > [    0.485998] pci 0000:00:01.0: reg 0x18: [mem 0xfce14000-0xfce15fff=
]
> > > [    0.488999] pci 0000:00:01.0: reg 0x1c: [io  0xc040-0xc05f]
> > > [    0.494999] pci 0000:00:01.0: reg 0x30: [mem 0xfce00000-0xfce0ffff=
 pref]
> > > [    0.495264] pci 0000:00:02.0: [1b36:000c] type 01 class 0x060400
> > > [    0.497990] pci 0000:00:02.0: reg 0x10: [mem 0xfce16000-0xfce16fff=
]
> > > [    0.500790] pci 0000:00:02.1: [1b36:000c] type 01 class 0x060400
> > > [    0.501997] pci 0000:00:02.1: reg 0x10: [mem 0xfce17000-0xfce17fff=
]
> > > [    0.504419] pci 0000:00:02.2: [1b36:000c] type 01 class 0x060400
> > > [    0.505690] pci 0000:00:02.2: reg 0x10: [mem 0xfce18000-0xfce18fff=
]
> > > [    0.509025] pci 0000:00:02.3: [1b36:000c] type 01 class 0x060400
> > > [    0.510477] pci 0000:00:02.3: reg 0x10: [mem 0xfce19000-0xfce19fff=
]
> > > [    0.512751] pci 0000:00:02.4: [1b36:000c] type 01 class 0x060400
> > > [    0.513997] pci 0000:00:02.4: reg 0x10: [mem 0xfce1a000-0xfce1afff=
]
> > > [    0.517791] pci 0000:00:02.5: [1b36:000c] type 01 class 0x060400
> > > [    0.518998] pci 0000:00:02.5: reg 0x10: [mem 0xfce1b000-0xfce1bfff=
]
> > > [    0.521403] pci 0000:00:02.6: [1b36:000c] type 01 class 0x060400
> > > [    0.522480] pci 0000:00:02.6: reg 0x10: [mem 0xfce1c000-0xfce1cfff=
]
> > > [    0.525063] pci 0000:00:1b.0: [8086:293e] type 00 class 0x040300
> > > [    0.527000] pci 0000:00:1b.0: reg 0x10: [mem 0xfce10000-0xfce13fff=
]
> > > [    0.530374] pci 0000:00:1f.0: [8086:2918] type 00 class 0x060100
> > > [    0.530723] pci 0000:00:1f.0: quirk: [io  0x0600-0x067f] claimed b=
y ICH6 ACPI/GPIO/TCO
> > > [    0.530989] pci 0000:00:1f.2: [8086:2922] type 00 class 0x010601
> > > [    0.534825] pci 0000:00:1f.2: reg 0x20: [io  0xc060-0xc07f]
> > > [    0.535470] pci 0000:00:1f.2: reg 0x24: [mem 0xfce1d000-0xfce1dfff=
]
> > > [    0.537348] pci 0000:00:1f.3: [8086:2930] type 00 class 0x0c0500
> > > [    0.539410] pci 0000:00:1f.3: reg 0x20: [io  0x0700-0x073f]
> > > [    0.540881] pci 0000:01:00.0: [1af4:1041] type 00 class 0x020000
> > > [    0.541997] pci 0000:01:00.0: reg 0x14: [mem 0xfcc40000-0xfcc40fff=
]
> > > [    0.543997] pci 0000:01:00.0: reg 0x20: [mem 0xfea00000-0xfea03fff=
 64bit pref]
> > > [    0.544996] pci 0000:01:00.0: reg 0x30: [mem 0xfcc00000-0xfcc3ffff=
 pref]
> > > [    0.546808] pci 0000:00:02.0: PCI bridge to [bus 01]
> > > [    0.546830] pci 0000:00:02.0:   bridge window [mem 0xfcc00000-0xfc=
dfffff]
> > > [    0.546850] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfe=
bfffff 64bit pref]
> > > [    0.547470] pci 0000:02:00.0: [1b36:000d] type 00 class 0x0c0330
> > > [    0.547972] pci 0000:02:00.0: reg 0x10: [mem 0xfca00000-0xfca03fff=
 64bit]
> > > [    0.550290] pci 0000:00:02.1: PCI bridge to [bus 02]
> > > [    0.550310] pci 0000:00:02.1:   bridge window [mem 0xfca00000-0xfc=
bfffff]
> > > [    0.550328] pci 0000:00:02.1:   bridge window [mem 0xfe800000-0xfe=
9fffff 64bit pref]
> > > [    0.551012] pci 0000:03:00.0: [1af4:1043] type 00 class 0x078000
> > > [    0.552862] pci 0000:03:00.0: reg 0x14: [mem 0xfc800000-0xfc800fff=
]
> > > [    0.554931] pci 0000:03:00.0: reg 0x20: [mem 0xfe600000-0xfe603fff=
 64bit pref]
> > > [    0.556758] pci 0000:00:02.2: PCI bridge to [bus 03]
> > > [    0.556780] pci 0000:00:02.2:   bridge window [mem 0xfc800000-0xfc=
9fffff]
> > > [    0.556801] pci 0000:00:02.2:   bridge window [mem 0xfe600000-0xfe=
7fffff 64bit pref]
> > > [    0.557445] pci 0000:04:00.0: [1af4:1042] type 00 class 0x010000
> > > [    0.558848] pci 0000:04:00.0: reg 0x14: [mem 0xfc600000-0xfc600fff=
]
> > > [    0.560813] pci 0000:04:00.0: reg 0x20: [mem 0xfe400000-0xfe403fff=
 64bit pref]
> > > [    0.562092] pci 0000:00:02.3: PCI bridge to [bus 04]
> > > [    0.562112] pci 0000:00:02.3:   bridge window [mem 0xfc600000-0xfc=
7fffff]
> > > [    0.562131] pci 0000:00:02.3:   bridge window [mem 0xfe400000-0xfe=
5fffff 64bit pref]
> > > [    0.562822] pci 0000:05:00.0: [1af4:1045] type 00 class 0x00ff00
> > > [    0.565669] pci 0000:05:00.0: reg 0x20: [mem 0xfe200000-0xfe203fff=
 64bit pref]
> > > [    0.566654] pci 0000:00:02.4: PCI bridge to [bus 05]
> > > [    0.566674] pci 0000:00:02.4:   bridge window [mem 0xfc400000-0xfc=
5fffff]
> > > [    0.566693] pci 0000:00:02.4:   bridge window [mem 0xfe200000-0xfe=
3fffff 64bit pref]
> > > [    0.567216] pci 0000:06:00.0: [1af4:1044] type 00 class 0x00ff00
> > > [    0.569228] pci 0000:06:00.0: reg 0x20: [mem 0xfe000000-0xfe003fff=
 64bit pref]
> > > [    0.570334] pci 0000:00:02.5: PCI bridge to [bus 06]
> > > [    0.570354] pci 0000:00:02.5:   bridge window [mem 0xfc200000-0xfc=
3fffff]
> > > [    0.570373] pci 0000:00:02.5:   bridge window [mem 0xfe000000-0xfe=
1fffff 64bit pref]
> > > [    0.571035] pci 0000:00:02.6: PCI bridge to [bus 07]
> > > [    0.571133] pci 0000:00:02.6:   bridge window [mem 0xfc000000-0xfc=
1fffff]
> > > [    0.571153] pci 0000:00:02.6:   bridge window [mem 0xfde00000-0xfd=
ffffff 64bit pref]
> > > [    0.575906] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> > > [    0.576101] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> > > [    0.576296] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> > > [    0.576495] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> > > [    0.576669] ACPI: PCI Interrupt Link [LNKE] (IRQs 5 *10 11)
> > > [    0.576842] ACPI: PCI Interrupt Link [LNKF] (IRQs 5 *10 11)
> > > [    0.577017] ACPI: PCI Interrupt Link [LNKG] (IRQs 5 10 *11)
> > > [    0.577212] ACPI: PCI Interrupt Link [LNKH] (IRQs 5 10 *11)
> > > [    0.577268] ACPI: PCI Interrupt Link [GSIA] (IRQs *16)
> > > [    0.577298] ACPI: PCI Interrupt Link [GSIB] (IRQs *17)
> > > [    0.577326] ACPI: PCI Interrupt Link [GSIC] (IRQs *18)
> > > [    0.577355] ACPI: PCI Interrupt Link [GSID] (IRQs *19)
> > > [    0.577384] ACPI: PCI Interrupt Link [GSIE] (IRQs *20)
> > > [    0.577412] ACPI: PCI Interrupt Link [GSIF] (IRQs *21)
> > > [    0.577465] ACPI: PCI Interrupt Link [GSIG] (IRQs *22)
> > > [    0.577494] ACPI: PCI Interrupt Link [GSIH] (IRQs *23)
> > > [    0.578389] pci 0000:00:01.0: vgaarb: setting as boot VGA device
> > > [    0.578389] pci 0000:00:01.0: vgaarb: VGA device added: decodes=3D=
io+mem,owns=3Dio+mem,locks=3Dnone
> > > [    0.578389] pci 0000:00:01.0: vgaarb: bridge control possible
> > > [    0.578389] vgaarb: loaded
> > > [    0.578389] SCSI subsystem initialized
> > > [    0.578389] libata version 3.00 loaded.
> > > [    0.578389] ACPI: bus type USB registered
> > > [    0.578389] usbcore: registered new interface driver usbfs
> > > [    0.579025] usbcore: registered new interface driver hub
> > > [    0.579116] usbcore: registered new device driver usb
> > > [    0.579355] PCI: Using ACPI for IRQ routing
> > > [    0.616394] PCI: pci_cache_line_size set to 64 bytes
> > > [    0.616575] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> > > [    0.616585] e820: reserve RAM buffer [mem 0x3ffdd000-0x3fffffff]
> > > [    0.616956] NetLabel: Initializing
> > > [    0.616957] NetLabel:  domain hash size =3D 128
> > > [    0.616959] NetLabel:  protocols =3D UNLABELED CIPSOv4 CALIPSO
> > > [    0.616990] NetLabel:  unlabeled traffic allowed by default
> > > [    0.617290] clocksource: Switched to clocksource tsc-early
> > > [    0.666917] VFS: Disk quotas dquot_6.6.0
> > > [    0.666947] VFS: Dquot-cache hash table entries: 512 (order 0, 409=
6 bytes)
> > > [    0.667015] *** VALIDATE hugetlbfs ***
> > > [    0.667169] pnp: PnP ACPI init
> > > [    0.667305] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (act=
ive)
> > > [    0.667387] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (act=
ive)
> > > [    0.667455] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (act=
ive)
> > > [    0.667630] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (act=
ive)
> > > [    0.668253] pnp: PnP ACPI: found 4 devices
> > > [    0.674149] thermal_sys: Registered thermal governor 'step_wise'
> > > [    0.678801] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xfff=
fff, max_idle_ns: 2085701024 ns
> > > [    0.678813] pci 0000:00:02.0: bridge window [io  0x1000-0x0fff] to=
 [bus 01] add_size 1000
> > > [    0.678816] pci 0000:00:02.1: bridge window [io  0x1000-0x0fff] to=
 [bus 02] add_size 1000
> > > [    0.678818] pci 0000:00:02.2: bridge window [io  0x1000-0x0fff] to=
 [bus 03] add_size 1000
> > > [    0.678820] pci 0000:00:02.3: bridge window [io  0x1000-0x0fff] to=
 [bus 04] add_size 1000
> > > [    0.678823] pci 0000:00:02.4: bridge window [io  0x1000-0x0fff] to=
 [bus 05] add_size 1000
> > > [    0.678825] pci 0000:00:02.5: bridge window [io  0x1000-0x0fff] to=
 [bus 06] add_size 1000
> > > [    0.678827] pci 0000:00:02.6: bridge window [io  0x1000-0x0fff] to=
 [bus 07] add_size 1000
> > > [    0.678840] pci 0000:00:02.0: BAR 13: assigned [io  0x1000-0x1fff]
> > > [    0.678842] pci 0000:00:02.1: BAR 13: assigned [io  0x2000-0x2fff]
> > > [    0.678844] pci 0000:00:02.2: BAR 13: assigned [io  0x3000-0x3fff]
> > > [    0.678846] pci 0000:00:02.3: BAR 13: assigned [io  0x4000-0x4fff]
> > > [    0.678849] pci 0000:00:02.4: BAR 13: assigned [io  0x5000-0x5fff]
> > > [    0.678851] pci 0000:00:02.5: BAR 13: assigned [io  0x6000-0x6fff]
> > > [    0.678853] pci 0000:00:02.6: BAR 13: assigned [io  0x7000-0x7fff]
> > > [    0.678862] pci 0000:00:02.0: PCI bridge to [bus 01]
> > > [    0.678870] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
> > > [    0.679761] pci 0000:00:02.0:   bridge window [mem 0xfcc00000-0xfc=
dfffff]
> > > [    0.680278] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfe=
bfffff 64bit pref]
> > > [    0.681290] pci 0000:00:02.1: PCI bridge to [bus 02]
> > > [    0.681298] pci 0000:00:02.1:   bridge window [io  0x2000-0x2fff]
> > > [    0.682074] pci 0000:00:02.1:   bridge window [mem 0xfca00000-0xfc=
bfffff]
> > > [    0.682546] pci 0000:00:02.1:   bridge window [mem 0xfe800000-0xfe=
9fffff 64bit pref]
> > > [    0.683542] pci 0000:00:02.2: PCI bridge to [bus 03]
> > > [    0.683550] pci 0000:00:02.2:   bridge window [io  0x3000-0x3fff]
> > > [    0.684313] pci 0000:00:02.2:   bridge window [mem 0xfc800000-0xfc=
9fffff]
> > > [    0.684813] pci 0000:00:02.2:   bridge window [mem 0xfe600000-0xfe=
7fffff 64bit pref]
> > > [    0.686925] pci 0000:00:02.3: PCI bridge to [bus 04]
> > > [    0.686937] pci 0000:00:02.3:   bridge window [io  0x4000-0x4fff]
> > > [    0.687754] pci 0000:00:02.3:   bridge window [mem 0xfc600000-0xfc=
7fffff]
> > > [    0.688262] pci 0000:00:02.3:   bridge window [mem 0xfe400000-0xfe=
5fffff 64bit pref]
> > > [    0.689263] pci 0000:00:02.4: PCI bridge to [bus 05]
> > > [    0.689337] pci 0000:00:02.4:   bridge window [io  0x5000-0x5fff]
> > > [    0.690144] pci 0000:00:02.4:   bridge window [mem 0xfc400000-0xfc=
5fffff]
> > > [    0.690635] pci 0000:00:02.4:   bridge window [mem 0xfe200000-0xfe=
3fffff 64bit pref]
> > > [    0.691629] pci 0000:00:02.5: PCI bridge to [bus 06]
> > > [    0.691650] pci 0000:00:02.5:   bridge window [io  0x6000-0x6fff]
> > > [    0.692392] pci 0000:00:02.5:   bridge window [mem 0xfc200000-0xfc=
3fffff]
> > > [    0.692888] pci 0000:00:02.5:   bridge window [mem 0xfe000000-0xfe=
1fffff 64bit pref]
> > > [    0.693890] pci 0000:00:02.6: PCI bridge to [bus 07]
> > > [    0.693898] pci 0000:00:02.6:   bridge window [io  0x7000-0x7fff]
> > > [    0.694657] pci 0000:00:02.6:   bridge window [mem 0xfc000000-0xfc=
1fffff]
> > > [    0.695153] pci 0000:00:02.6:   bridge window [mem 0xfde00000-0xfd=
ffffff 64bit pref]
> > > [    0.696197] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> > > [    0.696199] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
> > > [    0.696200] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff=
 window]
> > > [    0.696202] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xfebfffff=
 window]
> > > [    0.696204] pci_bus 0000:00: resource 8 [mem 0x100000000-0x8ffffff=
ff window]
> > > [    0.696206] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
> > > [    0.696207] pci_bus 0000:01: resource 1 [mem 0xfcc00000-0xfcdfffff=
]
> > > [    0.696209] pci_bus 0000:01: resource 2 [mem 0xfea00000-0xfebfffff=
 64bit pref]
> > > [    0.696211] pci_bus 0000:02: resource 0 [io  0x2000-0x2fff]
> > > [    0.696213] pci_bus 0000:02: resource 1 [mem 0xfca00000-0xfcbfffff=
]
> > > [    0.696215] pci_bus 0000:02: resource 2 [mem 0xfe800000-0xfe9fffff=
 64bit pref]
> > > [    0.696216] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
> > > [    0.696218] pci_bus 0000:03: resource 1 [mem 0xfc800000-0xfc9fffff=
]
> > > [    0.696220] pci_bus 0000:03: resource 2 [mem 0xfe600000-0xfe7fffff=
 64bit pref]
> > > [    0.696221] pci_bus 0000:04: resource 0 [io  0x4000-0x4fff]
> > > [    0.696223] pci_bus 0000:04: resource 1 [mem 0xfc600000-0xfc7fffff=
]
> > > [    0.696224] pci_bus 0000:04: resource 2 [mem 0xfe400000-0xfe5fffff=
 64bit pref]
> > > [    0.696226] pci_bus 0000:05: resource 0 [io  0x5000-0x5fff]
> > > [    0.696228] pci_bus 0000:05: resource 1 [mem 0xfc400000-0xfc5fffff=
]
> > > [    0.696229] pci_bus 0000:05: resource 2 [mem 0xfe200000-0xfe3fffff=
 64bit pref]
> > > [    0.696231] pci_bus 0000:06: resource 0 [io  0x6000-0x6fff]
> > > [    0.696233] pci_bus 0000:06: resource 1 [mem 0xfc200000-0xfc3fffff=
]
> > > [    0.696234] pci_bus 0000:06: resource 2 [mem 0xfe000000-0xfe1fffff=
 64bit pref]
> > > [    0.696236] pci_bus 0000:07: resource 0 [io  0x7000-0x7fff]
> > > [    0.696238] pci_bus 0000:07: resource 1 [mem 0xfc000000-0xfc1fffff=
]
> > > [    0.696239] pci_bus 0000:07: resource 2 [mem 0xfde00000-0xfdffffff=
 64bit pref]
> > > [    0.696374] NET: Registered protocol family 2
> > > [    0.696806] tcp_listen_portaddr_hash hash table entries: 512 (orde=
r: 3, 45056 bytes, linear)
> > > [    0.696822] TCP established hash table entries: 8192 (order: 4, 65=
536 bytes, linear)
> > > [    0.696871] TCP bind hash table entries: 8192 (order: 7, 655360 by=
tes, linear)
> > > [    0.697094] TCP: Hash tables configured (established 8192 bind 819=
2)
> > > [    0.697170] UDP hash table entries: 512 (order: 4, 98304 bytes, li=
near)
> > > [    0.697199] UDP-Lite hash table entries: 512 (order: 4, 98304 byte=
s, linear)
> > > [    0.697292] NET: Registered protocol family 1
> > > [    0.697301] NET: Registered protocol family 44
> > > [    0.698648] pci 0000:00:01.0: Video device with shadowed ROM at [m=
em 0x000c0000-0x000dffff]
> > > [    0.699995] PCI Interrupt Link [GSIG] enabled at IRQ 22
> > > [    0.703249] PCI: CLS 0 bytes, default 64
> > > [    0.703403] Unpacking initramfs...
> > > [    1.167012] Freeing initrd memory: 30308K
> > > [    1.168760] check: Scanning for low memory corruption every 60 sec=
onds
> > > [    1.172086] Initialise system trusted keyrings
> > > [    1.172147] Key type blacklist registered
> > > [    1.172311] workingset: timestamp_bits=3D36 max_order=3D18 bucket_=
order=3D0
> > > [    1.178469] zbud: loaded
> > > [    1.186015] NET: Registered protocol family 38
> > > [    1.186030] Key type asymmetric registered
> > > [    1.186052] Asymmetric key parser 'x509' registered
> > > [    1.186068] Block layer SCSI generic (bsg) driver version 0.4 load=
ed (major 250)
> > > [    1.186263] io scheduler mq-deadline registered
> > > [    1.186265] io scheduler kyber registered
> > > [    1.186343] io scheduler bfq registered
> > > [    1.187052] atomic64_test: passed for x86-64 platform with CX8 and=
 with SSE
> > > [    1.190203] pcieport 0000:00:02.0: PME: Signaling with IRQ 24
> > > [    1.190532] pcieport 0000:00:02.0: AER: enabled with IRQ 24
> > > [    1.190608] pcieport 0000:00:02.0: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.191848] pcieport 0000:00:02.1: PME: Signaling with IRQ 25
> > > [    1.192148] pcieport 0000:00:02.1: AER: enabled with IRQ 25
> > > [    1.192227] pcieport 0000:00:02.1: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.195319] pcieport 0000:00:02.2: PME: Signaling with IRQ 26
> > > [    1.195581] pcieport 0000:00:02.2: AER: enabled with IRQ 26
> > > [    1.195690] pcieport 0000:00:02.2: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.198778] pcieport 0000:00:02.3: PME: Signaling with IRQ 27
> > > [    1.199414] pcieport 0000:00:02.3: AER: enabled with IRQ 27
> > > [    1.199497] pcieport 0000:00:02.3: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.202348] pcieport 0000:00:02.4: PME: Signaling with IRQ 28
> > > [    1.202630] pcieport 0000:00:02.4: AER: enabled with IRQ 28
> > > [    1.202720] pcieport 0000:00:02.4: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.205424] pcieport 0000:00:02.5: PME: Signaling with IRQ 29
> > > [    1.205721] pcieport 0000:00:02.5: AER: enabled with IRQ 29
> > > [    1.205796] pcieport 0000:00:02.5: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.208826] pcieport 0000:00:02.6: PME: Signaling with IRQ 30
> > > [    1.209107] pcieport 0000:00:02.6: AER: enabled with IRQ 30
> > > [    1.209184] pcieport 0000:00:02.6: pciehp: Slot #0 AttnBtn+ PwrCtr=
l+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock+ NoCompl- LLActRep-
> > > [    1.209888] pcieport 0000:00:02.6: pciehp: Slot(0-6): Link Up
> > > [    1.210131] shpchp: Standard Hot Plug PCI Controller Driver versio=
n: 0.4
> > > [    1.210175] intel_idle: Please enable MWAIT in BIOS SETUP
> > > [    1.210298] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:0=
0/input/input0
> > > [    1.210437] ACPI: Power Button [PWRF]
> > > [    1.220791] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabl=
ed
> > > [    1.243371] 00:03: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 11=
5200) is a 16550A
> > > [    1.249682] Non-volatile memory driver v1.3
> > > [    1.250423] random: fast init done
> > > [    1.250526] random: crng init done
> > > [    1.251558] ahci 0000:00:1f.2: version 3.0
> > > [    1.252776] PCI Interrupt Link [GSIA] enabled at IRQ 16
> > > [    1.253330] ahci 0000:00:1f.2: AHCI 0001.0000 32 slots 6 ports 1.5=
 Gbps 0x3f impl SATA mode
> > > [    1.253332] ahci 0000:00:1f.2: flags: 64bit ncq only
> > > [    1.255383] scsi host0: ahci
> > > [    1.255830] scsi host1: ahci
> > > [    1.256198] scsi host2: ahci
> > > [    1.256482] scsi host3: ahci
> > > [    1.256796] scsi host4: ahci
> > > [    1.257151] scsi host5: ahci
> > > [    1.257277] ata1: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d100 irq 31
> > > [    1.257283] ata2: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d180 irq 31
> > > [    1.257288] ata3: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d200 irq 31
> > > [    1.257294] ata4: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d280 irq 31
> > > [    1.257299] ata5: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d300 irq 31
> > > [    1.257305] ata6: SATA max UDMA/133 abar m4096@0xfce1d000 port 0xf=
ce1d380 irq 31
> > > [    1.257606] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Dr=
iver
> > > [    1.257630] ehci-pci: EHCI PCI platform driver
> > > [    1.259193] xhci_hcd 0000:02:00.0: xHCI Host Controller
> > > [    1.259594] xhci_hcd 0000:02:00.0: new USB bus registered, assigne=
d bus number 1
> > > [    1.260018] xhci_hcd 0000:02:00.0: hcc params 0x00087001 hci versi=
on 0x100 quirks 0x0000000000000010
> > > [    1.261600] usb usb1: New USB device found, idVendor=3D1d6b, idPro=
duct=3D0002, bcdDevice=3D 5.03
> > > [    1.261605] usb usb1: New USB device strings: Mfr=3D3, Product=3D2=
, SerialNumber=3D1
> > > [    1.261607] usb usb1: Product: xHCI Host Controller
> > > [    1.261609] usb usb1: Manufacturer: Linux 5.3.0-rc4 xhci-hcd
> > > [    1.261610] usb usb1: SerialNumber: 0000:02:00.0
> > > [    1.262077] hub 1-0:1.0: USB hub found
> > > [    1.262192] hub 1-0:1.0: 15 ports detected
> > > [    1.263572] xhci_hcd 0000:02:00.0: xHCI Host Controller
> > > [    1.263747] xhci_hcd 0000:02:00.0: new USB bus registered, assigne=
d bus number 2
> > > [    1.263754] xhci_hcd 0000:02:00.0: Host supports USB 3.0 SuperSpee=
d
> > > [    1.263816] usb usb2: We don't know the algorithms for LPM for thi=
s host, disabling LPM.
> > > [    1.263869] usb usb2: New USB device found, idVendor=3D1d6b, idPro=
duct=3D0003, bcdDevice=3D 5.03
> > > [    1.263871] usb usb2: New USB device strings: Mfr=3D3, Product=3D2=
, SerialNumber=3D1
> > > [    1.263873] usb usb2: Product: xHCI Host Controller
> > > [    1.263874] usb usb2: Manufacturer: Linux 5.3.0-rc4 xhci-hcd
> > > [    1.263876] usb usb2: SerialNumber: 0000:02:00.0
> > > [    1.264203] hub 2-0:1.0: USB hub found
> > > [    1.264302] hub 2-0:1.0: 15 ports detected
> > > [    1.265710] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] =
at 0x60,0x64 irq 1,12
> > > [    1.266536] serio: i8042 KBD port at 0x60,0x64 irq 1
> > > [    1.266717] serio: i8042 AUX port at 0x60,0x64 irq 12
> > > [    1.266936] mousedev: PS/2 mouse device common for all mice
> > > [    1.267498] input: AT Translated Set 2 keyboard as /devices/platfo=
rm/i8042/serio0/input/input1
> > > [    1.268145] rtc_cmos 00:00: RTC can wake from S4
> > > [    1.269031] rtc_cmos 00:00: registered as rtc0
> > > [    1.269300] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes n=
vram
> > > [    1.269674] device-mapper: uevent: version 1.0.3
> > > [    1.270368] device-mapper: ioctl: 4.40.0-ioctl (2019-01-18) initia=
lised: dm-devel@redhat.com
> > > [    1.270402] intel_pstate: CPU model not supported
> > > [    1.270602] hidraw: raw HID events driver (C) Jiri Kosina
> > > [    1.270677] usbcore: registered new interface driver usbhid
> > > [    1.270679] usbhid: USB HID core driver
> > > [    1.270765] drop_monitor: Initializing network drop monitor servic=
e
> > > [    1.270878] Initializing XFRM netlink socket
> > > [    1.271294] NET: Registered protocol family 10
> > > [    1.277479] Segment Routing with IPv6
> > > [    1.277501] mip6: Mobile IPv6
> > > [    1.277504] NET: Registered protocol family 17
> > > [    1.278276] AVX2 version of gcm_enc/dec engaged.
> > > [    1.278278] AES CTR mode by8 optimization enabled
> > > [    1.339131] sched_clock: Marking stable (1323202088, 15909453)->(1=
435946725, -96835184)
> > > [    1.339977] registered taskstats version 1
> > > [    1.340023] Loading compiled-in X.509 certificates
> > > [    1.377075] Loaded X.509 cert 'Build time autogenerated kernel key=
: 7a85aefae658c9802b7828ba03d443687ccdd1e2'
> > > [    1.377457] zswap: loaded using pool lzo/z3fold
> > > [    1.387955] Key type big_key registered
> > > [    1.393681] Key type encrypted registered
> > > [    1.394519] PM:   Magic number: 15:617:66
> > > [    1.394685] rtc_cmos 00:00: setting system clock to 2019-08-18T07:=
03:46 UTC (1566111826)
> > > [    1.564505] ata6: SATA link down (SStatus 0 SControl 300)
> > > [    1.565190] ata3: SATA link down (SStatus 0 SControl 300)
> > > [    1.565743] ata2: SATA link down (SStatus 0 SControl 300)
> > > [    1.566268] ata4: SATA link down (SStatus 0 SControl 300)
> > > [    1.566870] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> > > [    1.567515] ata5: SATA link down (SStatus 0 SControl 300)
> > > [    1.567665] ata1.00: ATAPI: QEMU DVD-ROM, 2.5+, max UDMA/100
> > > [    1.567673] ata1.00: applying bridge limits
> > > [    1.568238] ata1.00: configured for UDMA/100
> > > [    1.570241] scsi 0:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM =
    2.5+ PQ: 0 ANSI: 5
> > > [    1.571380] scsi 0:0:0:0: Attached scsi generic sg0 type 5
> > > [    1.589070] usb 1-1: new high-speed USB device number 2 using xhci=
_hcd
> > > [    1.694290] usb 1-1: New USB device found, idVendor=3D0627, idProd=
uct=3D0001, bcdDevice=3D 0.00
> > > [    1.694301] usb 1-1: New USB device strings: Mfr=3D1, Product=3D3,=
 SerialNumber=3D5
> > > [    1.694305] usb 1-1: Product: QEMU USB Tablet
> > > [    1.694308] usb 1-1: Manufacturer: QEMU
> > > [    1.694312] usb 1-1: SerialNumber: 42
> > > [    1.697583] input: QEMU QEMU USB Tablet as /devices/pci0000:00/000=
0:00:02.1/0000:02:00.0/usb1/1-1/1-1:1.0/0003:0627:0001.0001/input/input4
> > > [    1.698972] hid-generic 0003:0627:0001.0001: input,hidraw0: USB HI=
D v0.01 Mouse [QEMU QEMU USB Tablet] on usb-0000:02:00.0-1/input0
> > > [    1.888111] input: ImExPS/2 Generic Explorer Mouse as /devices/pla=
tform/i8042/serio1/input/input3
> > > [    1.896745] Freeing unused kernel image memory: 4600K
> > > [    1.897015] Write protecting the kernel read-only data: 18432k
> > > [    1.898730] Freeing unused kernel image memory: 2032K
> > > [    1.899093] Freeing unused kernel image memory: 56K
> > > [    1.905259] x86/mm: Checked W+X mappings: passed, no W+X pages fou=
nd.
> > > [    1.905264] rodata_test: all tests were successful
> > > [    1.905266] x86/mm: Checking user space page tables
> > > [    1.910234] x86/mm: Checked W+X mappings: passed, no W+X pages fou=
nd.
> > > [    1.910237] Run /init as init process
> > > [    1.924283] systemd[1]: systemd v241-10.git511646b.fc30 running in=
 system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +=
LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD=
 +IDN2 -IDN +PCRE2 default-hierarchy=3Dhybrid)
> > > [    1.924418] systemd[1]: Detected virtualization kvm.
> > > [    1.924424] systemd[1]: Detected architecture x86-64.
> > > [    1.924427] systemd[1]: Running in initial RAM disk.
> > > [    1.927369] systemd[1]: Set hostname to <localhost.localdomain>.
> > > [    2.010753] systemd[1]: Reached target Slices.
> > > [    2.011080] systemd[1]: Listening on Journal Socket.
> > > [    2.014783] systemd[1]: Starting Setup Virtual Console...
> > > [    2.016898] systemd[1]: Starting Create list of required static de=
vice nodes for the current kernel...
> > > [    2.017194] systemd[1]: Listening on Journal Socket (/dev/log).
> > > [    2.226188] tsc: Refined TSC clocksource calibration: 3198.162 MHz
> > > [    2.226224] clocksource: tsc: mask: 0xffffffffffffffff max_cycles:=
 0x2e1981b195d, max_idle_ns: 440795241252 ns
> > > [    2.226391] clocksource: Switched to clocksource tsc
> > > [    2.279306] audit: type=3D1130 audit(1566111827.383:2): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsystem=
d-journald comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=3D? a=
ddr=3D? terminal=3D? res=3Dsuccess'
> > > [    2.296544] audit: type=3D1130 audit(1566111827.400:3): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Ddracut=
-cmdline comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=3D? add=
r=3D? terminal=3D? res=3Dsuccess'
> > > [    2.491865] audit: type=3D1130 audit(1566111827.595:4): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsystem=
d-udevd comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=3D? addr=
=3D? terminal=3D? res=3Dsuccess'
> > > [    2.642435] audit: type=3D1130 audit(1566111827.740:5): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsystem=
d-udev-trigger comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=
=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    2.660587] virtio_blk virtio2: [vda] 83886080 512-byte logical bl=
ocks (42.9 GB/40.0 GiB)
> > > [    2.665577]  vda: vda1 vda2
> > > [    2.667033] audit: type=3D1130 audit(1566111827.769:6): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dplymou=
th-start comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=3D? add=
r=3D? terminal=3D? res=3Dsuccess'
> > > [    2.667463] Linux agpgart interface v0.103
> > > [    2.882716] PCI Interrupt Link [GSIF] enabled at IRQ 21
> > > [    2.882776] qxl 0000:00:01.0: remove_conflicting_pci_framebuffers:=
 bar 0: 0xf4000000 -> 0xf7ffffff
> > > [    2.882779] qxl 0000:00:01.0: remove_conflicting_pci_framebuffers:=
 bar 1: 0xf8000000 -> 0xfbffffff
> > > [    2.882780] qxl 0000:00:01.0: remove_conflicting_pci_framebuffers:=
 bar 2: 0xfce14000 -> 0xfce15fff
> > > [    2.882817] qxl 0000:00:01.0: vgaarb: deactivate vga console
> > > [    2.939874] Console: switching to colour dummy device 80x25
> > > [    2.940619] [drm] Device Version 0.0
> > > [    2.940621] [drm] Compression level 0 log level 0
> > > [    2.940623] [drm] 12286 io pages at offset 0x1000000
> > > [    2.940624] [drm] 16777216 byte draw area at offset 0x0
> > > [    2.940625] [drm] RAM header offset: 0x3ffe000
> > > [    2.940918] [TTM] Zone  kernel: Available graphics memory: 491528 =
KiB
> > > [    2.940925] [TTM] Initializing pool allocator
> > > [    2.940938] [TTM] Initializing DMA pool allocator
> > > [    2.940958] [drm] qxl: 16M of VRAM memory size
> > > [    2.940959] [drm] qxl: 63M of IO pages memory ready (VRAM domain)
> > > [    2.940960] [drm] qxl: 64M of Surface memory size
> > > [    2.942598] [drm] slot 0 (main): base 0xf4000000, size 0x03ffe000,=
 gpu_offset 0x20000000000
> > > [    2.942775] [drm] slot 1 (surfaces): base 0xf8000000, size 0x04000=
000, gpu_offset 0x30000000000
> > > [    2.944286] [drm] Initialized qxl 0.1.0 20120117 for 0000:00:01.0 =
on minor 0
> > > [    2.946084] fbcon: qxldrmfb (fb0) is primary device
> > > [    2.950504] Console: switching to colour frame buffer device 128x4=
8
> > > [    2.954556] qxl 0000:00:01.0: fb0: qxldrmfb frame buffer device
> > > [    2.958453] setfont (442) used greatest stack depth: 13072 bytes l=
eft
> > > [    2.972895] setfont (445) used greatest stack depth: 12096 bytes l=
eft
> > > [    3.288119] PM: Image not found (code -22)
> > > [    3.291486] audit: type=3D1130 audit(1566111828.395:7): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsystem=
d-hibernate-resume@dev-mapper-fedora\x2dswap comm=3D"systemd" exe=3D"/usr/l=
ib/systemd/systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    3.291494] audit: type=3D1131 audit(1566111828.395:8): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsystem=
d-hibernate-resume@dev-mapper-fedora\x2dswap comm=3D"systemd" exe=3D"/usr/l=
ib/systemd/systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    3.301062] audit: type=3D1130 audit(1566111828.404:9): pid=3D1 ui=
d=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Ddracut=
-initqueue comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostname=3D? a=
ddr=3D? terminal=3D? res=3Dsuccess'
> > > [    3.317949] audit: type=3D1130 audit(1566111828.421:10): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dkernel msg=3D'unit=3Dsyste=
md-tmpfiles-setup comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" hostnam=
e=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    3.436368] EXT4-fs (dm-0): mounted filesystem with ordered data m=
ode. Opts: (null)
> > > [    3.475049] pcieport 0000:00:02.6: pciehp: Failed to check link st=
atus
> > > [    3.659755] systemd-udevd (388) used greatest stack depth: 11184 b=
ytes left
> > > [    3.788853] systemd-journald[312]: Received SIGTERM from PID 1 (sy=
stemd).
> > > [    3.851799] printk: systemd: 19 output lines suppressed due to rat=
elimiting
> > > [    4.458752] SELinux:  policy capability network_peer_controls=3D1
> > > [    4.458763] SELinux:  policy capability open_perms=3D1
> > > [    4.458764] SELinux:  policy capability extended_socket_class=3D1
> > > [    4.458765] SELinux:  policy capability always_check_network=3D0
> > > [    4.458767] SELinux:  policy capability cgroup_seclabel=3D1
> > > [    4.458768] SELinux:  policy capability nnp_nosuid_transition=3D1
> > > [    4.522670] systemd[1]: Successfully loaded SELinux policy in 628.=
964ms.
> > > [    4.575048] systemd[1]: Relabelled /dev, /dev/shm, /run, /sys/fs/c=
group in 33.264ms.
> > > [    4.577954] systemd[1]: systemd v241-10.git511646b.fc30 running in=
 system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +=
LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD=
 +IDN2 -IDN +PCRE2 default-hierarchy=3Dhybrid)
> > > [    4.578068] systemd[1]: Detected virtualization kvm.
> > > [    4.578081] systemd[1]: Detected architecture x86-64.
> > > [    4.579420] systemd[1]: Set hostname to <localhost.localdomain>.
> > > [    4.670011] systemd[1]: /usr/lib/systemd/system/sssd.service:11: P=
IDFile=3D references path below legacy directory /var/run/, updating /var/r=
un/sssd.pid ??? /run/sssd.pid; please update the unit file accordingly.
> > > [    4.735660] systemd[1]: initrd-switch-root.service: Succeeded.
> > > [    4.737494] systemd[1]: Stopped Switch Root.
> > > [    4.738466] systemd[1]: systemd-journald.service: Service has no h=
old-off time (RestartSec=3D0), scheduling restart.
> > > [    4.738521] systemd[1]: systemd-journald.service: Scheduled restar=
t job, restart counter is at 1.
> > > [    4.738543] systemd[1]: Stopped Journal Service.
> > > [    4.779169] Adding 4194300k swap on /dev/mapper/fedora-swap.  Prio=
rity:-2 extents:1 across:4194300k FS
> > > [    4.855064] EXT4-fs (dm-0): re-mounted. Opts: (null)
> > > [    5.033110] systemd-journald[569]: Received request to flush runti=
me journal from PID 1
> > > [    5.371855] kauditd_printk_skb: 39 callbacks suppressed
> > > [    5.371857] audit: type=3D1130 audit(1566111830.474:50): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dlvm2-monitor comm=3D"systemd" exe=3D"/usr/lib/systemd/syste=
md" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.409562] virtio_net virtio0 enp1s0: renamed from eth0
> > > [    5.496216] audit: type=3D1130 audit(1566111830.600:51): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dlvm2-pvscan@252:2 comm=3D"systemd" exe=3D"/usr/lib/systemd/=
systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.520718] audit: type=3D1130 audit(1566111830.624:52): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dsystemd-fsck@dev-disk-by\x2duuid-b74243f6\x2decfa\x2d48ac\x=
2d9a7a\x2d325447d248ed comm=3D"systemd" exe=3D"/usr/lib/systemd/systemd" ho=
stname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.537266] EXT4-fs (vda1): mounted filesystem with ordered data m=
ode. Opts: (null)
> > > [    5.561042] audit: type=3D1130 audit(1566111830.664:53): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Ddracut-shutdown comm=3D"systemd" exe=3D"/usr/lib/systemd/sy=
stemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.569117] audit: type=3D1130 audit(1566111830.673:54): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dplymouth-read-write comm=3D"systemd" exe=3D"/usr/lib/system=
d/systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.569125] audit: type=3D1131 audit(1566111830.673:55): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dplymouth-read-write comm=3D"systemd" exe=3D"/usr/lib/system=
d/systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.615617] audit: type=3D1130 audit(1566111830.719:56): pid=3D1 u=
id=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:init_t:s=
0 msg=3D'unit=3Dsystemd-tmpfiles-setup comm=3D"systemd" exe=3D"/usr/lib/sys=
temd/systemd" hostname=3D? addr=3D? terminal=3D? res=3Dsuccess'
> > > [    5.645087] audit: type=3D1305 audit(1566111830.749:57): op=3Dset =
audit_enabled=3D1 old=3D1 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_=
u:system_r:auditd_t:s0 res=3D1
> > > [   14.951245] pool-NetworkMan (813) used greatest stack depth: 11152=
 bytes left
> > > [   19.981798] stress (1024) used greatest stack depth: 10848 bytes l=
eft
> > > [   20.011727] stress (1025) used greatest stack depth: 10544 bytes l=
eft
> > > [  105.710330] BUG: unable to handle page fault for address: ffffd2df=
8a000028
> > > [  105.714547] #PF: supervisor read access in kernel mode
> > > [  105.717893] #PF: error_code(0x0000) - not-present page
> > > [  105.721227] PGD 0 P4D 0
> > > [  105.722884] Oops: 0000 [#1] SMP PTI
> > > [  105.725152] CPU: 0 PID: 1240 Comm: stress Not tainted 5.3.0-rc4 #6=
9
> > > [  105.729219] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [  105.734756] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [  105.737801] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [  105.749901] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > [  105.753230] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX: 00000=
00000000000
> > > [  105.757754] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI: ffff9=
0edb5fdd600
> > > [  105.762362] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09: 00000=
00000000000
> > > [  105.766973] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
0edbab538d8
> > > [  105.771577] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15: ffffa=
82d809a3438
> > > [  105.776190] FS:  00007ff6a887b740(0000) GS:ffff90edbe400000(0000) =
knlGS:0000000000000000
> > > [  105.780549] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  105.781436] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4: 00000=
00000160ef0
> > > [  105.782365] Call Trace:
> > > [  105.782668]  zswap_writeback_entry+0x50/0x410
> > > [  105.783199]  z3fold_zpool_shrink+0x4a6/0x540
> > > [  105.783717]  zswap_frontswap_store+0x424/0x7c1
> > > [  105.784329]  __frontswap_store+0xc4/0x162
> > > [  105.784815]  swap_writepage+0x39/0x70
> > > [  105.785282]  pageout.isra.0+0x12c/0x5d0
> > > [  105.785730]  shrink_page_list+0x1124/0x1830
> > > [  105.786335]  shrink_inactive_list+0x1da/0x460
> > > [  105.786882]  ? lruvec_lru_size+0x10/0x130
> > > [  105.787472]  shrink_node_memcg+0x202/0x770
> > > [  105.788011]  ? sched_clock_cpu+0xc/0xc0
> > > [  105.788594]  shrink_node+0xdc/0x4a0
> > > [  105.789012]  do_try_to_free_pages+0xdb/0x3c0
> > > [  105.789528]  try_to_free_pages+0x112/0x2e0
> > > [  105.790009]  __alloc_pages_slowpath+0x422/0x1000
> > > [  105.790547]  ? __lock_acquire+0x247/0x1900
> > > [  105.791040]  __alloc_pages_nodemask+0x37f/0x400
> > > [  105.791580]  alloc_pages_vma+0x79/0x1e0
> > > [  105.792064]  __read_swap_cache_async+0x1ec/0x3e0
> > > [  105.792639]  swap_cluster_readahead+0x184/0x330
> > > [  105.793194]  ? find_held_lock+0x32/0x90
> > > [  105.793681]  swapin_readahead+0x2b4/0x4e0
> > > [  105.794182]  ? sched_clock_cpu+0xc/0xc0
> > > [  105.794668]  do_swap_page+0x3ac/0xc30
> > > [  105.795658]  __handle_mm_fault+0x8dd/0x1900
> > > [  105.796729]  handle_mm_fault+0x159/0x340
> > > [  105.797723]  do_user_addr_fault+0x1fe/0x480
> > > [  105.798736]  do_page_fault+0x31/0x210
> > > [  105.799700]  page_fault+0x3e/0x50
> > > [  105.800597] RIP: 0033:0x56076f49e298
> > > [  105.801561] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [  105.804770] RSP: 002b:00007ffe5fc72e70 EFLAGS: 00010206
> > > [  105.805931] RAX: 00000000013ad000 RBX: ffffffffffffffff RCX: 00007=
ff6a8974156
> > > [  105.807300] RDX: 0000000000000000 RSI: 000000000b78d000 RDI: 00000=
00000000000
> > > [  105.808679] RBP: 00007ff69d0ee010 R08: 00007ff69d0ee010 R09: 00000=
00000000000
> > > [  105.810055] R10: 00007ff69e49a010 R11: 0000000000000246 R12: 00005=
6076f4a0004
> > > [  105.811383] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b78cc00
> > > [  105.812713] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw agpgart virtio_blk vi=
rtio_console qemu_fw_cfg
> > > [  105.821561] CR2: ffffd2df8a000028
> > > [  105.822552] ---[ end trace d5f24e2cb83a2b76 ]---
> > > [  105.823659] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [  105.824785] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [  105.828082] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > [  105.829287] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX: 00000=
00000000000
> > > [  105.830713] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI: ffff9=
0edb5fdd600
> > > [  105.832157] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09: 00000=
00000000000
> > > [  105.833607] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
0edbab538d8
> > > [  105.835054] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15: ffffa=
82d809a3438
> > > [  105.836489] FS:  00007ff6a887b740(0000) GS:ffff90edbe400000(0000) =
knlGS:0000000000000000
> > > [  105.838103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  105.839405] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4: 00000=
00000160ef0
> > > [  105.840883] ------------[ cut here ]------------
> > > [  105.842087] WARNING: CPU: 0 PID: 1240 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [  105.843617] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw agpgart virtio_blk vi=
rtio_console qemu_fw_cfg
> > > [  105.853356] CPU: 0 PID: 1240 Comm: stress Tainted: G      D       =
    5.3.0-rc4 #69
> > > [  105.855037] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [  105.856808] RIP: 0010:do_exit.cold+0xc/0x121
> > > [  105.858102] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a a4 e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [  105.862117] RSP: 0018:ffffa82d809a3ee0 EFLAGS: 00010046
> > > [  105.863543] RAX: 0000000000000024 RBX: ffff90ed93508000 RCX: 00000=
00000000006
> > > [  105.865202] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
0edbe5d89c0
> > > [  105.866914] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [  105.868557] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [  105.870252] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000000
> > > [  105.871946] FS:  00007ff6a887b740(0000) GS:ffff90edbe400000(0000) =
knlGS:0000000000000000
> > > [  105.873734] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  105.875277] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4: 00000=
00000160ef0
> > > [  105.876980] Call Trace:
> > > [  105.878097]  rewind_stack_do_exit+0x17/0x20
> > > [  105.879410] irq event stamp: 31721678
> > > [  105.880621] hardirqs last  enabled at (31721677): [<ffffffffa39d5b=
63>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [  105.882591] hardirqs last disabled at (31721678): [<ffffffffa3001b=
ea>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [  105.884745] softirqs last  enabled at (31721518): [<ffffffffa3c003=
51>] __do_softirq+0x351/0x451
> > > [  105.886902] softirqs last disabled at (31721503): [<ffffffffa30c98=
21>] irq_exit+0xf1/0x100
> > > [  105.889025] ---[ end trace d5f24e2cb83a2b77 ]---
> > > [  105.890553] BUG: sleeping function called from invalid context at =
include/linux/percpu-rwsem.h:38
> > > [  105.892618] in_atomic(): 0, irqs_disabled(): 1, pid: 1240, name: s=
tress
> > > [  105.894396] INFO: lockdep is turned off.
> > > [  105.895745] irq event stamp: 31721678
> > > [  105.897080] hardirqs last  enabled at (31721677): [<ffffffffa39d5b=
63>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [  105.899321] hardirqs last disabled at (31721678): [<ffffffffa3001b=
ea>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [  105.901531] softirqs last  enabled at (31721518): [<ffffffffa3c003=
51>] __do_softirq+0x351/0x451
> > > [  105.903598] softirqs last disabled at (31721503): [<ffffffffa30c98=
21>] irq_exit+0xf1/0x100
> > > [  105.905554] CPU: 0 PID: 1240 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [  105.907504] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [  105.909566] Call Trace:
> > > [  105.910696]  dump_stack+0x67/0x90
> > > [  105.911953]  ___might_sleep.cold+0x9f/0xaf
> > > [  105.913301]  exit_signals+0x30/0x330
> > > [  105.914573]  do_exit+0xcb/0xcd0
> > > [  105.915809]  rewind_stack_do_exit+0x17/0x20
> >
> >
> > > Fedora 30 (Thirty)
> > > Kernel 5.3.0-rc4 on an x86_64 (ttyS0)
> > >
> > > localhost login: [   66.090333] BUG: unable to handle page fault for =
address: ffffeab2e2000028
> > > [   66.091245] #PF: supervisor read access in kernel mode
> > > [   66.091904] #PF: error_code(0x0000) - not-present page
> > > [   66.092552] PGD 0 P4D 0
> > > [   66.092885] Oops: 0000 [#1] SMP PTI
> > > [   66.093332] CPU: 2 PID: 1193 Comm: stress Not tainted 5.3.0-rc4 #6=
9
> > > [   66.094127] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.095204] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.095799] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   66.098132] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.098792] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.099685] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.100579] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.101477] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.102367] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.103263] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.104264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.104988] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4: 00000=
00000160ee0
> > > [   66.105878] Call Trace:
> > > [   66.106202]  zswap_writeback_entry+0x50/0x410
> > > [   66.106761]  z3fold_zpool_shrink+0x29d/0x540
> > > [   66.107305]  zswap_frontswap_store+0x424/0x7c1
> > > [   66.107870]  __frontswap_store+0xc4/0x162
> > > [   66.108383]  swap_writepage+0x39/0x70
> > > [   66.108847]  pageout.isra.0+0x12c/0x5d0
> > > [   66.109340]  shrink_page_list+0x1124/0x1830
> > > [   66.109872]  shrink_inactive_list+0x1da/0x460
> > > [   66.110430]  shrink_node_memcg+0x202/0x770
> > > [   66.110955]  shrink_node+0xdc/0x4a0
> > > [   66.111403]  do_try_to_free_pages+0xdb/0x3c0
> > > [   66.111946]  try_to_free_pages+0x112/0x2e0
> > > [   66.112468]  __alloc_pages_slowpath+0x422/0x1000
> > > [   66.113064]  ? __lock_acquire+0x247/0x1900
> > > [   66.113596]  __alloc_pages_nodemask+0x37f/0x400
> > > [   66.114179]  alloc_pages_vma+0x79/0x1e0
> > > [   66.114675]  __handle_mm_fault+0x99c/0x1900
> > > [   66.115218]  handle_mm_fault+0x159/0x340
> > > [   66.115719]  do_user_addr_fault+0x1fe/0x480
> > > [   66.116256]  do_page_fault+0x31/0x210
> > > [   66.116730]  page_fault+0x3e/0x50
> > > [   66.117168] RIP: 0033:0x556945873250
> > > [   66.117624] Code: 0f 84 88 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 =
c0 89 04 24 41 83 fd 02 0f 8f f1 00 00 00 31 c0 4d 85 ff 7e 12 0f 1f 44 00 =
00 <c6> 44 05 00 5a 4c 01 f0 49 39 c7 7f f3 48 85 db 0f 84 dd 01 00 00
> > > [   66.120514] RSP: 002b:00007fffa5fc06c0 EFLAGS: 00010206
> > > [   66.121722] RAX: 000000000a0ad000 RBX: ffffffffffffffff RCX: 00007=
f33df724156
> > > [   66.123171] RDX: 0000000000000000 RSI: 000000000b7a4000 RDI: 00000=
00000000000
> > > [   66.124616] RBP: 00007f33d3e87010 R08: 00007f33d3e87010 R09: 00000=
00000000000
> > > [   66.126064] R10: 0000000000000022 R11: 0000000000000246 R12: 00005=
56945875004
> > > [   66.127499] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b7a3000
> > > [   66.128936] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.138533] CR2: ffffeab2e2000028
> > > [   66.139562] ---[ end trace bfa9f40a545e4544 ]---
> > > [   66.140733] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.141886] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   66.145387] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.146654] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.148137] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.149626] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.151128] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.152606] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.154076] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.155695] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.157020] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4: 00000=
00000160ee0
> > > [   66.158535] ------------[ cut here ]------------
> > > [   66.159727] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   66.161267] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.171267] CPU: 2 PID: 1193 Comm: stress Tainted: G      D       =
    5.3.0-rc4 #69
> > > [   66.172984] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.174778] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   66.176072] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   66.179927] RSP: 0000:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   66.181387] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   66.183083] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   66.184775] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.186475] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   66.188150] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000000
> > > [   66.189848] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.191666] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.193209] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4: 00000=
00000160ee0
> > > [   66.194916] Call Trace:
> > > [   66.196032]  rewind_stack_do_exit+0x17/0x20
> > > [   66.197347] irq event stamp: 1219776
> > > [   66.198574] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   66.200560] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   66.202535] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   66.204389] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   66.206207] ---[ end trace bfa9f40a545e4545 ]---
> > > [   66.207579] BUG: sleeping function called from invalid context at =
include/linux/percpu-rwsem.h:38
> > > [   66.209465] in_atomic(): 0, irqs_disabled(): 1, pid: 1193, name: s=
tress
> > > [   66.211064] INFO: lockdep is turned off.
> > > [   66.212319] irq event stamp: 1219776
> > > [   66.213513] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   66.215461] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   66.217399] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   66.219193] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   66.220945] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.222615] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.224396] Call Trace:
> > > [   66.225437]  dump_stack+0x67/0x90
> > > [   66.226584]  ___might_sleep.cold+0x9f/0xaf
> > > [   66.227811]  exit_signals+0x30/0x330
> > > [   66.228973]  do_exit+0xcb/0xcd0
> > > [   66.230096]  rewind_stack_do_exit+0x17/0x20
> > > [   66.280469] general protection fault: 0000 [#2] SMP PTI
> > > [   66.281894] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.283557] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.285351] RIP: 0010:__frontswap_invalidate_page+0x66/0x90
> > > [   66.286764] Code: 48 8b 1d bd 23 1f 01 48 85 db 74 17 48 8b 43 18 =
4c 89 e6 89 ef e8 da 9a 91 00 48 8b 5b 28 48 85 db 75 e9 49 8b 85 30 01 00 =
00 <f0> 4c 0f b3 20 f0 41 ff 8d 38 01 00 00 48 83 05 c5 5d 63 02 01 5b
> > > [   66.290514] RSP: 0018:ffffb7a200937c00 EFLAGS: 00010046
> > > [   66.291879] RAX: 59ffff9f67bbda00 RBX: 0000000000000000 RCX: 00000=
00000000002
> > > [   66.293476] RDX: 0000000000000002 RSI: 0000000000000001 RDI: ffff9=
f67b5b3a128
> > > [   66.295045] RBP: 0000000000000000 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.296590] R10: 0000000000000000 R11: 0000000000000000 R12: 00000=
00000050666
> > > [   66.298126] R13: ffff9f67b2930801 R14: 0000000000000001 R15: 00000=
00000050666
> > > [   66.299656] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.304295] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.307673] CR2: 00007f88f35758d0 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.311692] Call Trace:
> > > [   66.313488]  swap_range_free+0xb2/0xd0
> > > [   66.315922]  swapcache_free_entries+0x128/0x1a0
> > > [   66.318646]  free_swap_slot+0xd5/0xf0
> > > [   66.321001]  __swap_entry_free.constprop.0+0x8c/0xa0
> > > [   66.323948]  free_swap_and_cache+0x35/0x70
> > > [   66.326500]  unmap_page_range+0x4c8/0xd00
> > > [   66.329004]  unmap_vmas+0x70/0xd0
> > > [   66.331547]  exit_mmap+0x9d/0x190
> > > [   66.333791]  mmput+0x74/0x150
> > > [   66.335824]  do_exit+0x2e0/0xcd0
> > > [   66.337935]  rewind_stack_do_exit+0x17/0x20
> > > [   66.340508] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.369044] ---[ end trace bfa9f40a545e4546 ]---
> > > [   66.371903] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.374739] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   66.384836] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.387925] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.391900] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.395929] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.399941] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.403855] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.407874] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.412343] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.415707] CR2: 00007f88f35758d0 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.419744] ------------[ cut here ]------------
> > > [   66.422633] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   66.426824] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.455897] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.460267] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.465072] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   66.467866] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   66.478298] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   66.481488] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   66.485619] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   66.489712] RBP: 000000000000000b R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.493843] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
0000000000b
> > > [   66.497949] R13: 0000000000000000 R14: 0000000000000000 R15: 00000=
00000000000
> > > [   66.502012] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.506532] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.510022] CR2: 00007f88f35758d0 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.514106] Call Trace:
> > > [   66.516043]  rewind_stack_do_exit+0x17/0x20
> > > [   66.518763] irq event stamp: 1219776
> > > [   66.521188] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   66.526564] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   66.531810] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   66.536618] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   66.541361] ---[ end trace bfa9f40a545e4547 ]---
> > > [   66.544360] Fixing recursive fault but reboot is needed!
> > > [   66.547695] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   66.551709] #PF: supervisor write access in kernel mode
> > > [   66.554979] #PF: error_code(0x0002) - not-present page
> > > [   66.558129] PGD 0 P4D 0
> > > [   66.560058] Oops: 0002 [#3] SMP PTI
> > > [   66.562387] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.566745] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.571576] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   66.574645] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   66.585052] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   66.588282] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   66.592329] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   66.596433] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.600576] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   66.604648] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   66.608746] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.613312] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.616802] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.620945] Call Trace:
> > > [   66.622841]  schedule+0x75/0xb0
> > > [   66.625013]  do_exit.cold+0x105/0x121
> > > [   66.627452]  rewind_stack_do_exit+0x17/0x20
> > > [   66.630138] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.658821] CR2: 0000000000000009
> > > [   66.661079] ---[ end trace bfa9f40a545e4548 ]---
> > > [   66.663908] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   66.666770] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   66.676902] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   66.680088] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   66.684177] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   66.688287] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   66.692467] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   66.696739] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   66.701000] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.705752] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.709341] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.713585] ------------[ cut here ]------------
> > > [   66.716570] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   66.719387] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   66.734766] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.740562] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.746906] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   66.750505] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   66.764367] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   66.768613] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   66.774085] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   66.779515] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.784941] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   66.790354] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000002
> > > [   66.795774] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.801813] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.806338] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.811764] Call Trace:
> > > [   66.814182]  rewind_stack_do_exit+0x17/0x20
> > > [   66.817701] irq event stamp: 1219776
> > > [   66.820814] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   66.828348] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   66.838934] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   66.845378] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   66.851559] ---[ end trace bfa9f40a545e4549 ]---
> > > [   66.855375] Fixing recursive fault but reboot is needed!
> > > [   66.859621] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   66.864923] #PF: supervisor write access in kernel mode
> > > [   66.869086] #PF: error_code(0x0002) - not-present page
> > > [   66.873181] PGD 0 P4D 0
> > > [   66.875566] Oops: 0002 [#4] SMP PTI
> > > [   66.878580] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   66.884287] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   66.890556] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   66.894506] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   66.908139] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   66.912283] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   66.917647] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   66.923018] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   66.928382] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   66.933725] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   66.939152] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   66.945207] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   66.949721] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   66.955111] Call Trace:
> > > [   66.957436]  schedule+0x75/0xb0
> > > [   66.960188]  do_exit.cold+0x105/0x121
> > > [   66.963256]  rewind_stack_do_exit+0x17/0x20
> > > [   66.966639] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.004782] CR2: 0000000000000009
> > > [   67.007626] ---[ end trace bfa9f40a545e454a ]---
> > > [   67.011297] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   67.015023] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   67.028545] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   67.032642] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   67.037988] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   67.043324] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   67.048643] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   67.053960] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   67.059281] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.065232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.069672] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.074997] ------------[ cut here ]------------
> > > [   67.078709] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   67.084265] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.122745] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.128487] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.134776] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   67.138345] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   67.152134] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   67.156354] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   67.161781] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   67.167195] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.172602] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   67.177978] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000002
> > > [   67.183360] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.189352] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.193842] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.199227] Call Trace:
> > > [   67.201601]  rewind_stack_do_exit+0x17/0x20
> > > [   67.205093] irq event stamp: 1219776
> > > [   67.208194] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   67.215255] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   67.222153] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   67.228492] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   67.234582] ---[ end trace bfa9f40a545e454b ]---
> > > [   67.238367] Fixing recursive fault but reboot is needed!
> > > [   67.242580] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   67.247841] #PF: supervisor write access in kernel mode
> > > [   67.251979] #PF: error_code(0x0002) - not-present page
> > > [   67.256039] PGD 0 P4D 0
> > > [   67.258410] Oops: 0002 [#5] SMP PTI
> > > [   67.261394] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.267073] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.273307] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   67.277232] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   67.290772] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   67.294901] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   67.300256] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   67.305610] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.310974] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   67.316323] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   67.321673] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.327639] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.332215] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.337587] Call Trace:
> > > [   67.339916]  schedule+0x75/0xb0
> > > [   67.342656]  do_exit.cold+0x105/0x121
> > > [   67.345711]  rewind_stack_do_exit+0x17/0x20
> > > [   67.349094] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.367063] CR2: 0000000000000009
> > > [   67.368225] ---[ end trace bfa9f40a545e454c ]---
> > > [   67.369559] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   67.370892] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   67.374853] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   67.376312] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   67.378051] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   67.379776] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   67.381510] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   67.383244] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   67.384980] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.386841] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.388388] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.390150] ------------[ cut here ]------------
> > > [   67.391510] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   67.393227] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.404089] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.405914] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.407900] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   67.409284] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   67.413521] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   67.415067] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   67.416868] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   67.418612] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.420359] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   67.422092] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000002
> > > [   67.423802] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.425647] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.427206] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.428949] Call Trace:
> > > [   67.430084]  rewind_stack_do_exit+0x17/0x20
> > > [   67.431433] irq event stamp: 1219776
> > > [   67.432694] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   67.434785] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   67.436843] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   67.438775] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   67.440653] ---[ end trace bfa9f40a545e454d ]---
> > > [   67.442055] Fixing recursive fault but reboot is needed!
> > > [   67.443556] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   67.445247] #PF: supervisor write access in kernel mode
> > > [   67.446700] #PF: error_code(0x0002) - not-present page
> > > [   67.448134] PGD 0 P4D 0
> > > [   67.449209] Oops: 0002 [#6] SMP PTI
> > > [   67.450425] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.452181] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.454042] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   67.455423] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   67.459330] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   67.460767] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   67.462447] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   67.464166] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.465865] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   67.467547] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   67.469228] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.471034] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.472542] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.474221] Call Trace:
> > > [   67.475288]  schedule+0x75/0xb0
> > > [   67.476416]  do_exit.cold+0x105/0x121
> > > [   67.477583]  rewind_stack_do_exit+0x17/0x20
> > > [   67.478811] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.489221] CR2: 0000000000000009
> > > [   67.490348] ---[ end trace bfa9f40a545e454e ]---
> > > [   67.491636] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   67.492937] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   67.496773] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   67.498188] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   67.499866] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   67.501532] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   67.503194] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   67.504847] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   67.506494] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.508301] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.509774] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.511442] ------------[ cut here ]------------
> > > [   67.512786] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   67.514507] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.525356] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.527174] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.529109] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   67.530489] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   67.534608] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   67.536144] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   67.537936] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   67.539693] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.541439] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   67.543183] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000002
> > > [   67.544910] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.546760] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.548311] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.550057] Call Trace:
> > > [   67.551180]  rewind_stack_do_exit+0x17/0x20
> > > [   67.552513] irq event stamp: 1219776
> > > [   67.553776] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   67.555824] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   67.557873] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   67.559811] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   67.561740] ---[ end trace bfa9f40a545e454f ]---
> > > [   67.563149] Fixing recursive fault but reboot is needed!
> > > [   67.564635] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   67.566338] #PF: supervisor write access in kernel mode
> > > [   67.567794] #PF: error_code(0x0002) - not-present page
> > > [   67.569216] PGD 0 P4D 0
> > > [   67.570285] Oops: 0002 [#7] SMP PTI
> > > [   67.571492] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.573243] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.575122] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   67.576512] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   67.580431] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   67.581890] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   67.583572] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   67.585261] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.586970] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   67.588663] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   67.590362] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.592095] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.593587] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.595280] Call Trace:
> > > [   67.596344]  schedule+0x75/0xb0
> > > [   67.597453]  do_exit.cold+0x105/0x121
> > > [   67.598629]  rewind_stack_do_exit+0x17/0x20
> > > [   67.599844] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.610222] CR2: 0000000000000009
> > > [   67.611357] ---[ end trace bfa9f40a545e4550 ]---
> > > [   67.612638] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   67.613937] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   67.617757] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   67.619186] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   67.620854] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   67.622526] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   67.624194] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   67.625845] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   67.627479] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.629255] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.630752] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.632415] ------------[ cut here ]------------
> > > [   67.633755] WARNING: CPU: 2 PID: 1193 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   67.635418] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.646626] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.648519] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.650568] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   67.652058] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 9a e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   67.656459] RSP: 0018:ffffb7a200937ee0 EFLAGS: 00010046
> > > [   67.658094] RAX: 0000000000000024 RBX: ffff9f67b6af0000 RCX: 00000=
00000000006
> > > [   67.659963] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff9=
f67be9d89c0
> > > [   67.661757] RBP: 0000000000000009 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.663605] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000009
> > > [   67.665476] R13: 0000000000000009 R14: 0000000000000046 R15: 00000=
00000000002
> > > [   67.667307] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.669255] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.670893] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.672706] Call Trace:
> > > [   67.673869]  rewind_stack_do_exit+0x17/0x20
> > > [   67.675269] irq event stamp: 1219776
> > > [   67.676566] hardirqs last  enabled at (1219775): [<ffffffff999d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   67.678798] hardirqs last disabled at (1219776): [<ffffffff99001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   67.680978] softirqs last  enabled at (1219744): [<ffffffff99c0035=
1>] __do_softirq+0x351/0x451
> > > [   67.683012] softirqs last disabled at (1219409): [<ffffffff990c982=
1>] irq_exit+0xf1/0x100
> > > [   67.684975] ---[ end trace bfa9f40a545e4551 ]---
> > > [   67.686437] Fixing recursive fault but reboot is needed!
> > > [   67.687999] BUG: kernel NULL pointer dereference, address: 0000000=
000000009
> > > [   67.689768] #PF: supervisor write access in kernel mode
> > > [   67.691285] #PF: error_code(0x0002) - not-present page
> > > [   67.692776] PGD 0 P4D 0
> > > [   67.693867] Oops: 0002 [#8] SMP PTI
> > > [   67.695098] CPU: 2 PID: 1193 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   67.696975] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   67.698952] RIP: 0010:blk_flush_plug_list+0x66/0x110
> > > [   67.700404] Code: 24 08 48 39 c3 0f 84 91 00 00 00 49 bf 00 01 00 =
00 00 00 ad de 48 8b 45 10 48 39 c3 74 68 48 8b 4d 10 48 8b 55 18 48 8b 04 =
24 <4c> 89 69 08 48 89 0c 24 48 89 02 48 89 50 08 48 89 5d 10 48 89 5d
> > > [   67.704544] RSP: 0018:ffffb7a200937e78 EFLAGS: 00010096
> > > [   67.706057] RAX: ffffb7a200937e78 RBX: ffffb7a200937a00 RCX: 00000=
00000000001
> > > [   67.707846] RDX: 0000000000000086 RSI: 0000000000000001 RDI: ffffb=
7a2009379f0
> > > [   67.709605] RBP: ffffb7a2009379f0 R08: 0000000000000000 R09: 00000=
00000000000
> > > [   67.711387] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   67.713178] R13: ffffb7a200937e78 R14: 0000000000000001 R15: dead0=
00000000100
> > > [   67.714958] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.716892] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.718480] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.720282] Call Trace:
> > > [   67.721370]  schedule+0x75/0xb0
> > > [   67.722563]  do_exit.cold+0x105/0x121
> > > [   67.723804]  rewind_stack_do_exit+0x17/0x20
> > > [   67.725104] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp virtio_net=
 net_failover failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [   67.736320] CR2: 0000000000000009
> > > [   67.737494] ---[ end trace bfa9f40a545e4552 ]---
> > > [   67.738846] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > [   67.740202] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00 00 =
80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d 4e eb e4 =
00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d 6d 10 4c 89
> > > [   67.744349] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > [   67.745848] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX: 00000=
00000000000
> > > [   67.747608] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI: ffff9=
f67b39bca00
> > > [   67.749363] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09: 00000=
00000000000
> > > [   67.751165] R10: 0000000000000003 R11: 0000000000000000 R12: ffff9=
f67bb10e688
> > > [   67.752925] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15: ffffb=
7a200937628
> > > [   67.754659] FS:  00007f33df62b740(0000) GS:ffff9f67be800000(0000) =
knlGS:0000000000000000
> > > [   67.756560] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   67.758129] CR2: 0000000000000009 CR3: 000000003530c006 CR4: 00000=
00000160ee0
> > > [   67.759896] ------------[ cut here ]------------
> >
> > > Fedora 30 (Thirty)
> > > Kernel 5.3.0-rc4 on an x86_64 (ttyS0)
> > >
> > > localhost login: [ 4180.615506] kernel BUG at lib/list_debug.c:54!
> > > [ 4180.617034] invalid opcode: 0000 [#1] SMP PTI
> > > [ 4180.618059] CPU: 3 PID: 2129 Comm: stress Tainted: G        W     =
    5.3.0-rc4 #69
> > > [ 4180.619811] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4180.621757] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > [ 4180.623035] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89 fe =
48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8 36 7e bf =
ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e bf ff 0f 0b
> > > [ 4180.627262] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > [ 4180.628459] RAX: 0000000000000054 RBX: ffff88a102053000 RCX: 00000=
00000000000
> > > [ 4180.630077] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI: ffff8=
8a13bbd89c8
> > > [ 4180.631693] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09: 00000=
00000000000
> > > [ 4180.633271] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13098a200
> > > [ 4180.634899] R13: ffff88a13098a208 R14: 0000000000000000 R15: ffff8=
8a102053010
> > > [ 4180.636539] FS:  00007f86b900e740(0000) GS:ffff88a13ba00000(0000) =
knlGS:0000000000000000
> > > [ 4180.638394] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4180.639733] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4: 00000=
00000160ee0
> > > [ 4180.641383] Call Trace:
> > > [ 4180.641965]  z3fold_zpool_malloc+0x106/0xa40
> > > [ 4180.642965]  zswap_frontswap_store+0x2e8/0x7c1
> > > [ 4180.643978]  __frontswap_store+0xc4/0x162
> > > [ 4180.644875]  swap_writepage+0x39/0x70
> > > [ 4180.645695]  pageout.isra.0+0x12c/0x5d0
> > > [ 4180.646553]  shrink_page_list+0x1124/0x1830
> > > [ 4180.647538]  shrink_inactive_list+0x1da/0x460
> > > [ 4180.648564]  shrink_node_memcg+0x202/0x770
> > > [ 4180.649529]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4180.650432]  shrink_node+0xdc/0x4a0
> > > [ 4180.651258]  do_try_to_free_pages+0xdb/0x3c0
> > > [ 4180.652261]  try_to_free_pages+0x112/0x2e0
> > > [ 4180.653217]  __alloc_pages_slowpath+0x422/0x1000
> > > [ 4180.654294]  ? __lock_acquire+0x247/0x1900
> > > [ 4180.655254]  __alloc_pages_nodemask+0x37f/0x400
> > > [ 4180.656312]  alloc_pages_vma+0x79/0x1e0
> > > [ 4180.657169]  __read_swap_cache_async+0x1ec/0x3e0
> > > [ 4180.658197]  swap_cluster_readahead+0x184/0x330
> > > [ 4180.659211]  ? find_held_lock+0x32/0x90
> > > [ 4180.660111]  swapin_readahead+0x2b4/0x4e0
> > > [ 4180.661046]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4180.661949]  do_swap_page+0x3ac/0xc30
> > > [ 4180.662807]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4180.663790]  handle_mm_fault+0x159/0x340
> > > [ 4180.664713]  do_user_addr_fault+0x1fe/0x480
> > > [ 4180.665691]  do_page_fault+0x31/0x210
> > > [ 4180.666552]  page_fault+0x3e/0x50
> > > [ 4180.667818] RIP: 0033:0x555b3127d298
> > > [ 4180.669153] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [ 4180.676117] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4180.678515] RAX: 0000000000038000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4180.681657] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4180.684762] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4180.687846] R10: 00007f86ad840010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4180.690919] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> > > [ 4180.693967] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4180.715768] ---[ end trace 6eab0ae003d4d2ea ]---
> > > [ 4180.718021] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > [ 4180.720602] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89 fe =
48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8 36 7e bf =
ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e bf ff 0f 0b
> > > [ 4180.728474] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > [ 4180.730969] RAX: 0000000000000054 RBX: ffff88a102053000 RCX: 00000=
00000000000
> > > [ 4180.734130] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI: ffff8=
8a13bbd89c8
> > > [ 4180.737285] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09: 00000=
00000000000
> > > [ 4180.740442] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13098a200
> > > [ 4180.743609] R13: ffff88a13098a208 R14: 0000000000000000 R15: ffff8=
8a102053010
> > > [ 4180.746774] FS:  00007f86b900e740(0000) GS:ffff88a13ba00000(0000) =
knlGS:0000000000000000
> > > [ 4180.750294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4180.752986] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4: 00000=
00000160ee0
> > > [ 4180.756176] ------------[ cut here ]------------
> > > [ 4180.758489] WARNING: CPU: 3 PID: 2129 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [ 4180.761825] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4180.784538] CPU: 3 PID: 2129 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [ 4180.788037] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4180.791843] RIP: 0010:do_exit.cold+0xc/0x121
> > > [ 4180.794147] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a 8f e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [ 4180.802444] RSP: 0000:ffffacfcc097fee0 EFLAGS: 00010246
> > > [ 4180.805128] RAX: 0000000000000024 RBX: ffff88a10f898000 RCX: 00000=
00000000000
> > > [ 4180.808493] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI: ffff8=
8a13bbd89c8
> > > [ 4180.811873] RBP: 000000000000000b R08: ffff88a13bbd89c8 R09: 00000=
00000000000
> > > [ 4180.815254] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
0000000000b
> > > [ 4180.818631] R13: ffffffff8f0aba78 R14: ffff88a10f898000 R15: 00000=
00000000000
> > > [ 4180.822013] FS:  00007f86b900e740(0000) GS:ffff88a13ba00000(0000) =
knlGS:0000000000000000
> > > [ 4180.825759] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4180.828668] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4: 00000=
00000160ee0
> > > [ 4180.832080] Call Trace:
> > > [ 4180.833812]  rewind_stack_do_exit+0x17/0x20
> > > [ 4180.836143] irq event stamp: 4733143
> > > [ 4180.838248] hardirqs last  enabled at (4733143): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4180.842093] hardirqs last disabled at (4733141): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4180.845999] softirqs last  enabled at (4733142): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4180.849911] softirqs last disabled at (4733135): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4180.853671] ---[ end trace 6eab0ae003d4d2eb ]---
> > > [ 4180.856173] BUG: sleeping function called from invalid context at =
include/linux/percpu-rwsem.h:38
> > > [ 4180.860196] in_atomic(): 1, irqs_disabled(): 0, pid: 2129, name: s=
tress
> > > [ 4180.863395] INFO: lockdep is turned off.
> > > [ 4180.865618] CPU: 3 PID: 2129 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [ 4180.869149] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4180.872986] Call Trace:
> > > [ 4180.874651]  dump_stack+0x67/0x90
> > > [ 4180.876617]  ___might_sleep.cold+0x9f/0xaf
> > > [ 4180.878843]  exit_signals+0x30/0x330
> > > [ 4180.880862]  do_exit+0xcb/0xcd0
> > > [ 4180.882716]  rewind_stack_do_exit+0x17/0x20
> > > [ 4180.884951] note: stress[2129] exited with preempt_count 4
> > > [ 4208.214012] watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [str=
ess:2132]
> > > [ 4208.220179] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4208.265286] irq event stamp: 3676955
> > > [ 4208.268842] hardirqs last  enabled at (3676955): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4208.275012] watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [str=
ess:2131]
> > > [ 4208.276838] hardirqs last disabled at (3676953): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4208.278415] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4208.285788] softirqs last  enabled at (3676954): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4208.285790] softirqs last disabled at (3676947): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4208.295618] irq event stamp: 5816781
> > > [ 4208.295621] hardirqs last  enabled at (5816781): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4208.303009] CPU: 1 PID: 2132 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [ 4208.304704] hardirqs last disabled at (5816779): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4208.304705] softirqs last  enabled at (5816780): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4208.308215] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4208.308218] RIP: 0010:queued_spin_lock_slowpath+0x124/0x1e0
> > > [ 4208.310033] softirqs last disabled at (5816773): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4208.310035] CPU: 2 PID: 2131 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [ 4208.316663] Code: 00 89 1d 00 eb a1 41 83 c0 01 c1 e1 10 41 c1 e0 =
12 44 09 c1 89 c8 c1 e8 10 66 87 47 02 89 c6 c1 e6 10 75 3c 31 f6 eb 02 f3 =
90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 74 64 c6 07 01
> > > [ 4208.318406] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4208.318409] RIP: 0010:queued_spin_lock_slowpath+0x42/0x1e0
> > > [ 4208.325751] RSP: 0000:ffffacfcc09bf568 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [ 4208.327489] Code: 49 f0 0f ba 2f 08 0f 92 c0 0f b6 c0 c1 e0 08 89 =
c2 8b 07 30 e4 09 d0 a9 00 01 ff ff 75 23 85 c0 74 0e 8b 07 84 c0 74 08 f3 =
90 <8b> 07 84 c0 75 f8 b8 01 00 00 00 66 89 07 65 48 ff 05 18 f8 09 72
> > > [ 4208.327491] RSP: 0000:ffffacfcc09b3d30 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [ 4208.332557] RAX: 0000000000100101 RBX: ffff88a13a103140 RCX: 00000=
00000080000
> > > [ 4208.332558] RDX: ffff88a13b7ec400 RSI: 0000000000000000 RDI: ffff8=
8a13a103140
> > > [ 4208.334275] RAX: 0000000000100101 RBX: ffff88a13a103140 RCX: 88888=
88888888889
> > > [ 4208.334277] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8=
8a13a103140
> > > [ 4208.336012] watchdog: BUG: soft lockup - CPU#3 stuck for 23s! [str=
ess:2129]
> > > [ 4208.336013] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4208.336028] irq event stamp: 4733143
> > > [ 4208.336030] hardirqs last  enabled at (4733143): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4208.336031] hardirqs last disabled at (4733141): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4208.336032] softirqs last  enabled at (4733142): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4208.336034] softirqs last disabled at (4733135): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4208.336036] CPU: 3 PID: 2129 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [ 4208.336036] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4208.336038] RIP: 0010:queued_spin_lock_slowpath+0x184/0x1e0
> > > [ 4208.336040] Code: c1 ee 12 83 e0 03 83 ee 01 48 c1 e0 04 48 63 f6 =
48 05 00 c4 1e 00 48 03 04 f5 a0 96 18 8f 48 89 10 8b 42 08 85 c0 75 09 f3 =
90 <8b> 42 08 85 c0 74 f7 48 8b 02 48 85 c0 74 8b 48 89 c6 0f 18 08 eb
> > > [ 4208.336040] RSP: 0000:ffffacfcc097fc80 EFLAGS: 00000246 ORIG_RAX: =
ffffffffffffff13
> > > [ 4208.336041] RAX: 0000000000000000 RBX: ffff88a13a103140 RCX: 00000=
00000100000
> > > [ 4208.336042] RDX: ffff88a13bbec400 RSI: 0000000000000001 RDI: ffff8=
8a13a103140
> > > [ 4208.336043] RBP: ffff88a13a103140 R08: 0000000000100000 R09: 00000=
00000000000
> > > [ 4208.336043] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4208.336044] R13: 000000000006728b R14: 000000000006728b R15: 07fff=
ffff31ae802
> > > [ 4208.336046] FS:  0000000000000000(0000) GS:ffff88a13ba00000(0000) =
knlGS:0000000000000000
> > > [ 4208.336047] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4208.336048] CR2: 00007f86b1e1f010 CR3: 000000003e212003 CR4: 00000=
00000160ee0
> > > [ 4208.336048] Call Trace:
> > > [ 4208.336051]  do_raw_spin_lock+0xab/0xb0
> > > [ 4208.336055]  _raw_spin_lock+0x63/0x80
> > > [ 4208.336058]  __swap_entry_free.constprop.0+0x82/0xa0
> > > [ 4208.336060]  free_swap_and_cache+0x35/0x70
> > > [ 4208.336062]  unmap_page_range+0x4c8/0xd00
> > > [ 4208.336067]  unmap_vmas+0x70/0xd0
> > > [ 4208.336070]  exit_mmap+0x9d/0x190
> > > [ 4208.336075]  mmput+0x74/0x150
> > > [ 4208.336077]  do_exit+0x2e0/0xcd0
> > > [ 4208.336080]  rewind_stack_do_exit+0x17/0x20
> > > [ 4208.340892] RBP: ffff88a13a103140 R08: 0000000000080000 R09: 00000=
00000000000
> > > [ 4208.340893] R10: 0000000000000002 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4208.344609] RBP: ffff88a13a103140 R08: 000003cd60184be9 R09: 00000=
00000000000
> > > [ 4208.344610] R10: 0000000000000002 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4208.351976] R13: ffff88a13a103140 R14: ffffea2b4079b448 R15: ffffe=
a2b4079b440
> > > [ 4208.351979] FS:  00007f86b900e740(0000) GS:ffff88a13b600000(0000) =
knlGS:0000000000000000
> > > [ 4208.353440] R13: 00000000000877d4 R14: 00000000000877d4 R15: ffffe=
a2b4084d3c0
> > > [ 4208.353443] FS:  00007f86b900e740(0000) GS:ffff88a13b800000(0000) =
knlGS:0000000000000000
> > > [ 4208.360057] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4208.360058] CR2: 00007f86b1257010 CR3: 0000000031fc4005 CR4: 00000=
00000160ee0
> > > [ 4208.363853] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4208.363855] CR2: 00007f86b02c0010 CR3: 0000000028ce0005 CR4: 00000=
00000160ee0
> > > [ 4208.370516] Call Trace:
> > > [ 4208.372193] Call Trace:
> > > [ 4208.378517]  do_raw_spin_lock+0xab/0xb0
> > > [ 4208.380184]  do_raw_spin_lock+0xab/0xb0
> > > [ 4208.386494]  _raw_spin_lock+0x63/0x80
> > > [ 4208.388139]  _raw_spin_lock+0x63/0x80
> > > [ 4208.432239]  page_swapcount+0x88/0x90
> > > [ 4208.433610]  __swap_entry_free.constprop.0+0x82/0xa0
> > > [ 4208.441629]  try_to_free_swap+0x1a4/0x200
> > > [ 4208.443553]  do_swap_page+0x608/0xc30
> > > [ 4208.451066]  swap_writepage+0x13/0x70
> > > [ 4208.452919]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4208.459686]  pageout.isra.0+0x12c/0x5d0
> > > [ 4208.461559]  handle_mm_fault+0x159/0x340
> > > [ 4208.466734]  shrink_page_list+0x1124/0x1830
> > > [ 4208.470616]  do_user_addr_fault+0x1fe/0x480
> > > [ 4208.477305]  shrink_inactive_list+0x1da/0x460
> > > [ 4208.480094]  do_page_fault+0x31/0x210
> > > [ 4208.485733]  shrink_node_memcg+0x202/0x770
> > > [ 4208.489206]  page_fault+0x3e/0x50
> > > [ 4208.494802]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4208.498239] RIP: 0033:0x555b3127d298
> > > [ 4208.504409]  shrink_node+0xdc/0x4a0
> > > [ 4208.507320] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [ 4208.512839]  do_try_to_free_pages+0xdb/0x3c0
> > > [ 4208.514545] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4208.517890]  try_to_free_pages+0x112/0x2e0
> > > [ 4208.520012] RAX: 00000000049f8000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4208.520013] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4208.524061]  __alloc_pages_slowpath+0x422/0x1000
> > > [ 4208.526319] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4208.526321] R10: 00007f86b2200010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4208.529739]  ? __lock_acquire+0x247/0x1900
> > > [ 4208.531702] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> > > [ 4208.663101]  __alloc_pages_nodemask+0x37f/0x400
> > > [ 4208.665282]  alloc_pages_vma+0x79/0x1e0
> > > [ 4208.667206]  __read_swap_cache_async+0x1ec/0x3e0
> > > [ 4208.669411]  swap_cluster_readahead+0x184/0x330
> > > [ 4208.671588]  ? find_held_lock+0x32/0x90
> > > [ 4208.673495]  swapin_readahead+0x2b4/0x4e0
> > > [ 4208.675463]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4208.677358]  do_swap_page+0x3ac/0xc30
> > > [ 4208.679178]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4208.681188]  handle_mm_fault+0x159/0x340
> > > [ 4208.683091]  do_user_addr_fault+0x1fe/0x480
> > > [ 4208.685140]  do_page_fault+0x31/0x210
> > > [ 4208.686048]  page_fault+0x3e/0x50
> > > [ 4208.686907] RIP: 0033:0x555b3127d298
> > > [ 4208.687813] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [ 4208.690919] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4208.694134] RAX: 000000000b512000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4208.697265] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4208.700395] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4208.703523] R10: 00007f86b8d1a010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4208.706655] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> > > [ 4236.214049] watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [str=
ess:2132]
> > > [ 4236.219179] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4236.256598] irq event stamp: 3676955
> > > [ 4236.259545] hardirqs last  enabled at (3676955): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4236.266216] hardirqs last disabled at (3676953): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4236.272381] softirqs last  enabled at (3676954): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4236.275050] watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [str=
ess:2131]
> > > [ 4236.278546] softirqs last disabled at (3676947): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4236.278549] CPU: 1 PID: 2132 Comm: stress Tainted: G      D W    L=
    5.3.0-rc4 #69
> > > [ 4236.282747] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4236.287710] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4236.287714] RIP: 0010:queued_spin_lock_slowpath+0x124/0x1e0
> > > [ 4236.292479] irq event stamp: 5816781
> > > [ 4236.325373] Code: 00 89 1d 00 eb a1 41 83 c0 01 c1 e1 10 41 c1 e0 =
12 44 09 c1 89 c8 c1 e8 10 66 87 47 02 89 c6 c1 e6 10 75 3c 31 f6 eb 02 f3 =
90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 74 64 c6 07 01
> > > [ 4236.330652] hardirqs last  enabled at (5816781): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4236.330654] hardirqs last disabled at (5816779): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4236.334257] RSP: 0000:ffffacfcc09bf568 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [ 4236.336049] watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [str=
ess:2129]
> > > [ 4236.336050] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon net_failo=
ver intel_agp failover intel_gtt qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_blk virtio_con=
sole agpgart qemu_fw_cfg
> > > [ 4236.336064] irq event stamp: 4733143
> > > [ 4236.336066] hardirqs last  enabled at (4733143): [<ffffffff8e001bc=
a>] trace_hardirqs_on_thunk+0x1a/0x20
> > > [ 4236.336068] hardirqs last disabled at (4733141): [<ffffffff8ec002c=
a>] __do_softirq+0x2ca/0x451
> > > [ 4236.336069] softirqs last  enabled at (4733142): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4236.336071] softirqs last disabled at (4733135): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4236.336073] CPU: 3 PID: 2129 Comm: stress Tainted: G      D W    L=
    5.3.0-rc4 #69
> > > [ 4236.336073] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4236.336076] RIP: 0010:queued_spin_lock_slowpath+0x184/0x1e0
> > > [ 4236.336077] Code: c1 ee 12 83 e0 03 83 ee 01 48 c1 e0 04 48 63 f6 =
48 05 00 c4 1e 00 48 03 04 f5 a0 96 18 8f 48 89 10 8b 42 08 85 c0 75 09 f3 =
90 <8b> 42 08 85 c0 74 f7 48 8b 02 48 85 c0 74 8b 48 89 c6 0f 18 08 eb
> > > [ 4236.336078] RSP: 0000:ffffacfcc097fc80 EFLAGS: 00000246 ORIG_RAX: =
ffffffffffffff13
> > > [ 4236.336079] RAX: 0000000000000000 RBX: ffff88a13a103140 RCX: 00000=
00000100000
> > > [ 4236.336079] RDX: ffff88a13bbec400 RSI: 0000000000000001 RDI: ffff8=
8a13a103140
> > > [ 4236.336080] RBP: ffff88a13a103140 R08: 0000000000100000 R09: 00000=
00000000000
> > > [ 4236.336080] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4236.336081] R13: 000000000006728b R14: 000000000006728b R15: 07fff=
ffff31ae802
> > > [ 4236.336084] FS:  0000000000000000(0000) GS:ffff88a13ba00000(0000) =
knlGS:0000000000000000
> > > [ 4236.336084] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4236.336085] CR2: 00007f86b1e1f010 CR3: 000000003e212003 CR4: 00000=
00000160ee0
> > > [ 4236.336085] Call Trace:
> > > [ 4236.336088]  do_raw_spin_lock+0xab/0xb0
> > > [ 4236.336092]  _raw_spin_lock+0x63/0x80
> > > [ 4236.336095]  __swap_entry_free.constprop.0+0x82/0xa0
> > > [ 4236.336097]  free_swap_and_cache+0x35/0x70
> > > [ 4236.336099]  unmap_page_range+0x4c8/0xd00
> > > [ 4236.336104]  unmap_vmas+0x70/0xd0
> > > [ 4236.336108]  exit_mmap+0x9d/0x190
> > > [ 4236.336113]  mmput+0x74/0x150
> > > [ 4236.336114]  do_exit+0x2e0/0xcd0
> > > [ 4236.336117]  rewind_stack_do_exit+0x17/0x20
> > > [ 4236.336922] softirqs last  enabled at (5816780): [<ffffffff8ec0035=
1>] __do_softirq+0x351/0x451
> > > [ 4236.336924] softirqs last disabled at (5816773): [<ffffffff8e0c982=
1>] irq_exit+0xf1/0x100
> > > [ 4236.348337] RAX: 0000000000100101 RBX: ffff88a13a103140 RCX: 00000=
00000080000
> > > [ 4236.348338] RDX: ffff88a13b7ec400 RSI: 0000000000000000 RDI: ffff8=
8a13a103140
> > > [ 4236.354150] CPU: 2 PID: 2131 Comm: stress Tainted: G      D W    L=
    5.3.0-rc4 #69
> > > [ 4236.359677] RBP: ffff88a13a103140 R08: 0000000000080000 R09: 00000=
00000000000
> > > [ 4236.359679] R10: 0000000000000002 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4236.364484] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [ 4236.364487] RIP: 0010:queued_spin_lock_slowpath+0x42/0x1e0
> > > [ 4236.369155] R13: ffff88a13a103140 R14: ffffea2b4079b448 R15: ffffe=
a2b4079b440
> > > [ 4236.369158] FS:  00007f86b900e740(0000) GS:ffff88a13b600000(0000) =
knlGS:0000000000000000
> > > [ 4236.401942] Code: 49 f0 0f ba 2f 08 0f 92 c0 0f b6 c0 c1 e0 08 89 =
c2 8b 07 30 e4 09 d0 a9 00 01 ff ff 75 23 85 c0 74 0e 8b 07 84 c0 74 08 f3 =
90 <8b> 07 84 c0 75 f8 b8 01 00 00 00 66 89 07 65 48 ff 05 18 f8 09 72
> > > [ 4236.404801] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4236.404802] CR2: 00007f86b1257010 CR3: 0000000031fc4005 CR4: 00000=
00000160ee0
> > > [ 4236.410715] RSP: 0000:ffffacfcc09b3d30 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [ 4236.416294] Call Trace:
> > > [ 4236.421766] RAX: 0000000000100101 RBX: ffff88a13a103140 RCX: 88888=
88888888889
> > > [ 4236.421767] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8=
8a13a103140
> > > [ 4236.427262]  do_raw_spin_lock+0xab/0xb0
> > > [ 4236.432260] RBP: ffff88a13a103140 R08: 000003cd60184be9 R09: 00000=
00000000000
> > > [ 4236.432262] R10: 0000000000000002 R11: 0000000000000000 R12: ffff8=
8a13a103158
> > > [ 4236.438131]  _raw_spin_lock+0x63/0x80
> > > [ 4236.442026] R13: 00000000000877d4 R14: 00000000000877d4 R15: ffffe=
a2b4084d3c0
> > > [ 4236.442029] FS:  00007f86b900e740(0000) GS:ffff88a13b800000(0000) =
knlGS:0000000000000000
> > > [ 4236.454537]  page_swapcount+0x88/0x90
> > > [ 4236.459512] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [ 4236.459513] CR2: 00007f86b02c0010 CR3: 0000000028ce0005 CR4: 00000=
00000160ee0
> > > [ 4236.464192]  try_to_free_swap+0x1a4/0x200
> > > [ 4236.468946] Call Trace:
> > > [ 4236.474017]  swap_writepage+0x13/0x70
> > > [ 4236.478811]  do_raw_spin_lock+0xab/0xb0
> > > [ 4236.483800]  pageout.isra.0+0x12c/0x5d0
> > > [ 4236.489047]  _raw_spin_lock+0x63/0x80
> > > [ 4236.493030]  shrink_page_list+0x1124/0x1830
> > > [ 4236.497707]  __swap_entry_free.constprop.0+0x82/0xa0
> > > [ 4236.499723]  shrink_inactive_list+0x1da/0x460
> > > [ 4236.502622]  do_swap_page+0x608/0xc30
> > > [ 4236.505538]  shrink_node_memcg+0x202/0x770
> > > [ 4236.509009]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4236.511974]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4236.514936]  handle_mm_fault+0x159/0x340
> > > [ 4236.517633]  shrink_node+0xdc/0x4a0
> > > [ 4236.520183]  do_user_addr_fault+0x1fe/0x480
> > > [ 4236.522455]  do_try_to_free_pages+0xdb/0x3c0
> > > [ 4236.524941]  do_page_fault+0x31/0x210
> > > [ 4236.527849]  try_to_free_pages+0x112/0x2e0
> > > [ 4236.533189]  page_fault+0x3e/0x50
> > > [ 4236.538559]  __alloc_pages_slowpath+0x422/0x1000
> > > [ 4236.543089] RIP: 0033:0x555b3127d298
> > > [ 4236.547432]  ? __lock_acquire+0x247/0x1900
> > > [ 4236.552254] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [ 4236.556377]  __alloc_pages_nodemask+0x37f/0x400
> > > [ 4236.560903] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4236.566205]  alloc_pages_vma+0x79/0x1e0
> > > [ 4236.569815] RAX: 00000000049f8000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4236.569817] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4236.573896]  __read_swap_cache_async+0x1ec/0x3e0
> > > [ 4236.578918] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4236.578920] R10: 00007f86b2200010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4236.591058]  swap_cluster_readahead+0x184/0x330
> > > [ 4236.594822] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> > > [ 4236.753959]  ? find_held_lock+0x32/0x90
> > > [ 4236.756411]  swapin_readahead+0x2b4/0x4e0
> > > [ 4236.758936]  ? sched_clock_cpu+0xc/0xc0
> > > [ 4236.761488]  do_swap_page+0x3ac/0xc30
> > > [ 4236.763806]  __handle_mm_fault+0x8dd/0x1900
> > > [ 4236.766543]  handle_mm_fault+0x159/0x340
> > > [ 4236.769083]  do_user_addr_fault+0x1fe/0x480
> > > [ 4236.771524]  do_page_fault+0x31/0x210
> > > [ 4236.773914]  page_fault+0x3e/0x50
> > > [ 4236.776100] RIP: 0033:0x555b3127d298
> > > [ 4236.778489] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [ 4236.789276] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > [ 4236.792624] RAX: 000000000b512000 RBX: ffffffffffffffff RCX: 00007=
f86b9107156
> > > [ 4236.797102] RDX: 0000000000000000 RSI: 000000000b805000 RDI: 00000=
00000000000
> > > [ 4236.801334] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09: 00000=
00000000000
> > > [ 4236.805688] R10: 00007f86b8d1a010 R11: 0000000000000246 R12: 00005=
55b3127f004
> > > [ 4236.810091] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b804000
> >
> > > Fedora 30 (Thirty)
> > > Kernel 5.3.0-rc4 on an x86_64 (ttyS0)
> > >
> > > localhost login: [   22.529023] kernel BUG at include/linux/mm.h:607!
> > > [   22.529092] BUG: kernel NULL pointer dereference, address: 0000000=
000000008
> > > [   22.531789] #PF: supervisor read access in kernel mode
> > > [   22.532954] #PF: error_code(0x0000) - not-present page
> > > [   22.533722] PGD 0 P4D 0
> > > [   22.534097] Oops: 0000 [#1] SMP PTI
> > > [   22.534585] CPU: 0 PID: 186 Comm: kworker/u8:4 Not tainted 5.3.0-r=
c4 #69
> > > [   22.535488] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   22.536633] Workqueue: zswap1 compact_page_work
> > > [   22.537263] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.537868] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00 =
41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90 49 89 =
d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0f 85 98
> > > [   22.540322] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.540953] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.541838] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.542747] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.543660] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.544614] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.545578] FS:  0000000000000000(0000) GS:ffff8d69be400000(0000) =
knlGS:0000000000000000
> > > [   22.546662] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.547452] CR2: 0000000000000008 CR3: 0000000035304001 CR4: 00000=
00000160ef0
> > > [   22.548488] Call Trace:
> > > [   22.548845]  do_compact_page+0x31e/0x430
> > > [   22.549406]  process_one_work+0x272/0x5a0
> > > [   22.549972]  worker_thread+0x50/0x3b0
> > > [   22.550488]  kthread+0x108/0x140
> > > [   22.550939]  ? process_one_work+0x5a0/0x5a0
> > > [   22.551531]  ? kthread_park+0x80/0x80
> > > [   22.552034]  ret_from_fork+0x3a/0x50
> > > [   22.552554] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   22.559889] CR2: 0000000000000008
> > > [   22.560328] ---[ end trace cfa4596e38137687 ]---
> > > [   22.560330] invalid opcode: 0000 [#2] SMP PTI
> > > [   22.560981] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.561515] CPU: 2 PID: 1063 Comm: stress Tainted: G      D       =
    5.3.0-rc4 #69
> > > [   22.562143] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00 =
41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90 49 89 =
d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0f 85 98
> > > [   22.563034] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   22.565759] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.565760] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.565761] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.565761] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.565762] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.565763] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.565765] FS:  0000000000000000(0000) GS:ffff8d69be400000(0000) =
knlGS:0000000000000000
> > > [   22.565766] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.565766] CR2: 0000000000000008 CR3: 0000000035304001 CR4: 00000=
00000160ef0
> > > [   22.565797] note: kworker/u8:4[186] exited with preempt_count 3
> > > [   22.581957] RIP: 0010:__free_pages+0x2d/0x30
> > > [   22.583146] Code: 00 00 8b 47 34 85 c0 74 15 f0 ff 4f 34 75 09 85 =
f6 75 06 e9 75 ff ff ff c3 e9 4f e2 ff ff 48 c7 c6 e8 8c 0a bb e8 d3 7f fd =
ff <0f> 0b 90 0f 1f 44 00 00 89 f1 41 bb 01 00 00 00 49 89 fa 41 d3 e3
> > > [   22.586649] RSP: 0018:ffffa073809ef4d0 EFLAGS: 00010246
> > > [   22.587963] RAX: 000000000000003e RBX: ffff8d6992d10000 RCX: 00000=
00000000006
> > > [   22.589579] RDX: 0000000000000000 RSI: 0000000000000000 RDI: fffff=
fffbb0e5774
> > > [   22.591181] RBP: ffffd090004b4408 R08: 000000053ed5634a R09: 00000=
00000000000
> > > [   22.592781] R10: 0000000000000000 R11: 0000000000000000 R12: ffffd=
090004b4400
> > > [   22.594339] R13: ffff8d69bd0dfca0 R14: ffff8d69bd0dfc00 R15: ffff8=
d69bd0dfc08
> > > [   22.595832] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000) =
knlGS:0000000000000000
> > > [   22.598649] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.601196] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4: 00000=
00000160ee0
> > > [   22.603539] Call Trace:
> > > [   22.605103]  z3fold_zpool_shrink+0x25f/0x540
> > > [   22.607218]  zswap_frontswap_store+0x424/0x7c1
> > > [   22.609115]  __frontswap_store+0xc4/0x162
> > > [   22.610819]  swap_writepage+0x39/0x70
> > > [   22.612525]  pageout.isra.0+0x12c/0x5d0
> > > [   22.613957]  shrink_page_list+0x1124/0x1830
> > > [   22.615130]  shrink_inactive_list+0x1da/0x460
> > > [   22.616311]  shrink_node_memcg+0x202/0x770
> > > [   22.617473]  ? sched_clock_cpu+0xc/0xc0
> > > [   22.619145]  shrink_node+0xdc/0x4a0
> > > [   22.620279]  do_try_to_free_pages+0xdb/0x3c0
> > > [   22.621450]  try_to_free_pages+0x112/0x2e0
> > > [   22.622582]  __alloc_pages_slowpath+0x422/0x1000
> > > [   22.623749]  ? __lock_acquire+0x247/0x1900
> > > [   22.624876]  __alloc_pages_nodemask+0x37f/0x400
> > > [   22.626007]  alloc_pages_vma+0x79/0x1e0
> > > [   22.627040]  __read_swap_cache_async+0x1ec/0x3e0
> > > [   22.628143]  swap_cluster_readahead+0x184/0x330
> > > [   22.629234]  ? find_held_lock+0x32/0x90
> > > [   22.630292]  swapin_readahead+0x2b4/0x4e0
> > > [   22.631370]  ? sched_clock_cpu+0xc/0xc0
> > > [   22.632379]  do_swap_page+0x3ac/0xc30
> > > [   22.633356]  __handle_mm_fault+0x8dd/0x1900
> > > [   22.634373]  handle_mm_fault+0x159/0x340
> > > [   22.635714]  do_user_addr_fault+0x1fe/0x480
> > > [   22.636738]  do_page_fault+0x31/0x210
> > > [   22.637674]  page_fault+0x3e/0x50
> > > [   22.638559] RIP: 0033:0x562b503bd298
> > > [   22.639476] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [   22.642658] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > [   22.643900] RAX: 0000000000f09000 RBX: ffffffffffffffff RCX: 00007=
f48317b0156
> > > [   22.645242] RDX: 0000000000000000 RSI: 000000000b276000 RDI: 00000=
00000000000
> > > [   22.646571] RBP: 00007f4826441010 R08: 00007f4826441010 R09: 00000=
00000000000
> > > [   22.647888] R10: 00007f4827349010 R11: 0000000000000246 R12: 00005=
62b503bf004
> > > [   22.649210] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b275800
> > > [   22.650518] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   22.659276] ---[ end trace cfa4596e38137688 ]---
> > > [   22.660398] RIP: 0010:__list_add_valid+0x3/0x40
> > > [   22.661493] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00 00 =
41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90 90 49 89 =
d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39 c1 0f 85 98
> > > [   22.664800] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > [   22.666779] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX: 88888=
88888888889
> > > [   22.669830] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI: ffff8=
d69ad052000
> > > [   22.672878] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09: 00000=
00000000001
> > > [   22.675920] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
00000000000
> > > [   22.678966] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15: ffff8=
d69ad052010
> > > [   22.682014] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000) =
knlGS:0000000000000000
> > > [   22.685399] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.687991] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4: 00000=
00000160ee0
> > > [   22.691068] ------------[ cut here ]------------
> > > [   22.693308] WARNING: CPU: 2 PID: 1063 at kernel/exit.c:785 do_exit=
.cold+0xc/0x121
> > > [   22.696506] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   22.718213] CPU: 2 PID: 1063 Comm: stress Tainted: G      D       =
    5.3.0-rc4 #69
> > > [   22.721600] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   22.725269] RIP: 0010:do_exit.cold+0xc/0x121
> > > [   22.727494] Code: 1f 44 00 00 8b 4f 68 48 8b 57 60 8b 77 58 48 8b =
7f 28 e9 58 ff ff ff 0f 1f 44 00 00 0f 0b 48 c7 c7 48 98 0a bb e8 c3 14 08 =
00 <0f> 0b e9 ee ee ff ff 65 48 8b 04 25 80 7f 01 00 8b 90 a8 08 00 00
> > > [   22.735422] RSP: 0018:ffffa073809efee0 EFLAGS: 00010246
> > > [   22.738012] RAX: 0000000000000024 RBX: ffff8d69b2e132c0 RCX: 00000=
00000000000
> > > [   22.741253] RDX: 0000000000000000 RSI: ffff8d69be9d89c8 RDI: ffff8=
d69be9d89c8
> > > [   22.744496] RBP: 000000000000000b R08: ffff8d69be9d89c8 R09: 00000=
00000000000
> > > [   22.747754] R10: 0000000000000001 R11: 0000000000000000 R12: 00000=
0000000000b
> > > [   22.751004] R13: ffffffffbb0aba78 R14: ffff8d69b2e132c0 R15: 00000=
00000000000
> > > [   22.754253] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000) =
knlGS:0000000000000000
> > > [   22.757831] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   22.760629] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4: 00000=
00000160ee0
> > > [   22.763902] Call Trace:
> > > [   22.765588]  rewind_stack_do_exit+0x17/0x20
> > > [   22.767874] irq event stamp: 1368024
> > > [   22.769903] hardirqs last  enabled at (1368023): [<ffffffffba147ac=
f>] console_unlock+0x43f/0x590
> > > [   22.773699] hardirqs last disabled at (1368024): [<ffffffffba001be=
a>] trace_hardirqs_off_thunk+0x1a/0x20
> > > [   22.777731] softirqs last  enabled at (1367996): [<ffffffffbac0035=
1>] __do_softirq+0x351/0x451
> > > [   22.781483] softirqs last disabled at (1367983): [<ffffffffba0c982=
1>] irq_exit+0xf1/0x100
> > > [   22.785088] ---[ end trace cfa4596e38137689 ]---
> > > [   47.516736] watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [str=
ess:1066]
> > > [   47.522992] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   47.568388] irq event stamp: 1887610
> > > [   47.571970] hardirqs last  enabled at (1887609): [<ffffffffba9d5b6=
3>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   47.578749] watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [str=
ess:1064]
> > > [   47.580285] hardirqs last disabled at (1887610): [<ffffffffba9cdf6=
4>] __schedule+0xc4/0x8a0
> > > [   47.583634] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   47.589879] softirqs last  enabled at (1887414): [<ffffffffbac0035=
1>] __do_softirq+0x351/0x451
> > > [   47.613664] irq event stamp: 1383450
> > > [   47.613668] hardirqs last  enabled at (1383449): [<ffffffffba9d5b0=
9>] _raw_spin_unlock_irq+0x29/0x40
> > > [   47.620211] softirqs last disabled at (1887271): [<ffffffffba0c982=
1>] irq_exit+0xf1/0x100
> > > [   47.622419] hardirqs last disabled at (1383450): [<ffffffffba9cdf6=
4>] __schedule+0xc4/0x8a0
> > > [   47.622422] softirqs last  enabled at (1383396): [<ffffffffbac0035=
1>] __do_softirq+0x351/0x451
> > > [   47.629329] CPU: 0 PID: 1066 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   47.633216] softirqs last disabled at (1383305): [<ffffffffba0c982=
1>] irq_exit+0xf1/0x100
> > > [   47.633219] CPU: 1 PID: 1064 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   47.639764] watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [str=
ess:1065]
> > > [   47.639765] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   47.639781] irq event stamp: 1376134
> > > [   47.639784] hardirqs last  enabled at (1376133): [<ffffffffba0e78b=
e>] mod_delayed_work_on+0x8e/0xa0
> > > [   47.639787] hardirqs last disabled at (1376134): [<ffffffffba9cdf6=
4>] __schedule+0xc4/0x8a0
> > > [   47.639788] softirqs last  enabled at (1375828): [<ffffffffbac0035=
1>] __do_softirq+0x351/0x451
> > > [   47.639790] softirqs last disabled at (1375805): [<ffffffffba0c982=
1>] irq_exit+0xf1/0x100
> > > [   47.639792] CPU: 2 PID: 1065 Comm: stress Tainted: G      D W     =
    5.3.0-rc4 #69
> > > [   47.639793] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   47.639796] RIP: 0010:queued_spin_lock_slowpath+0x184/0x1e0
> > > [   47.639797] Code: c1 ee 12 83 e0 03 83 ee 01 48 c1 e0 04 48 63 f6 =
48 05 00 c4 1e 00 48 03 04 f5 a0 96 18 bb 48 89 10 8b 42 08 85 c0 75 09 f3 =
90 <8b> 42 08 85 c0 74 f7 48 8b 02 48 85 c0 74 8b 48 89 c6 0f 18 08 eb
> > > [   47.639798] RSP: 0018:ffffa07380a0f4a8 EFLAGS: 00000246 ORIG_RAX: =
ffffffffffffff13
> > > [   47.639799] RAX: 0000000000000000 RBX: ffff8d69bd0dfc08 RCX: 00000=
000000c0000
> > > [   47.639800] RDX: ffff8d69be9ec400 RSI: 0000000000000000 RDI: ffff8=
d69bd0dfc08
> > > [   47.639800] RBP: ffff8d69bd0dfc08 R08: 00000000000c0000 R09: 00000=
00000000000
> > > [   47.639801] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
d69bd0dfc20
> > > [   47.639802] R13: ffff8d69bd0dfca0 R14: ffff8d69bd0dfc00 R15: ffff8=
d69bd0dfc08
> > > [   47.639804] FS:  00007f48316b7740(0000) GS:ffff8d69be800000(0000) =
knlGS:0000000000000000
> > > [   47.639805] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   47.639805] CR2: 00007fba36dd7de0 CR3: 000000003510e006 CR4: 00000=
00000160ee0
> > > [   47.639806] Call Trace:
> > > [   47.639809]  do_raw_spin_lock+0xab/0xb0
> > > [   47.639812]  _raw_spin_lock+0x63/0x80
> > > [   47.639816]  z3fold_zpool_shrink+0x303/0x540
> > > [   47.639820]  zswap_frontswap_store+0x424/0x7c1
> > > [   47.639823]  __frontswap_store+0xc4/0x162
> > > [   47.639825]  swap_writepage+0x39/0x70
> > > [   47.639827]  pageout.isra.0+0x12c/0x5d0
> > > [   47.639831]  shrink_page_list+0x1124/0x1830
> > > [   47.639835]  shrink_inactive_list+0x1da/0x460
> > > [   47.639836]  ? lruvec_lru_size+0x10/0x130
> > > [   47.639839]  shrink_node_memcg+0x202/0x770
> > > [   47.639843]  ? sched_clock_cpu+0xc/0xc0
> > > [   47.639847]  shrink_node+0xdc/0x4a0
> > > [   47.639850]  do_try_to_free_pages+0xdb/0x3c0
> > > [   47.639853]  try_to_free_pages+0x112/0x2e0
> > > [   47.639856]  __alloc_pages_slowpath+0x422/0x1000
> > > [   47.639858]  ? __lock_acquire+0x247/0x1900
> > > [   47.639863]  __alloc_pages_nodemask+0x37f/0x400
> > > [   47.639867]  alloc_pages_vma+0x79/0x1e0
> > > [   47.639869]  __read_swap_cache_async+0x1ec/0x3e0
> > > [   47.639871]  swap_cluster_readahead+0x184/0x330
> > > [   47.639873]  ? find_held_lock+0x32/0x90
> > > [   47.639876]  swapin_readahead+0x2b4/0x4e0
> > > [   47.639878]  ? sched_clock_cpu+0xc/0xc0
> > > [   47.639882]  do_swap_page+0x3ac/0xc30
> > > [   47.639885]  __handle_mm_fault+0x8dd/0x1900
> > > [   47.639889]  handle_mm_fault+0x159/0x340
> > > [   47.639891]  do_user_addr_fault+0x1fe/0x480
> > > [   47.639894]  do_page_fault+0x31/0x210
> > > [   47.639897]  page_fault+0x3e/0x50
> > > [   47.639898] RIP: 0033:0x562b503bd298
> > > [   47.639900] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [   47.639900] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > [   47.639901] RAX: 00000000011bb000 RBX: ffffffffffffffff RCX: 00007=
f48317b0156
> > > [   47.639902] RDX: 0000000000000000 RSI: 000000000b276000 RDI: 00000=
00000000000
> > > [   47.639902] RBP: 00007f4826441010 R08: 00007f4826441010 R09: 00000=
00000000000
> > > [   47.639903] R10: 00007f48275fb010 R11: 0000000000000246 R12: 00005=
62b503bf004
> > > [   47.639903] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b275800
> > > [   47.640770] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   47.645104] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   47.645108] RIP: 0010:queued_spin_lock_slowpath+0x184/0x1e0
> > > [   47.651057] RIP: 0010:queued_spin_lock_slowpath+0x124/0x1e0
> > > [   47.654927] Code: c1 ee 12 83 e0 03 83 ee 01 48 c1 e0 04 48 63 f6 =
48 05 00 c4 1e 00 48 03 04 f5 a0 96 18 bb 48 89 10 8b 42 08 85 c0 75 09 f3 =
90 <8b> 42 08 85 c0 74 f7 48 8b 02 48 85 c0 74 8b 48 89 c6 0f 18 08 eb
> > > [   47.660823] Code: 00 89 1d 00 eb a1 41 83 c0 01 c1 e1 10 41 c1 e0 =
12 44 09 c1 89 c8 c1 e8 10 66 87 47 02 89 c6 c1 e6 10 75 3c 31 f6 eb 02 f3 =
90 <8b> 07 66 85 c0 75 f7 41 89 c0 66 45 31 c0 41 39 c8 74 64 c6 07 01
> > > [   47.664219] RSP: 0000:ffffa073809f74a0 EFLAGS: 00000246 ORIG_RAX: =
ffffffffffffff13
> > > [   47.700778] watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [kco=
mpactd0:36]
> > > [   47.700779] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject=
_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat ip6table_mangle i=
p6table_raw ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw=
 iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_s=
et nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_=
pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net net_failo=
ver intel_agp intel_gtt failover qxl drm_kms_helper syscopyarea sysfillrect=
 sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw virtio_console virtio=
_blk agpgart qemu_fw_cfg
> > > [   47.700794] irq event stamp: 230655
> > > [   47.700798] hardirqs last  enabled at (230655): [<ffffffffba9d5b63=
>] _raw_spin_unlock_irqrestore+0x43/0x50
> > > [   47.700800] hardirqs last disabled at (230654): [<ffffffffba9d5916=
>] _raw_spin_lock_irqsave+0x16/0x80
> > > [   47.700801] softirqs last  enabled at (230330): [<ffffffffbac00351=
>] __do_softirq+0x351/0x451
> > > [   47.700803] softirqs last disabled at (230317): [<ffffffffba0c9821=
>] irq_exit+0xf1/0x100
> > > [   47.700805] CPU: 3 PID: 36 Comm: kcompactd0 Tainted: G      D W   =
 L    5.3.0-rc4 #69
> > > [   47.700805] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BI=
OS 1.12.0-2.fc30 04/01/2014
> > > [   47.700808] RIP: 0010:queued_spin_lock_slowpath+0x42/0x1e0
> > > [   47.700809] Code: 49 f0 0f ba 2f 08 0f 92 c0 0f b6 c0 c1 e0 08 89 =
c2 8b 07 30 e4 09 d0 a9 00 01 ff ff 75 23 85 c0 74 0e 8b 07 84 c0 74 08 f3 =
90 <8b> 07 84 c0 75 f8 b8 01 00 00 00 66 89 07 65 48 ff 05 18 f8 09 46
> > > [   47.700810] RSP: 0000:ffffa0738014fb60 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [   47.700811] RAX: 0000000000080101 RBX: ffff8d69bd0dfc08 RCX: 88888=
88888888889
> > > [   47.700811] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8=
d69bd0dfc08
> > > [   47.700812] RBP: ffff8d69bd0dfc08 R08: 000000053ed6a652 R09: 00000=
00000000000
> > > [   47.700812] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8=
d69bd0dfc20
> > > [   47.700813] R13: ffff8d69b5803350 R14: ffff8d69a2d93010 R15: ffffd=
090008b64c0
> > > [   47.700815] FS:  0000000000000000(0000) GS:ffff8d69bea00000(0000) =
knlGS:0000000000000000
> > > [   47.700816] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   47.700817] CR2: 00007f4826f45010 CR3: 000000000b212006 CR4: 00000=
00000160ee0
> > > [   47.700817] Call Trace:
> > > [   47.700819]  do_raw_spin_lock+0xab/0xb0
> > > [   47.700822]  _raw_spin_lock+0x63/0x80
> > > [   47.700825]  z3fold_page_migrate+0x28d/0x460
> > > [   47.700829]  move_to_new_page+0x2f3/0x420
> > > [   47.700832]  ? debug_check_no_obj_freed+0x107/0x1d8
> > > [   47.700835]  migrate_pages+0x991/0xfb0
> > > [   47.700838]  ? isolate_freepages_block+0x410/0x410
> > > [   47.700840]  ? __ClearPageMovable+0x90/0x90
> > > [   47.700843]  compact_zone+0x74c/0xef0
> > > [   47.700848]  kcompactd_do_work+0x14c/0x3c0
> > > [   47.700853]  kcompactd+0xbe/0x2b0
> > > [   47.700855]  ? finish_wait+0x90/0x90
> > > [   47.700858]  kthread+0x108/0x140
> > > [   47.700860]  ? kcompactd_do_work+0x3c0/0x3c0
> > > [   47.700861]  ? kthread_park+0x80/0x80
> > > [   47.700863]  ret_from_fork+0x3a/0x50
> > > [   47.703372] RSP: 0000:ffffa07380a17698 EFLAGS: 00000202 ORIG_RAX: =
ffffffffffffff13
> > > [   47.705576] RAX: 0000000000000000 RBX: ffff8d69bd0dfc08 RCX: 00000=
00000080000
> > > [   47.705577] RDX: ffff8d69be7ec400 RSI: 0000000000000002 RDI: ffff8=
d69bd0dfc08
> > > [   47.712349] RAX: 0000000000080101 RBX: ffff8d69bd0dfc08 RCX: 00000=
00000040000
> > > [   47.716287] RBP: ffff8d69bd0dfc08 R08: 0000000000080000 R09: 00000=
00000000000
> > > [   47.716288] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
d69bd0dfc20
> > > [   47.722821] RDX: ffff8d69be5ec400 RSI: 0000000000000000 RDI: ffff8=
d69bd0dfc08
> > > [   47.726705] R13: ffff8d69bd0dfc08 R14: 0000000000000000 R15: ffff8=
d69bd306000
> > > [   47.726708] FS:  00007f48316b7740(0000) GS:ffff8d69be600000(0000) =
knlGS:0000000000000000
> > > [   47.732581] RBP: ffff8d69bd0dfc08 R08: 0000000000040000 R09: 00000=
00000000000
> > > [   47.732582] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8=
d69bd0dfc20
> > > [   47.736598] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   47.736600] CR2: 00007f4829892010 CR3: 00000000350d4003 CR4: 00000=
00000160ee0
> > > [   47.741064] R13: ffff8d69bd0dfca0 R14: ffff8d69bd0dfc00 R15: ffff8=
d69bd0dfc08
> > > [   47.749689] Call Trace:
> > > [   47.755239] FS:  00007f48316b7740(0000) GS:ffff8d69be400000(0000) =
knlGS:0000000000000000
> > > [   47.758756]  do_raw_spin_lock+0xab/0xb0
> > > [   47.764302] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [   47.767811]  _raw_spin_lock+0x63/0x80
> > > [   47.772979] CR2: 0000000000000008 CR3: 00000000380ac005 CR4: 00000=
00000160ef0
> > > [   47.772982] Call Trace:
> > > [   47.776514]  z3fold_zpool_malloc+0xdc/0xa40
> > > [   47.782703]  do_raw_spin_lock+0xab/0xb0
> > > [   47.785710]  zswap_frontswap_store+0x2e8/0x7c1
> > > [   47.791314]  _raw_spin_lock+0x63/0x80
> > > [   47.793107]  __frontswap_store+0xc4/0x162
> > > [   47.796499]  z3fold_zpool_shrink+0x303/0x540
> > > [   47.798692]  swap_writepage+0x39/0x70
> > > [   47.802320]  zswap_frontswap_store+0x424/0x7c1
> > > [   47.804759]  pageout.isra.0+0x12c/0x5d0
> > > [   47.808202]  __frontswap_store+0xc4/0x162
> > > [   47.810332]  shrink_page_list+0x1124/0x1830
> > > [   47.813626]  swap_writepage+0x39/0x70
> > > [   47.815918]  shrink_inactive_list+0x1da/0x460
> > > [   47.819522]  pageout.isra.0+0x12c/0x5d0
> > > [   47.821714]  shrink_node_memcg+0x202/0x770
> > > [   47.825119]  shrink_page_list+0x1124/0x1830
> > > [   47.827210]  ? mem_cgroup_iter+0x8a/0x710
> > > [   47.830157]  shrink_inactive_list+0x1da/0x460
> > > [   47.832377]  shrink_node+0xdc/0x4a0
> > > [   47.835702]  ? lruvec_lru_size+0x10/0x130
> > > [   47.838040]  do_try_to_free_pages+0xdb/0x3c0
> > > [   47.841374]  shrink_node_memcg+0x202/0x770
> > > [   47.843667]  try_to_free_pages+0x112/0x2e0
> > > [   47.846805]  shrink_node+0xdc/0x4a0
> > > [   47.849115]  __alloc_pages_slowpath+0x422/0x1000
> > > [   47.852690]  do_try_to_free_pages+0xdb/0x3c0
> > > [   47.854689]  __alloc_pages_nodemask+0x37f/0x400
> > > [   47.857902]  try_to_free_pages+0x112/0x2e0
> > > [   47.859863]  alloc_pages_vma+0x79/0x1e0
> > > [   47.862806]  __alloc_pages_slowpath+0x422/0x1000
> > > [   47.864850]  __read_swap_cache_async+0x1ec/0x3e0
> > > [   47.867949]  __alloc_pages_nodemask+0x37f/0x400
> > > [   47.869963]  swap_cluster_readahead+0x184/0x330
> > > [   47.872753]  alloc_pages_vma+0x79/0x1e0
> > > [   47.874453]  swapin_readahead+0x2b4/0x4e0
> > > [   47.877285]  __handle_mm_fault+0x99c/0x1900
> > > [   47.885233]  do_swap_page+0x3ac/0xc30
> > > [   47.889167]  handle_mm_fault+0x159/0x340
> > > [   47.892265]  ? __switch_to_asm+0x40/0x70
> > > [   47.897433]  do_user_addr_fault+0x1fe/0x480
> > > [   47.900494]  ? __switch_to_asm+0x34/0x70
> > > [   47.900496]  ? __switch_to_asm+0x40/0x70
> > > [   47.905647]  do_page_fault+0x31/0x210
> > > [   47.908690]  ? __switch_to_asm+0x34/0x70
> > > [   47.908692]  __handle_mm_fault+0x8dd/0x1900
> > > [   47.914600]  page_fault+0x3e/0x50
> > > [   47.918164]  handle_mm_fault+0x159/0x340
> > > [   47.922255] RIP: 0033:0x562b503bd250
> > > [   47.924731]  do_user_addr_fault+0x1fe/0x480
> > > [   47.937476] Code: 0f 84 88 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 =
c0 89 04 24 41 83 fd 02 0f 8f f1 00 00 00 31 c0 4d 85 ff 7e 12 0f 1f 44 00 =
00 <c6> 44 05 00 5a 4c 01 f0 49 39 c7 7f f3 48 85 db 0f 84 dd 01 00 00
> > > [   47.944155]  do_page_fault+0x31/0x210
> > > [   47.947252] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > [   47.949763]  page_fault+0x3e/0x50
> > > [   47.970920] RAX: 000000000885c000 RBX: ffffffffffffffff RCX: 00007=
f48317b0156
> > > [   47.972527] RIP: 0033:0x562b503bd298
> > > [   47.976434] RDX: 0000000000000000 RSI: 000000000b276000 RDI: 00000=
00000000000
> > > [   47.979642] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84 4d =
00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49 39 c7 7e =
2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85 ed 0f 89 de
> > > [   47.983184] RBP: 00007f4826441010 R08: 00007f4826441010 R09: 00000=
00000000000
> > > [   47.983185] R10: 0000000000000022 R11: 0000000000000246 R12: 00005=
62b503bf004
> > > [   47.986079] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > [   47.989382] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b275800
> > > [   47.992427] RAX: 0000000003451000 RBX: ffffffffffffffff RCX: 00007=
f48317b0156
> > > [   47.992428] RDX: 0000000000000000 RSI: 000000000b276000 RDI: 00000=
00000000000
> > > [   48.222105] RBP: 00007f4826441010 R08: 00007f4826441010 R09: 00000=
00000000000
> > > [   48.224588] R10: 00007f4829891010 R11: 0000000000000246 R12: 00005=
62b503bf004
> > > [   48.227066] R13: 0000000000000002 R14: 0000000000001000 R15: 00000=
0000b275800
> >
> >
> > --
> > Michal Hocko
> > SUSE Labs

