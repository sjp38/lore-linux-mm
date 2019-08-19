Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C75C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 17:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A542087E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 17:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OHWRVkjp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A542087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48E326B0005; Mon, 19 Aug 2019 13:12:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43E856B0006; Mon, 19 Aug 2019 13:12:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 242CD6B0007; Mon, 19 Aug 2019 13:12:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id CD8936B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:12:19 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4859C181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:12:19 +0000 (UTC)
X-FDA: 75839820798.30.soap09_6b2fa177f220a
X-HE-Tag: soap09_6b2fa177f220a
X-Filterd-Recvd-Size: 181712
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com [209.85.208.173])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:12:16 +0000 (UTC)
Received: by mail-lj1-f173.google.com with SMTP id m24so2475253ljg.8
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 10:12:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3yIJg/wbanG98G9G9l1QFlUtwqPcMf6AjjQ61UNVHhY=;
        b=OHWRVkjpixjuiRfaOEpfMN6LPfFiBy2RsbyHxX4sjN/eAMv8UvszZE3LKZT8MpfFsO
         HQQALUW6FggAxAr6NyZBP4I5nz3g+Dv9SS4R0heuj7yZg4Fq6TRCyTuZZqKywsCs8j1G
         ZKMNr5Eyqr5lSj9s0oIYzuh7RcSfAwsctCKcGd1vdRrKA445+mWnMwuXKcqZw5xWFV3s
         fXaUrZu4noYtGreJdufdCB6Sk3RrUSH7yO8xj/N6OkvoDATstA/6qn9pjMwf5+IjjuZm
         RndW+btsjtf4JkEHVk6EVMyTHiTSV0cLBz5uMphyKgjkh3iVkjqioLpaMJOouHXyd8zA
         6W2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=3yIJg/wbanG98G9G9l1QFlUtwqPcMf6AjjQ61UNVHhY=;
        b=Ns68bSIgzQY/1dPZEjJpNE9SPRZcJbcMmLDyT+howtNgetKna8y4o63vuchzUSWAlW
         KDjh/SS0vny7RXyEtI0vnPfHC8M9v+v1iSkbj9qFTiH4cxu5R5bXZKXnPWND+7NAaNbr
         me4MHRpbnMYeg8TTcehk2KmpS7HHr11TMRnOD8Eleo/p1E0nLgEktouYjtDDcu+dDmi3
         Jd28Ko5pwAcBN4xIqpQfodp45lEMcvqegrBBp7rB/Ps4haHJwowteA33EEXpn/uut6/L
         pj2hUyMNys+O2ZLuOtp144rw9UDnV/S8YPvOjSq/2MxJwfsr7Ccgds0r6NcuiiyqDAiJ
         2dsQ==
X-Gm-Message-State: APjAAAXYCiS18wdyeD42stpjfgssd9LwT0VhMZhHrnhaSYQKmRdBNW4h
	/eYwJwg4CzFHEaWSbHwBhLqkKDTXNFnD2ncqFA0=
X-Google-Smtp-Source: APXvYqyed/22gsy3obezcx/3kh6b6kFb3SF54BBlBJDBZc/usHaVaDXPAvZQhmRs3zunLOhmgTKZPduLbIPomnUhWc0=
X-Received: by 2002:a2e:534e:: with SMTP id t14mr13327781ljd.218.1566234734327;
 Mon, 19 Aug 2019 10:12:14 -0700 (PDT)
MIME-Version: 1.0
References: <CAH6yVy3s6Z6EH+7QRcN740pZe6CP-kkC83VwYd4RvbRm6LF4OQ@mail.gmail.com>
 <20190819073456.GC3111@dhcp22.suse.cz> <CAMJBoFPGT0_GqZLuOxLWPtrYkwM2WLvZ9=8F7phnGEoGYSEW8Q@mail.gmail.com>
 <CAMJBoFN-TPggasbaEnpubXt+77XHQt+AGmu9A9JX2c=h7Tog0Q@mail.gmail.com> <CAH6yVy0S_=2tOcx2+LMT7DOe8xg+4KaVnzQiSGwLfGPsxD1g1Q@mail.gmail.com>
In-Reply-To: <CAH6yVy0S_=2tOcx2+LMT7DOe8xg+4KaVnzQiSGwLfGPsxD1g1Q@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 19 Aug 2019 10:11:59 -0700
Message-ID: <CAMJBoFPAOSd3w9YECBqT3nudBozEsMi7ODNE+3nCvKEjT-nhnQ@mail.gmail.com>
Subject: Re: PROBLEM: zswap with z3fold makes swap stuck
To: Markus Linnala <markus.linnala@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Content-Type: multipart/alternative; boundary="000000000000f97b6305907b707f"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000f97b6305907b707f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Den m=C3=A5n 19 aug. 2019 9:53 fmMarkus Linnala <markus.linnala@gmail.com> =
skrev:

> I've started to test 5.3-rc5 and generally there is about the same
> issues as 5.3-rc4. I'll start testing with your patch righ away.
>

I do not expect any change in behavior with rc5. We can aim for rc6 though.

~Vitaly

ma 19. elok. 2019 klo 18.27 Vitaly Wool (vitalywool@gmail.com) kirjoitti:
> >
> > On Mon, Aug 19, 2019 at 4:42 PM Vitaly Wool <vitalywool@gmail.com>
> wrote:
> > >
> > > Hey Michal,
> > >
> > > On Mon, Aug 19, 2019 at 9:35 AM Michal Hocko <mhocko@kernel.org>
> wrote:
> > > >
> > > > Thanks a lot for a detailed bug report. CC Vitaly.
> > >
> > > thanks for CC'ing me.
> > >
> > > > The original email preserved for more context.
> > >
> > > Thanks Markus for bisecting. That really gave me the clue. I'll come
> > > up with a patch within hours, would you be up for trying it?
> >
> > Patch: https://bugzilla.kernel.org/attachment.cgi?id=3D284507&action=3D=
diff
> >
> > > Best regards,
> > >    Vitaly
> > >
> > > > On Sun 18-08-19 21:36:19, Markus Linnala wrote:
> > > > > [1.] One line summary of the problem:
> > > > >
> > > > > zswap with z3fold makes swap stuck
> > > > >
> > > > >
> > > > > [2.] Full description of the problem/report:
> > > > >
> > > > > I've enabled zwswap using kernel parameters: zswap.enabled=3D1
> zswap.zpool=3Dz3fold
> > > > > When there is issue, every process using swapping is stuck.
> > > > >
> > > > > I can reproduce almost always in vanilla v5.3-rc4 running tool
> > > > > "stress", repeatedly.
> > > > >
> > > > >
> > > > > Issue starts with these messages:
> > > > > [   41.818966] BUG: unable to handle page fault for address:
> fffff54cf8000028
> > > > > [   14.458709] general protection fault: 0000 [#1] SMP PTI
> > > > > [   14.143173] kernel BUG at lib/list_debug.c:54!
> > > > > [  127.971860] kernel BUG at include/linux/mm.h:607!
> > > > >
> > > > >
> > > > > [3.] Keywords (i.e., modules, networking, kernel):
> > > > >
> > > > > zswap z3fold swapping swap bisect
> > > > >
> > > > >
> > > > > [4.] Kernel information
> > > > >
> > > > > [4.1.] Kernel version (from /proc/version):
> > > > >
> > > > > $ cat /proc/version
> > > > > Linux version 5.3.0-rc4 (maage@workstation.lan) (gcc version 9.1.=
1
> > > > > 20190503 (Red Hat 9.1.1-1) (GCC)) #69 SMP Fri Aug 16 19:52:23 EES=
T
> > > > > 2019
> > > > >
> > > > >
> > > > > [4.2.] Kernel .config file:
> > > > >
> > > > > Attached as config-5.3.0-rc4
> > > > >
> > > > > My vanilla kernel config is based on Fedora kernel kernel config,
> but
> > > > > most drivers not used in testing machine disabled to speed up tes=
t
> > > > > builds.
> > > > >
> > > > >
> > > > > [5.] Most recent kernel version which did not have the bug:
> > > > >
> > > > > I'm able to reproduce the issue in vanilla v5.3-rc4 and what ever
> came
> > > > > as bad during git bisect from v5.1 (good) and v5.3-rc4 (bad). And=
 I
> > > > > can also reproduce issue with some Fedora kernels, at least from
> > > > > 5.2.1-200.fc30.x86_64 on. About Fedora kernels:
> > > > > https://bugzilla.redhat.com/show_bug.cgi?id=3D1740690
> > > > >
> > > > > Result from git bisect:
> > > > >
> > > > > 7c2b8baa61fe578af905342938ad12f8dbaeae79 is the first bad commit
> > > > >
> > > > > commit 7c2b8baa61fe578af905342938ad12f8dbaeae79
> > > > > Author: Vitaly Wool <vitalywool@gmail.com>
> > > > > Date:   Mon May 13 17:22:49 2019 -0700
> > > > >
> > > > >     mm/z3fold.c: add structure for buddy handles
> > > > >
> > > > >     For z3fold to be able to move its pages per request of the
> memory
> > > > >     subsystem, it should not use direct object addresses in
> handles.  Instead,
> > > > >     it will create abstract handles (3 per page) which will
> contain pointers
> > > > >     to z3fold objects.  Thus, it will be possible to change these
> pointers
> > > > >     when z3fold page is moved.
> > > > >
> > > > >     Link:
> http://lkml.kernel.org/r/20190417103826.484eaf18c1294d682769880f@gmail.co=
m
> > > > >     Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
> > > > >     Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > > >     Cc: Dan Streetman <ddstreet@ieee.org>
> > > > >     Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> > > > >     Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
> > > > >     Cc: Uladzislau Rezki <urezki@gmail.com>
> > > > >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > > >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> > > > >
> > > > > :040000 040000 1a27b311b3ad8556062e45fff84d46a57ba8a4b1
> > > > > a79e463e14ab8ea271a89fb5f3069c3c84221478 M mm
> > > > > bisect run success
> > > > >
> > > > >
> > > > > [6.] Output of Oops.. message (if applicable) with symbolic
> information
> > > > >      resolved (see Documentation/admin-guide/bug-hunting.rst)
> > > > >
> > > > > 1st Full dmesg attached: dmesg-5.3.0-rc4-1566111932.476354086.txt
> > > > >
> > > > > [  105.710330] BUG: unable to handle page fault for address:
> ffffd2df8a000028
> > > > > [  105.714547] #PF: supervisor read access in kernel mode
> > > > > [  105.717893] #PF: error_code(0x0000) - not-present page
> > > > > [  105.721227] PGD 0 P4D 0
> > > > > [  105.722884] Oops: 0000 [#1] SMP PTI
> > > > > [  105.725152] CPU: 0 PID: 1240 Comm: stress Not tainted 5.3.0-rc=
4
> #69
> > > > > [  105.729219] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [  105.734756] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > > > [  105.737801] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00
> 00
> > > > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d
> 4e
> > > > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d
> 6d 10
> > > > > 4c 89
> > > > > [  105.749901] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > > > [  105.753230] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX:
> 0000000000000000
> > > > > [  105.757754] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI:
> ffff90edb5fdd600
> > > > > [  105.762362] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09:
> 0000000000000000
> > > > > [  105.766973] R10: 0000000000000003 R11: 0000000000000000 R12:
> ffff90edbab538d8
> > > > > [  105.771577] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15:
> ffffa82d809a3438
> > > > > [  105.776190] FS:  00007ff6a887b740(0000)
> GS:ffff90edbe400000(0000)
> > > > > knlGS:0000000000000000
> > > > > [  105.780549] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [  105.781436] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4:
> 0000000000160ef0
> > > > > [  105.782365] Call Trace:
> > > > > [  105.782668]  zswap_writeback_entry+0x50/0x410
> > > > > [  105.783199]  z3fold_zpool_shrink+0x4a6/0x540
> > > > > [  105.783717]  zswap_frontswap_store+0x424/0x7c1
> > > > > [  105.784329]  __frontswap_store+0xc4/0x162
> > > > > [  105.784815]  swap_writepage+0x39/0x70
> > > > > [  105.785282]  pageout.isra.0+0x12c/0x5d0
> > > > > [  105.785730]  shrink_page_list+0x1124/0x1830
> > > > > [  105.786335]  shrink_inactive_list+0x1da/0x460
> > > > > [  105.786882]  ? lruvec_lru_size+0x10/0x130
> > > > > [  105.787472]  shrink_node_memcg+0x202/0x770
> > > > > [  105.788011]  ? sched_clock_cpu+0xc/0xc0
> > > > > [  105.788594]  shrink_node+0xdc/0x4a0
> > > > > [  105.789012]  do_try_to_free_pages+0xdb/0x3c0
> > > > > [  105.789528]  try_to_free_pages+0x112/0x2e0
> > > > > [  105.790009]  __alloc_pages_slowpath+0x422/0x1000
> > > > > [  105.790547]  ? __lock_acquire+0x247/0x1900
> > > > > [  105.791040]  __alloc_pages_nodemask+0x37f/0x400
> > > > > [  105.791580]  alloc_pages_vma+0x79/0x1e0
> > > > > [  105.792064]  __read_swap_cache_async+0x1ec/0x3e0
> > > > > [  105.792639]  swap_cluster_readahead+0x184/0x330
> > > > > [  105.793194]  ? find_held_lock+0x32/0x90
> > > > > [  105.793681]  swapin_readahead+0x2b4/0x4e0
> > > > > [  105.794182]  ? sched_clock_cpu+0xc/0xc0
> > > > > [  105.794668]  do_swap_page+0x3ac/0xc30
> > > > > [  105.795658]  __handle_mm_fault+0x8dd/0x1900
> > > > > [  105.796729]  handle_mm_fault+0x159/0x340
> > > > > [  105.797723]  do_user_addr_fault+0x1fe/0x480
> > > > > [  105.798736]  do_page_fault+0x31/0x210
> > > > > [  105.799700]  page_fault+0x3e/0x50
> > > > > [  105.800597] RIP: 0033:0x56076f49e298
> > > > > [  105.801561] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84
> 4d
> > > > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49
> 39
> > > > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85
> ed 0f
> > > > > 89 de
> > > > > [  105.804770] RSP: 002b:00007ffe5fc72e70 EFLAGS: 00010206
> > > > > [  105.805931] RAX: 00000000013ad000 RBX: ffffffffffffffff RCX:
> 00007ff6a8974156
> > > > > [  105.807300] RDX: 0000000000000000 RSI: 000000000b78d000 RDI:
> 0000000000000000
> > > > > [  105.808679] RBP: 00007ff69d0ee010 R08: 00007ff69d0ee010 R09:
> 0000000000000000
> > > > > [  105.810055] R10: 00007ff69e49a010 R11: 0000000000000246 R12:
> 000056076f4a0004
> > > > > [  105.811383] R13: 0000000000000002 R14: 0000000000001000 R15:
> 000000000b78cc00
> > > > > [  105.812713] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > > > net_failover intel_agp failover intel_gtt qxl drm_kms_helper
> > > > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_inte=
l
> > > > > serio_raw agpgart virtio_blk virtio_console qemu_fw_cfg
> > > > > [  105.821561] CR2: ffffd2df8a000028
> > > > > [  105.822552] ---[ end trace d5f24e2cb83a2b76 ]---
> > > > > [  105.823659] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > > > [  105.824785] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00
> 00
> > > > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d
> 4e
> > > > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d
> 6d 10
> > > > > 4c 89
> > > > > [  105.828082] RSP: 0018:ffffa82d809a33f8 EFLAGS: 00010286
> > > > > [  105.829287] RAX: 0000000000000000 RBX: ffffd2df8a000000 RCX:
> 0000000000000000
> > > > > [  105.830713] RDX: 0000000080000000 RSI: ffff90edbab538d8 RDI:
> ffff90edb5fdd600
> > > > > [  105.832157] RBP: 0000000000000000 R08: ffff90edb5fdd600 R09:
> 0000000000000000
> > > > > [  105.833607] R10: 0000000000000003 R11: 0000000000000000 R12:
> ffff90edbab538d8
> > > > > [  105.835054] R13: ffff90edb5fdd6a0 R14: ffff90edb5fdd600 R15:
> ffffa82d809a3438
> > > > > [  105.836489] FS:  00007ff6a887b740(0000)
> GS:ffff90edbe400000(0000)
> > > > > knlGS:0000000000000000
> > > > > [  105.838103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [  105.839405] CR2: ffffd2df8a000028 CR3: 0000000036fde006 CR4:
> 0000000000160ef0
> > > > > [  105.840883] ------------[ cut here ]------------
> > > > >
> > > > >
> > > > > (gdb) l *zswap_writeback_entry+0x50
> > > > > 0xffffffff812e8490 is in zswap_writeback_entry
> (/src/linux/mm/zswap.c:858).
> > > > > 853 .sync_mode =3D WB_SYNC_NONE,
> > > > > 854 };
> > > > > 855
> > > > > 856 /* extract swpentry from data */
> > > > > 857 zhdr =3D zpool_map_handle(pool, handle, ZPOOL_MM_RO);
> > > > > 858 swpentry =3D zhdr->swpentry; /* here */
> > > > > 859 zpool_unmap_handle(pool, handle);
> > > > > 860 tree =3D zswap_trees[swp_type(swpentry)];
> > > > > 861 offset =3D swp_offset(swpentry);
> > > > >
> > > > >
> > > > > (gdb) l *z3fold_zpool_map+0x52
> > > > > 0xffffffff81337b32 is in z3fold_zpool_map
> > > > > (/src/linux/arch/x86/include/asm/bitops.h:207).
> > > > > 202 return GEN_BINARY_RMWcc(LOCK_PREFIX __ASM_SIZE(btc), *addr, c=
,
> "Ir", nr);
> > > > > 203 }
> > > > > 204
> > > > > 205 static __always_inline bool constant_test_bit(long nr, const
> > > > > volatile unsigned long *addr)
> > > > > 206 {
> > > > > 207 return ((1UL << (nr & (BITS_PER_LONG-1))) &
> > > > > 208 (addr[nr >> _BITOPS_LONG_SHIFT])) !=3D 0;
> > > > > 209 }
> > > > > 210
> > > > > 211 static __always_inline bool variable_test_bit(long nr, volati=
le
> > > > > const unsigned long *addr)
> > > > >
> > > > >
> > > > > (gdb) l *z3fold_zpool_shrink+0x4a6
> > > > > 0xffffffff81338796 is in z3fold_zpool_shrink
> (/src/linux/mm/z3fold.c:1173).
> > > > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > > > 1169 if (ret)
> > > > > 1170 goto next;
> > > > > 1171 }
> > > > > 1172 if (last_handle) {
> > > > > 1173 ret =3D pool->ops->evict(pool, last_handle);
> > > > > 1174 if (ret)
> > > > > 1175 goto next;
> > > > > 1176 }
> > > > > 1177 next:
> > > > >
> > > > >
> > > > > Because of test setup and swapping, usually ssh/shell etc are stu=
ck
> > > > > and it is not possible to get dmesg of other situations. So I've
> used
> > > > > console logging. It misses other boot messages though. They shoul=
d
> be
> > > > > about the same as 1st case.
> > > > >
> > > > >
> > > > > 2st console log attached: console-1566133726.340057021.log
> > > > >
> > > > > [   14.324867] general protection fault: 0000 [#1] SMP PTI
> > > > > [   14.330269] CPU: 1 PID: 150 Comm: kswapd0 Tainted: G        W
> > > > >   5.3.0-rc4 #69
> > > > > [   14.331359] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [   14.332511] RIP: 0010:handle_to_buddy+0x20/0x30
> > > > > [   14.333478] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00
> 53
> > > > > 48 89 fb 83 e7 01 0f 85 01 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2
> 00
> > > > > f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f
> 44 00
> > > > > 00 55
> > > > > [   14.336310] RSP: 0000:ffffb6cc0019f820 EFLAGS: 00010206
> > > > > [   14.337112] RAX: 00ffff8b24c22ed0 RBX: fffff46a4008bb40 RCX:
> 0000000000000000
> > > > > [   14.338174] RDX: 00ffff8b24c22000 RSI: ffff8b24fe7d89c8 RDI:
> ffff8b24fe7d89c8
> > > > > [   14.339112] RBP: ffff8b24c22ed000 R08: ffff8b24fe7d89c8 R09:
> 0000000000000000
> > > > > [   14.340407] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff8b24c22ed001
> > > > > [   14.341445] R13: ffff8b24c22ed010 R14: ffff8b24f5f70a00 R15:
> ffffb6cc0019f868
> > > > > [   14.342439] FS:  0000000000000000(0000)
> GS:ffff8b24fe600000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   14.343937] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   14.344771] CR2: 00007f37563d4010 CR3: 0000000008212005 CR4:
> 0000000000160ee0
> > > > > [   14.345816] Call Trace:
> > > > > [   14.346182]  z3fold_zpool_map+0x76/0x110
> > > > > [   14.347111]  zswap_writeback_entry+0x50/0x410
> > > > > [   14.347828]  z3fold_zpool_shrink+0x3c4/0x540
> > > > > [   14.348457]  zswap_frontswap_store+0x424/0x7c1
> > > > > [   14.349134]  __frontswap_store+0xc4/0x162
> > > > > [   14.349746]  swap_writepage+0x39/0x70
> > > > > [   14.350292]  pageout.isra.0+0x12c/0x5d0
> > > > > [   14.350899]  shrink_page_list+0x1124/0x1830
> > > > > [   14.351473]  shrink_inactive_list+0x1da/0x460
> > > > > [   14.352068]  shrink_node_memcg+0x202/0x770
> > > > > [   14.352697]  shrink_node+0xdc/0x4a0
> > > > > [   14.353204]  balance_pgdat+0x2e7/0x580
> > > > > [   14.353773]  kswapd+0x239/0x500
> > > > > [   14.354241]  ? finish_wait+0x90/0x90
> > > > > [   14.355003]  kthread+0x108/0x140
> > > > > [   14.355619]  ? balance_pgdat+0x580/0x580
> > > > > [   14.356216]  ? kthread_park+0x80/0x80
> > > > > [   14.356782]  ret_from_fork+0x3a/0x50
> > > > > [   14.357859] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_net net_failover
> > > > > virtio_balloon failover intel_agp intel_gtt qxl drm_kms_helper
> > > > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_inte=
l
> > > > > serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg
> > > > > [   14.369818] ---[ end trace 351ba6e5814522bd ]---
> > > > >
> > > > >
> > > > > (gdb) l *z3fold_zpool_map+0x76
> > > > > 0xffffffff81337b56 is in z3fold_zpool_map
> (/src/linux/mm/z3fold.c:1239).
> > > > > 1234 if (test_bit(PAGE_HEADLESS, &page->private))
> > > > > 1235 goto out;
> > > > > 1236
> > > > > 1237 z3fold_page_lock(zhdr);
> > > > > 1238 buddy =3D handle_to_buddy(handle);
> > > > > 1239 switch (buddy) {
> > > > > 1240 case FIRST:
> > > > > 1241 addr +=3D ZHDR_SIZE_ALIGNED;
> > > > > 1242 break;
> > > > > 1243 case MIDDLE:
> > > > >
> > > > > (gdb) l *z3fold_zpool_shrink+0x3c4
> > > > > 0xffffffff813386b4 is in z3fold_zpool_shrink
> (/src/linux/mm/z3fold.c:1168).
> > > > > 1163 ret =3D pool->ops->evict(pool, middle_handle);
> > > > > 1164 if (ret)
> > > > > 1165 goto next;
> > > > > 1166 }
> > > > > 1167 if (first_handle) {
> > > > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > > > 1169 if (ret)
> > > > > 1170 goto next;
> > > > > 1171 }
> > > > > 1172 if (last_handle) {
> > > > >
> > > > > (gdb) l *handle_to_buddy+0x20
> > > > > 0xffffffff81337550 is in handle_to_buddy
> (/src/linux/mm/z3fold.c:425).
> > > > > 420 unsigned long addr;
> > > > > 421
> > > > > 422 WARN_ON(handle & (1 << PAGE_HEADLESS));
> > > > > 423 addr =3D *(unsigned long *)handle;
> > > > > 424 zhdr =3D (struct z3fold_header *)(addr & PAGE_MASK);
> > > > > 425 return (addr - zhdr->first_num) & BUDDY_MASK;
> > > > > 426 }
> > > > > 427
> > > > > 428 static inline struct z3fold_pool *zhdr_to_pool(struct
> z3fold_header *zhdr)
> > > > > 429 {
> > > > >
> > > > >
> > > > > 3st console log attached: console-1566146080.512045588.log
> > > > >
> > > > > [ 4180.615506] kernel BUG at lib/list_debug.c:54!
> > > > > [ 4180.617034] invalid opcode: 0000 [#1] SMP PTI
> > > > > [ 4180.618059] CPU: 3 PID: 2129 Comm: stress Tainted: G        W
> > > > >   5.3.0-rc4 #69
> > > > > [ 4180.619811] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [ 4180.621757] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > > > [ 4180.623035] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89
> fe
> > > > > 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8
> 36
> > > > > 7e bf ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e
> bf ff
> > > > > 0f 0b
> > > > > [ 4180.627262] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > > > [ 4180.628459] RAX: 0000000000000054 RBX: ffff88a102053000 RCX:
> 0000000000000000
> > > > > [ 4180.630077] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI:
> ffff88a13bbd89c8
> > > > > [ 4180.631693] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09:
> 0000000000000000
> > > > > [ 4180.633271] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff88a13098a200
> > > > > [ 4180.634899] R13: ffff88a13098a208 R14: 0000000000000000 R15:
> ffff88a102053010
> > > > > [ 4180.636539] FS:  00007f86b900e740(0000)
> GS:ffff88a13ba00000(0000)
> > > > > knlGS:0000000000000000
> > > > > [ 4180.638394] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [ 4180.639733] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4:
> 0000000000160ee0
> > > > > [ 4180.641383] Call Trace:
> > > > > [ 4180.641965]  z3fold_zpool_malloc+0x106/0xa40
> > > > > [ 4180.642965]  zswap_frontswap_store+0x2e8/0x7c1
> > > > > [ 4180.643978]  __frontswap_store+0xc4/0x162
> > > > > [ 4180.644875]  swap_writepage+0x39/0x70
> > > > > [ 4180.645695]  pageout.isra.0+0x12c/0x5d0
> > > > > [ 4180.646553]  shrink_page_list+0x1124/0x1830
> > > > > [ 4180.647538]  shrink_inactive_list+0x1da/0x460
> > > > > [ 4180.648564]  shrink_node_memcg+0x202/0x770
> > > > > [ 4180.649529]  ? sched_clock_cpu+0xc/0xc0
> > > > > [ 4180.650432]  shrink_node+0xdc/0x4a0
> > > > > [ 4180.651258]  do_try_to_free_pages+0xdb/0x3c0
> > > > > [ 4180.652261]  try_to_free_pages+0x112/0x2e0
> > > > > [ 4180.653217]  __alloc_pages_slowpath+0x422/0x1000
> > > > > [ 4180.654294]  ? __lock_acquire+0x247/0x1900
> > > > > [ 4180.655254]  __alloc_pages_nodemask+0x37f/0x400
> > > > > [ 4180.656312]  alloc_pages_vma+0x79/0x1e0
> > > > > [ 4180.657169]  __read_swap_cache_async+0x1ec/0x3e0
> > > > > [ 4180.658197]  swap_cluster_readahead+0x184/0x330
> > > > > [ 4180.659211]  ? find_held_lock+0x32/0x90
> > > > > [ 4180.660111]  swapin_readahead+0x2b4/0x4e0
> > > > > [ 4180.661046]  ? sched_clock_cpu+0xc/0xc0
> > > > > [ 4180.661949]  do_swap_page+0x3ac/0xc30
> > > > > [ 4180.662807]  __handle_mm_fault+0x8dd/0x1900
> > > > > [ 4180.663790]  handle_mm_fault+0x159/0x340
> > > > > [ 4180.664713]  do_user_addr_fault+0x1fe/0x480
> > > > > [ 4180.665691]  do_page_fault+0x31/0x210
> > > > > [ 4180.666552]  page_fault+0x3e/0x50
> > > > > [ 4180.667818] RIP: 0033:0x555b3127d298
> > > > > [ 4180.669153] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84
> 4d
> > > > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49
> 39
> > > > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85
> ed 0f
> > > > > 89 de
> > > > > [ 4180.676117] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010206
> > > > > [ 4180.678515] RAX: 0000000000038000 RBX: ffffffffffffffff RCX:
> 00007f86b9107156
> > > > > [ 4180.681657] RDX: 0000000000000000 RSI: 000000000b805000 RDI:
> 0000000000000000
> > > > > [ 4180.684762] RBP: 00007f86ad809010 R08: 00007f86ad809010 R09:
> 0000000000000000
> > > > > [ 4180.687846] R10: 00007f86ad840010 R11: 0000000000000246 R12:
> 0000555b3127f004
> > > > > [ 4180.690919] R13: 0000000000000002 R14: 0000000000001000 R15:
> 000000000b804000
> > > > > [ 4180.693967] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon
> > > > > net_failover intel_agp failover intel_gtt qxl drm_kms_helper
> > > > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_inte=
l
> > > > > serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg
> > > > > [ 4180.715768] ---[ end trace 6eab0ae003d4d2ea ]---
> > > > > [ 4180.718021] RIP: 0010:__list_del_entry_valid.cold+0x1d/0x55
> > > > > [ 4180.720602] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0f 0b 48 89
> fe
> > > > > 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 fc 11 8f e8
> 36
> > > > > 7e bf ff <0f> 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc 11 8f e8 22 7e
> bf ff
> > > > > 0f 0b
> > > > > [ 4180.728474] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010246
> > > > > [ 4180.730969] RAX: 0000000000000054 RBX: ffff88a102053000 RCX:
> 0000000000000000
> > > > > [ 4180.734130] RDX: 0000000000000000 RSI: ffff88a13bbd89c8 RDI:
> ffff88a13bbd89c8
> > > > > [ 4180.737285] RBP: ffff88a102053000 R08: ffff88a13bbd89c8 R09:
> 0000000000000000
> > > > > [ 4180.740442] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff88a13098a200
> > > > > [ 4180.743609] R13: ffff88a13098a208 R14: 0000000000000000 R15:
> ffff88a102053010
> > > > > [ 4180.746774] FS:  00007f86b900e740(0000)
> GS:ffff88a13ba00000(0000)
> > > > > knlGS:0000000000000000
> > > > > [ 4180.750294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [ 4180.752986] CR2: 00007f86b1e1f010 CR3: 000000002f21e002 CR4:
> 0000000000160ee0
> > > > > [ 4180.756176] ------------[ cut here ]------------
> > > > >
> > > > > (gdb) l *z3fold_zpool_malloc+0x106
> > > > > 0xffffffff81338936 is in z3fold_zpool_malloc
> > > > > (/src/linux/include/linux/list.h:190).
> > > > > 185 * list_del_init - deletes entry from list and reinitialize it=
.
> > > > > 186 * @entry: the element to delete from the list.
> > > > > 187 */
> > > > > 188 static inline void list_del_init(struct list_head *entry)
> > > > > 189 {
> > > > > 190 __list_del_entry(entry);
> > > > > 191 INIT_LIST_HEAD(entry);
> > > > > 192 }
> > > > > 193
> > > > > 194 /**
> > > > >
> > > > > (gdb) l *zswap_frontswap_store+0x2e8
> > > > > 0xffffffff812e8b38 is in zswap_frontswap_store
> (/src/linux/mm/zswap.c:1073).
> > > > > 1068 goto put_dstmem;
> > > > > 1069 }
> > > > > 1070
> > > > > 1071 /* store */
> > > > > 1072 hlen =3D zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) =
: 0;
> > > > > 1073 ret =3D zpool_malloc(entry->pool->zpool, hlen + dlen,
> > > > > 1074    __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> > > > > 1075    &handle);
> > > > > 1076 if (ret =3D=3D -ENOSPC) {
> > > > > 1077 zswap_reject_compress_poor++;
> > > > >
> > > > >
> > > > > 4th console log attached: console-1566151496.204958451.log
> > > > >
> > > > > [   66.090333] BUG: unable to handle page fault for address:
> ffffeab2e2000028
> > > > > [   66.091245] #PF: supervisor read access in kernel mode
> > > > > [   66.091904] #PF: error_code(0x0000) - not-present page
> > > > > [   66.092552] PGD 0 P4D 0
> > > > > [   66.092885] Oops: 0000 [#1] SMP PTI
> > > > > [   66.093332] CPU: 2 PID: 1193 Comm: stress Not tainted 5.3.0-rc=
4
> #69
> > > > > [   66.094127] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [   66.095204] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > > > [   66.095799] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00
> 00
> > > > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d
> 4e
> > > > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d
> 6d 10
> > > > > 4c 89
> > > > > [   66.098132] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > > > [   66.098792] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX:
> 0000000000000000
> > > > > [   66.099685] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI:
> ffff9f67b39bca00
> > > > > [   66.100579] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09:
> 0000000000000000
> > > > > [   66.101477] R10: 0000000000000003 R11: 0000000000000000 R12:
> ffff9f67bb10e688
> > > > > [   66.102367] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15:
> ffffb7a200937628
> > > > > [   66.103263] FS:  00007f33df62b740(0000)
> GS:ffff9f67be800000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   66.104264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   66.104988] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4:
> 0000000000160ee0
> > > > > [   66.105878] Call Trace:
> > > > > [   66.106202]  zswap_writeback_entry+0x50/0x410
> > > > > [   66.106761]  z3fold_zpool_shrink+0x29d/0x540
> > > > > [   66.107305]  zswap_frontswap_store+0x424/0x7c1
> > > > > [   66.107870]  __frontswap_store+0xc4/0x162
> > > > > [   66.108383]  swap_writepage+0x39/0x70
> > > > > [   66.108847]  pageout.isra.0+0x12c/0x5d0
> > > > > [   66.109340]  shrink_page_list+0x1124/0x1830
> > > > > [   66.109872]  shrink_inactive_list+0x1da/0x460
> > > > > [   66.110430]  shrink_node_memcg+0x202/0x770
> > > > > [   66.110955]  shrink_node+0xdc/0x4a0
> > > > > [   66.111403]  do_try_to_free_pages+0xdb/0x3c0
> > > > > [   66.111946]  try_to_free_pages+0x112/0x2e0
> > > > > [   66.112468]  __alloc_pages_slowpath+0x422/0x1000
> > > > > [   66.113064]  ? __lock_acquire+0x247/0x1900
> > > > > [   66.113596]  __alloc_pages_nodemask+0x37f/0x400
> > > > > [   66.114179]  alloc_pages_vma+0x79/0x1e0
> > > > > [   66.114675]  __handle_mm_fault+0x99c/0x1900
> > > > > [   66.115218]  handle_mm_fault+0x159/0x340
> > > > > [   66.115719]  do_user_addr_fault+0x1fe/0x480
> > > > > [   66.116256]  do_page_fault+0x31/0x210
> > > > > [   66.116730]  page_fault+0x3e/0x50
> > > > > [   66.117168] RIP: 0033:0x556945873250
> > > > > [   66.117624] Code: 0f 84 88 02 00 00 8b 54 24 0c 31 c0 85 d2 0f
> 94
> > > > > c0 89 04 24 41 83 fd 02 0f 8f f1 00 00 00 31 c0 4d 85 ff 7e 12 0f
> 1f
> > > > > 44 00 00 <c6> 44 05 00 5a 4c 01 f0 49 39 c7 7f f3 48 85 db 0f 84
> dd 01
> > > > > 00 00
> > > > > [   66.120514] RSP: 002b:00007fffa5fc06c0 EFLAGS: 00010206
> > > > > [   66.121722] RAX: 000000000a0ad000 RBX: ffffffffffffffff RCX:
> 00007f33df724156
> > > > > [   66.123171] RDX: 0000000000000000 RSI: 000000000b7a4000 RDI:
> 0000000000000000
> > > > > [   66.124616] RBP: 00007f33d3e87010 R08: 00007f33d3e87010 R09:
> 0000000000000000
> > > > > [   66.126064] R10: 0000000000000022 R11: 0000000000000246 R12:
> 0000556945875004
> > > > > [   66.127499] R13: 0000000000000002 R14: 0000000000001000 R15:
> 000000000b7a3000
> > > > > [   66.128936] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_balloon intel_agp
> virtio_net
> > > > > net_failover failover intel_gtt qxl drm_kms_helper syscopyarea
> > > > > sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel serio_raw
> > > > > virtio_blk virtio_console agpgart qemu_fw_cfg
> > > > > [   66.138533] CR2: ffffeab2e2000028
> > > > > [   66.139562] ---[ end trace bfa9f40a545e4544 ]---
> > > > > [   66.140733] RIP: 0010:z3fold_zpool_map+0x52/0x110
> > > > > [   66.141886] Code: e8 48 01 ea 0f 82 ca 00 00 00 48 c7 c3 00 00
> 00
> > > > > 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 06 48 03 1d
> 4e
> > > > > eb e4 00 <48> 8b 53 28 83 e2 01 74 07 5b 5d 41 5c 41 5d c3 4c 8d
> 6d 10
> > > > > 4c 89
> > > > > [   66.145387] RSP: 0000:ffffb7a2009375e8 EFLAGS: 00010286
> > > > > [   66.146654] RAX: 0000000000000000 RBX: ffffeab2e2000000 RCX:
> 0000000000000000
> > > > > [   66.148137] RDX: 0000000080000000 RSI: ffff9f67bb10e688 RDI:
> ffff9f67b39bca00
> > > > > [   66.149626] RBP: 0000000000000000 R08: ffff9f67b39bca00 R09:
> 0000000000000000
> > > > > [   66.151128] R10: 0000000000000003 R11: 0000000000000000 R12:
> ffff9f67bb10e688
> > > > > [   66.152606] R13: ffff9f67b39bcaa0 R14: ffff9f67b39bca00 R15:
> ffffb7a200937628
> > > > > [   66.154076] FS:  00007f33df62b740(0000)
> GS:ffff9f67be800000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   66.155695] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   66.157020] CR2: ffffeab2e2000028 CR3: 000000003798a001 CR4:
> 0000000000160ee0
> > > > > [   66.158535] ------------[ cut here ]------------
> > > > >
> > > > > (gdb) l *z3fold_zpool_shrink+0x29d
> > > > > 0xffffffff8133858d is in z3fold_zpool_shrink
> (/src/linux/mm/z3fold.c:1168).
> > > > > 1163 ret =3D pool->ops->evict(pool, middle_handle);
> > > > > 1164 if (ret)
> > > > > 1165 goto next;
> > > > > 1166 }
> > > > > 1167 if (first_handle) {
> > > > > 1168 ret =3D pool->ops->evict(pool, first_handle);
> > > > > 1169 if (ret)
> > > > > 1170 goto next;
> > > > > 1171 }
> > > > > 1172 if (last_handle) {
> > > > >
> > > > >
> > > > > 5th console log is: console-1566152424.019311951.log
> > > > > [   22.529023] kernel BUG at include/linux/mm.h:607!
> > > > > [   22.529092] BUG: kernel NULL pointer dereference, address:
> 0000000000000008
> > > > > [   22.531789] #PF: supervisor read access in kernel mode
> > > > > [   22.532954] #PF: error_code(0x0000) - not-present page
> > > > > [   22.533722] PGD 0 P4D 0
> > > > > [   22.534097] Oops: 0000 [#1] SMP PTI
> > > > > [   22.534585] CPU: 0 PID: 186 Comm: kworker/u8:4 Not tainted
> 5.3.0-rc4 #69
> > > > > [   22.535488] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [   22.536633] Workqueue: zswap1 compact_page_work
> > > > > [   22.537263] RIP: 0010:__list_add_valid+0x3/0x40
> > > > > [   22.537868] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00
> 00
> > > > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90
> 90
> > > > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39
> c1 0f
> > > > > 85 98
> > > > > [   22.540322] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > > > [   22.540953] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX:
> 8888888888888889
> > > > > [   22.541838] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI:
> ffff8d69ad052000
> > > > > [   22.542747] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09:
> 0000000000000001
> > > > > [   22.543660] R10: 0000000000000001 R11: 0000000000000000 R12:
> 0000000000000000
> > > > > [   22.544614] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15:
> ffff8d69ad052010
> > > > > [   22.545578] FS:  0000000000000000(0000)
> GS:ffff8d69be400000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   22.546662] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   22.547452] CR2: 0000000000000008 CR3: 0000000035304001 CR4:
> 0000000000160ef0
> > > > > [   22.548488] Call Trace:
> > > > > [   22.548845]  do_compact_page+0x31e/0x430
> > > > > [   22.549406]  process_one_work+0x272/0x5a0
> > > > > [   22.549972]  worker_thread+0x50/0x3b0
> > > > > [   22.550488]  kthread+0x108/0x140
> > > > > [   22.550939]  ? process_one_work+0x5a0/0x5a0
> > > > > [   22.551531]  ? kthread_park+0x80/0x80
> > > > > [   22.552034]  ret_from_fork+0x3a/0x50
> > > > > [   22.552554] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > > > net_failover intel_agp intel_gtt failover qxl drm_kms_helper
> > > > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_inte=
l
> > > > > serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg
> > > > > [   22.559889] CR2: 0000000000000008
> > > > > [   22.560328] ---[ end trace cfa4596e38137687 ]---
> > > > > [   22.560330] invalid opcode: 0000 [#2] SMP PTI
> > > > > [   22.560981] RIP: 0010:__list_add_valid+0x3/0x40
> > > > > [   22.561515] CPU: 2 PID: 1063 Comm: stress Tainted: G      D
> > > > >   5.3.0-rc4 #69
> > > > > [   22.562143] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00
> 00
> > > > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90
> 90
> > > > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39
> c1 0f
> > > > > 85 98
> > > > > [   22.563034] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,
> > > > > BIOS 1.12.0-2.fc30 04/01/2014
> > > > > [   22.565759] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > > > [   22.565760] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX:
> 8888888888888889
> > > > > [   22.565761] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI:
> ffff8d69ad052000
> > > > > [   22.565761] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09:
> 0000000000000001
> > > > > [   22.565762] R10: 0000000000000001 R11: 0000000000000000 R12:
> 0000000000000000
> > > > > [   22.565763] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15:
> ffff8d69ad052010
> > > > > [   22.565765] FS:  0000000000000000(0000)
> GS:ffff8d69be400000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   22.565766] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   22.565766] CR2: 0000000000000008 CR3: 0000000035304001 CR4:
> 0000000000160ef0
> > > > > [   22.565797] note: kworker/u8:4[186] exited with preempt_count =
3
> > > > > [   22.581957] RIP: 0010:__free_pages+0x2d/0x30
> > > > > [   22.583146] Code: 00 00 8b 47 34 85 c0 74 15 f0 ff 4f 34 75 09
> 85
> > > > > f6 75 06 e9 75 ff ff ff c3 e9 4f e2 ff ff 48 c7 c6 e8 8c 0a bb e8
> d3
> > > > > 7f fd ff <0f> 0b 90 0f 1f 44 00 00 89 f1 41 bb 01 00 00 00 49 89
> fa 41
> > > > > d3 e3
> > > > > [   22.586649] RSP: 0018:ffffa073809ef4d0 EFLAGS: 00010246
> > > > > [   22.587963] RAX: 000000000000003e RBX: ffff8d6992d10000 RCX:
> 0000000000000006
> > > > > [   22.589579] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffffffbb0e5774
> > > > > [   22.591181] RBP: ffffd090004b4408 R08: 000000053ed5634a R09:
> 0000000000000000
> > > > > [   22.592781] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffffd090004b4400
> > > > > [   22.594339] R13: ffff8d69bd0dfca0 R14: ffff8d69bd0dfc00 R15:
> ffff8d69bd0dfc08
> > > > > [   22.595832] FS:  00007f48316b7740(0000)
> GS:ffff8d69be800000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   22.598649] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   22.601196] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4:
> 0000000000160ee0
> > > > > [   22.603539] Call Trace:
> > > > > [   22.605103]  z3fold_zpool_shrink+0x25f/0x540
> > > > > [   22.607218]  zswap_frontswap_store+0x424/0x7c1
> > > > > [   22.609115]  __frontswap_store+0xc4/0x162
> > > > > [   22.610819]  swap_writepage+0x39/0x70
> > > > > [   22.612525]  pageout.isra.0+0x12c/0x5d0
> > > > > [   22.613957]  shrink_page_list+0x1124/0x1830
> > > > > [   22.615130]  shrink_inactive_list+0x1da/0x460
> > > > > [   22.616311]  shrink_node_memcg+0x202/0x770
> > > > > [   22.617473]  ? sched_clock_cpu+0xc/0xc0
> > > > > [   22.619145]  shrink_node+0xdc/0x4a0
> > > > > [   22.620279]  do_try_to_free_pages+0xdb/0x3c0
> > > > > [   22.621450]  try_to_free_pages+0x112/0x2e0
> > > > > [   22.622582]  __alloc_pages_slowpath+0x422/0x1000
> > > > > [   22.623749]  ? __lock_acquire+0x247/0x1900
> > > > > [   22.624876]  __alloc_pages_nodemask+0x37f/0x400
> > > > > [   22.626007]  alloc_pages_vma+0x79/0x1e0
> > > > > [   22.627040]  __read_swap_cache_async+0x1ec/0x3e0
> > > > > [   22.628143]  swap_cluster_readahead+0x184/0x330
> > > > > [   22.629234]  ? find_held_lock+0x32/0x90
> > > > > [   22.630292]  swapin_readahead+0x2b4/0x4e0
> > > > > [   22.631370]  ? sched_clock_cpu+0xc/0xc0
> > > > > [   22.632379]  do_swap_page+0x3ac/0xc30
> > > > > [   22.633356]  __handle_mm_fault+0x8dd/0x1900
> > > > > [   22.634373]  handle_mm_fault+0x159/0x340
> > > > > [   22.635714]  do_user_addr_fault+0x1fe/0x480
> > > > > [   22.636738]  do_page_fault+0x31/0x210
> > > > > [   22.637674]  page_fault+0x3e/0x50
> > > > > [   22.638559] RIP: 0033:0x562b503bd298
> > > > > [   22.639476] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 44 8b 2d 84
> 4d
> > > > > 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4c 01 f0 49
> 39
> > > > > c7 7e 2d <80> 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c 89 14 24 45 85
> ed 0f
> > > > > 89 de
> > > > > [   22.642658] RSP: 002b:00007ffd83e31e80 EFLAGS: 00010206
> > > > > [   22.643900] RAX: 0000000000f09000 RBX: ffffffffffffffff RCX:
> 00007f48317b0156
> > > > > [   22.645242] RDX: 0000000000000000 RSI: 000000000b276000 RDI:
> 0000000000000000
> > > > > [   22.646571] RBP: 00007f4826441010 R08: 00007f4826441010 R09:
> 0000000000000000
> > > > > [   22.647888] R10: 00007f4827349010 R11: 0000000000000246 R12:
> 0000562b503bf004
> > > > > [   22.649210] R13: 0000000000000002 R14: 0000000000001000 R15:
> 000000000b275800
> > > > > [   22.650518] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_na=
t
> > > > > ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> > > > > iptable_mangle iptable_raw iptable_security nf_conntrack
> > > > > nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> > > > > ip6table_filter ip6_tables iptable_filter ip_tables
> crct10dif_pclmul
> > > > > crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_net
> > > > > net_failover intel_agp intel_gtt failover qxl drm_kms_helper
> > > > > syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_inte=
l
> > > > > serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg
> > > > > [   22.659276] ---[ end trace cfa4596e38137688 ]---
> > > > > [   22.660398] RIP: 0010:__list_add_valid+0x3/0x40
> > > > > [   22.661493] Code: f4 ff ff ff e9 3a ff ff ff 49 c7 07 00 00 00
> 00
> > > > > 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 90 90 90 90
> 90
> > > > > 49 89 d0 <48> 8b 52 08 48 39 f2 0f 85 7c 00 00 00 4c 8b 0a 4d 39
> c1 0f
> > > > > 85 98
> > > > > [   22.664800] RSP: 0000:ffffa073802cfdf8 EFLAGS: 00010206
> > > > > [   22.666779] RAX: 00000000000003c0 RBX: ffff8d69ad052000 RCX:
> 8888888888888889
> > > > > [   22.669830] RDX: 0000000000000000 RSI: ffffc0737f6012e8 RDI:
> ffff8d69ad052000
> > > > > [   22.672878] RBP: ffffc0737f6012e8 R08: 0000000000000000 R09:
> 0000000000000001
> > > > > [   22.675920] R10: 0000000000000001 R11: 0000000000000000 R12:
> 0000000000000000
> > > > > [   22.678966] R13: ffff8d69bd0dfc00 R14: ffff8d69bd0dfc08 R15:
> ffff8d69ad052010
> > > > > [   22.682014] FS:  00007f48316b7740(0000)
> GS:ffff8d69be800000(0000)
> > > > > knlGS:0000000000000000
> > > > > [   22.685399] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   22.687991] CR2: 00007fbcae5049b0 CR3: 00000000352fe002 CR4:
> 0000000000160ee0
> > > > > [   22.691068] ------------[ cut here ]------------
> > > > >
> > > > > (gdb) l *__list_add_valid+0x3
> > > > > 0xffffffff81551b43 is in __list_add_valid
> > > > > (/srv/s_maage/pkg/linux/linux/lib/list_debug.c:23).
> > > > > 18 */
> > > > > 19
> > > > > 20 bool __list_add_valid(struct list_head *new, struct list_head
> *prev,
> > > > > 21       struct list_head *next)
> > > > > 22 {
> > > > > 23 if (CHECK_DATA_CORRUPTION(next->prev !=3D prev,
> > > > > 24 "list_add corruption. next->prev should be prev (%px), but was
> %px.
> > > > > (next=3D%px).\n",
> > > > > 25 prev, next->prev, next) ||
> > > > > 26     CHECK_DATA_CORRUPTION(prev->next !=3D next,
> > > > > 27 "list_add corruption. prev->next should be next (%px), but was
> %px.
> > > > > (prev=3D%px).\n",
> > > > >
> > > > > (gdb) l *do_compact_page+0x31e
> > > > > 0xffffffff813396fe is in do_compact_page
> > > > > (/srv/s_maage/pkg/linux/linux/include/linux/list.h:60).
> > > > > 55 */
> > > > > 56 static inline void __list_add(struct list_head *new,
> > > > > 57       struct list_head *prev,
> > > > > 58       struct list_head *next)
> > > > > 59 {
> > > > > 60 if (!__list_add_valid(new, prev, next))
> > > > > 61 return;
> > > > > 62
> > > > > 63 next->prev =3D new;
> > > > > 64 new->next =3D next;
> > > > >
> > > > > (gdb) l *z3fold_zpool_shrink+0x25f
> > > > > 0xffffffff8133854f is in z3fold_zpool_shrink
> > > > >
> (/srv/s_maage/pkg/linux/linux/arch/x86/include/asm/atomic64_64.h:102).
> > > > > 97 *
> > > > > 98 * Atomically decrements @v by 1.
> > > > > 99 */
> > > > > 100 static __always_inline void arch_atomic64_dec(atomic64_t *v)
> > > > > 101 {
> > > > > 102 asm volatile(LOCK_PREFIX "decq %0"
> > > > > 103      : "=3Dm" (v->counter)
> > > > > 104      : "m" (v->counter) : "memory");
> > > > > 105 }
> > > > > 106 #define arch_atomic64_dec arch_atomic64_dec
> > > > >
> > > > > (gdb) l *zswap_frontswap_store+0x424
> > > > > 0xffffffff812e8c74 is in zswap_frontswap_store
> > > > > (/srv/s_maage/pkg/linux/linux/mm/zswap.c:955).
> > > > > 950
> > > > > 951 pool =3D zswap_pool_last_get();
> > > > > 952 if (!pool)
> > > > > 953 return -ENOENT;
> > > > > 954
> > > > > 955 ret =3D zpool_shrink(pool->zpool, 1, NULL);
> > > > > 956
> > > > > 957 zswap_pool_put(pool);
> > > > > 958
> > > > > 959 return ret;
> > > > >
> > > > >
> > > > >
> > > > > [7.] A small shell script or example program which triggers the
> > > > > problem (if possible)
> > > > >
> > > > > for tmout in 10 10 10 20 20 20 30 120 $((3600/2)) 10; do
> > > > >     stress --vm $(($(nproc)+2)) --vm-bytes $(($(awk
> > > > > '"'"'/MemAvail/{print $2}'"'"' /proc/meminfo)*1024/$(nproc)))
> > > > > --timeout '"$tmout"
> > > > > done
> > > > >
> > > > >
> > > > > [8.] Environment
> > > > >
> > > > > My test machine is Fedora 30 (minimal install) virtual machine
> running
> > > > > 4 vCPU and 1GiB RAM and 2GiB swap. Origninally I noticed the
> problem
> > > > > in other machines (Fedora 30). I guess any amount of memory
> pressure
> > > > > and zswap activation can cause problems.
> > > > >
> > > > > Test machine does only have whatever comes from install and
> whatever
> > > > > is enabled by default. Then I've also enabled serial console
> > > > > "console=3Dtty0 console=3DttyS0". Enabled passwordless sudo to he=
lp
> > > > > testing and then installed "stress."
> > > > >
> > > > > stress package version is stress-1.0.4-22.fc30
> > > > >
> > > > >
> > > > > [8.1.] Software (add the output of the ver_linux script here)
> > > > >
> > > > > $ ./ver_linux
> > > > > If some fields are empty or look unusual you may have an old
> version.
> > > > > Compare to the current minimal requirements in
> Documentation/Changes.
> > > > >
> > > > > Linux localhost.localdomain 5.3.0-rc4 #69 SMP Fri Aug 16 19:52:23
> EEST
> > > > > 2019 x86_64 x86_64 x86_64 GNU/Linux
> > > > >
> > > > > Util-linux          2.33.2
> > > > > Mount                2.33.2
> > > > > Module-init-tools    25
> > > > > E2fsprogs            1.44.6
> > > > > Linux C Library      2.29
> > > > > Dynamic linker (ldd) 2.29
> > > > > Linux C++ Library    6.0.26
> > > > > Procps              3.3.15
> > > > > Kbd                  2.0.4
> > > > > Console-tools        2.0.4
> > > > > Sh-utils            8.31
> > > > > Udev                241
> > > > > Modules Loaded      agpgart crc32c_intel crc32_pclmul
> crct10dif_pclmul
> > > > > drm drm_kms_helper failover fb_sys_fops ghash_clmulni_intel
> intel_agp
> > > > > intel_gtt ip6table_filter ip6table_mangle ip6table_nat ip6table_r=
aw
> > > > > ip6_tables ip6table_security ip6t_REJECT ip6t_rpfilter ip_set
> > > > > iptable_filter iptable_mangle iptable_nat iptable_raw ip_tables
> > > > > iptable_security ipt_REJECT libcrc32c net_failover nf_conntrack
> > > > > nf_defrag_ipv4 nf_defrag_ipv6 nf_nat nfnetlink nf_reject_ipv4
> > > > > nf_reject_ipv6 qemu_fw_cfg qxl serio_raw syscopyarea sysfillrect
> > > > > sysimgblt ttm virtio_balloon virtio_blk virtio_console virtio_net
> > > > > xt_conntrack
> > > > >
> > > > >
> > > > > [8.2.] Processor information (from /proc/cpuinfo):
> > > > >
> > > > > $ cat /proc/cpuinfo
> > > > > processor : 0
> > > > > vendor_id : GenuineIntel
> > > > > cpu family : 6
> > > > > model : 60
> > > > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > > > stepping : 1
> > > > > microcode : 0x1
> > > > > cpu MHz : 3198.099
> > > > > cache size : 16384 KB
> > > > > physical id : 0
> > > > > siblings : 1
> > > > > core id : 0
> > > > > cpu cores : 1
> > > > > apicid : 0
> > > > > initial apicid : 0
> > > > > fpu : yes
> > > > > fpu_exception : yes
> > > > > cpuid level : 13
> > > > > wp : yes
> > > > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov
> > > > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp =
lm
> > > > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse=
3
> fma
> > > > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer ae=
s
> > > > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ep=
t
> > > > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > > > xsaveopt arat umip md_clear
> > > > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf
> mds swapgs
> > > > > bogomips : 6396.19
> > > > > clflush size : 64
> > > > > cache_alignment : 64
> > > > > address sizes : 40 bits physical, 48 bits virtual
> > > > > power management:
> > > > >
> > > > > processor : 1
> > > > > vendor_id : GenuineIntel
> > > > > cpu family : 6
> > > > > model : 60
> > > > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > > > stepping : 1
> > > > > microcode : 0x1
> > > > > cpu MHz : 3198.099
> > > > > cache size : 16384 KB
> > > > > physical id : 1
> > > > > siblings : 1
> > > > > core id : 0
> > > > > cpu cores : 1
> > > > > apicid : 1
> > > > > initial apicid : 1
> > > > > fpu : yes
> > > > > fpu_exception : yes
> > > > > cpuid level : 13
> > > > > wp : yes
> > > > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov
> > > > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp =
lm
> > > > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse=
3
> fma
> > > > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer ae=
s
> > > > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ep=
t
> > > > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > > > xsaveopt arat umip md_clear
> > > > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf
> mds swapgs
> > > > > bogomips : 6468.62
> > > > > clflush size : 64
> > > > > cache_alignment : 64
> > > > > address sizes : 40 bits physical, 48 bits virtual
> > > > > power management:
> > > > >
> > > > > processor : 2
> > > > > vendor_id : GenuineIntel
> > > > > cpu family : 6
> > > > > model : 60
> > > > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > > > stepping : 1
> > > > > microcode : 0x1
> > > > > cpu MHz : 3198.099
> > > > > cache size : 16384 KB
> > > > > physical id : 2
> > > > > siblings : 1
> > > > > core id : 0
> > > > > cpu cores : 1
> > > > > apicid : 2
> > > > > initial apicid : 2
> > > > > fpu : yes
> > > > > fpu_exception : yes
> > > > > cpuid level : 13
> > > > > wp : yes
> > > > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov
> > > > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp =
lm
> > > > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse=
3
> fma
> > > > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer ae=
s
> > > > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ep=
t
> > > > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > > > xsaveopt arat umip md_clear
> > > > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf
> mds swapgs
> > > > > bogomips : 6627.92
> > > > > clflush size : 64
> > > > > cache_alignment : 64
> > > > > address sizes : 40 bits physical, 48 bits virtual
> > > > > power management:
> > > > >
> > > > > processor : 3
> > > > > vendor_id : GenuineIntel
> > > > > cpu family : 6
> > > > > model : 60
> > > > > model name : Intel Core Processor (Haswell, no TSX, IBRS)
> > > > > stepping : 1
> > > > > microcode : 0x1
> > > > > cpu MHz : 3198.099
> > > > > cache size : 16384 KB
> > > > > physical id : 3
> > > > > siblings : 1
> > > > > core id : 0
> > > > > cpu cores : 1
> > > > > apicid : 3
> > > > > initial apicid : 3
> > > > > fpu : yes
> > > > > fpu_exception : yes
> > > > > cpuid level : 13
> > > > > wp : yes
> > > > > flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov
> > > > > pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp =
lm
> > > > > constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq vmx ssse=
3
> fma
> > > > > cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer ae=
s
> > > > > xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_fault
> > > > > invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexpriority ep=
t
> > > > > vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid
> > > > > xsaveopt arat umip md_clear
> > > > > bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf
> mds swapgs
> > > > > bogomips : 6662.16
> > > > > clflush size : 64
> > > > > cache_alignment : 64
> > > > > address sizes : 40 bits physical, 48 bits virtual
> > > > > power management:
> > > > >
> > > > >
> > > > > [8.3.] Module information (from /proc/modules):
> > > > >
> > > > > $ cat /proc/modules
> > > > > ip6t_rpfilter 16384 1 - Live 0x0000000000000000
> > > > > ip6t_REJECT 16384 2 - Live 0x0000000000000000
> > > > > nf_reject_ipv6 20480 1 ip6t_REJECT, Live 0x0000000000000000
> > > > > ipt_REJECT 16384 2 - Live 0x0000000000000000
> > > > > nf_reject_ipv4 16384 1 ipt_REJECT, Live 0x0000000000000000
> > > > > xt_conntrack 16384 13 - Live 0x0000000000000000
> > > > > ip6table_nat 16384 1 - Live 0x0000000000000000
> > > > > ip6table_mangle 16384 1 - Live 0x0000000000000000
> > > > > ip6table_raw 16384 1 - Live 0x0000000000000000
> > > > > ip6table_security 16384 1 - Live 0x0000000000000000
> > > > > iptable_nat 16384 1 - Live 0x0000000000000000
> > > > > nf_nat 126976 2 ip6table_nat,iptable_nat, Live 0x0000000000000000
> > > > > iptable_mangle 16384 1 - Live 0x0000000000000000
> > > > > iptable_raw 16384 1 - Live 0x0000000000000000
> > > > > iptable_security 16384 1 - Live 0x0000000000000000
> > > > > nf_conntrack 241664 2 xt_conntrack,nf_nat, Live 0x000000000000000=
0
> > > > > nf_defrag_ipv6 24576 1 nf_conntrack, Live 0x0000000000000000
> > > > > nf_defrag_ipv4 16384 1 nf_conntrack, Live 0x0000000000000000
> > > > > libcrc32c 16384 2 nf_nat,nf_conntrack, Live 0x0000000000000000
> > > > > ip_set 69632 0 - Live 0x0000000000000000
> > > > > nfnetlink 20480 1 ip_set, Live 0x0000000000000000
> > > > > ip6table_filter 16384 1 - Live 0x0000000000000000
> > > > > ip6_tables 36864 7
> > > > >
> ip6table_nat,ip6table_mangle,ip6table_raw,ip6table_security,ip6table_filt=
er,
> > > > > Live 0x0000000000000000
> > > > > iptable_filter 16384 1 - Live 0x0000000000000000
> > > > > ip_tables 32768 5
> > > > >
> iptable_nat,iptable_mangle,iptable_raw,iptable_security,iptable_filter,
> > > > > Live 0x0000000000000000
> > > > > crct10dif_pclmul 16384 1 - Live 0x0000000000000000
> > > > > crc32_pclmul 16384 0 - Live 0x0000000000000000
> > > > > ghash_clmulni_intel 16384 0 - Live 0x0000000000000000
> > > > > virtio_net 61440 0 - Live 0x0000000000000000
> > > > > virtio_balloon 24576 0 - Live 0x0000000000000000
> > > > > net_failover 24576 1 virtio_net, Live 0x0000000000000000
> > > > > failover 16384 1 net_failover, Live 0x0000000000000000
> > > > > intel_agp 24576 0 - Live 0x0000000000000000
> > > > > intel_gtt 24576 1 intel_agp, Live 0x0000000000000000
> > > > > qxl 77824 0 - Live 0x0000000000000000
> > > > > drm_kms_helper 221184 3 qxl, Live 0x0000000000000000
> > > > > syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > > > sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > > > sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > > > fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
> > > > > ttm 126976 1 qxl, Live 0x0000000000000000
> > > > > drm 602112 4 qxl,drm_kms_helper,ttm, Live 0x0000000000000000
> > > > > crc32c_intel 24576 5 - Live 0x0000000000000000
> > > > > serio_raw 20480 0 - Live 0x0000000000000000
> > > > > virtio_blk 20480 3 - Live 0x0000000000000000
> > > > > virtio_console 45056 0 - Live 0x0000000000000000
> > > > > qemu_fw_cfg 20480 0 - Live 0x0000000000000000
> > > > > agpgart 53248 4 intel_agp,intel_gtt,ttm,drm, Live
> 0x0000000000000000
> > > > >
> > > > >
> > > > > [8.4.] Loaded driver and hardware information (/proc/ioports,
> /proc/iomem)
> > > > >
> > > > > $ cat /proc/ioports
> > > > > 0000-0000 : PCI Bus 0000:00
> > > > >   0000-0000 : dma1
> > > > >   0000-0000 : pic1
> > > > >   0000-0000 : timer0
> > > > >   0000-0000 : timer1
> > > > >   0000-0000 : keyboard
> > > > >   0000-0000 : keyboard
> > > > >   0000-0000 : rtc0
> > > > >   0000-0000 : dma page reg
> > > > >   0000-0000 : pic2
> > > > >   0000-0000 : dma2
> > > > >   0000-0000 : fpu
> > > > >   0000-0000 : vga+
> > > > >   0000-0000 : serial
> > > > >   0000-0000 : QEMU0002:00
> > > > >     0000-0000 : fw_cfg_io
> > > > >   0000-0000 : 0000:00:1f.0
> > > > >     0000-0000 : ACPI PM1a_EVT_BLK
> > > > >     0000-0000 : ACPI PM1a_CNT_BLK
> > > > >     0000-0000 : ACPI PM_TMR
> > > > >     0000-0000 : ACPI GPE0_BLK
> > > > >   0000-0000 : 0000:00:1f.3
> > > > > 0000-0000 : PCI conf1
> > > > > 0000-0000 : PCI Bus 0000:00
> > > > >   0000-0000 : PCI Bus 0000:01
> > > > >   0000-0000 : PCI Bus 0000:02
> > > > >   0000-0000 : PCI Bus 0000:03
> > > > >   0000-0000 : PCI Bus 0000:04
> > > > >   0000-0000 : PCI Bus 0000:05
> > > > >   0000-0000 : PCI Bus 0000:06
> > > > >   0000-0000 : PCI Bus 0000:07
> > > > >   0000-0000 : 0000:00:01.0
> > > > >   0000-0000 : 0000:00:1f.2
> > > > >     0000-0000 : ahci
> > > > >
> > > > > $ cat /proc/iomem
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : System RAM
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : PCI Bus 0000:00
> > > > > 00000000-00000000 : Video ROM
> > > > > 00000000-00000000 : Adapter ROM
> > > > > 00000000-00000000 : Adapter ROM
> > > > > 00000000-00000000 : Reserved
> > > > >   00000000-00000000 : System ROM
> > > > > 00000000-00000000 : System RAM
> > > > >   00000000-00000000 : Kernel code
> > > > >   00000000-00000000 : Kernel data
> > > > >   00000000-00000000 : Kernel bss
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : PCI MMCONFIG 0000 [bus 00-ff]
> > > > >   00000000-00000000 : Reserved
> > > > > 00000000-00000000 : PCI Bus 0000:00
> > > > >   00000000-00000000 : 0000:00:01.0
> > > > >   00000000-00000000 : 0000:00:01.0
> > > > >   00000000-00000000 : PCI Bus 0000:07
> > > > >   00000000-00000000 : PCI Bus 0000:06
> > > > >   00000000-00000000 : PCI Bus 0000:05
> > > > >   00000000-00000000 : PCI Bus 0000:04
> > > > >     00000000-00000000 : 0000:04:00.0
> > > > >   00000000-00000000 : PCI Bus 0000:03
> > > > >     00000000-00000000 : 0000:03:00.0
> > > > >   00000000-00000000 : PCI Bus 0000:02
> > > > >     00000000-00000000 : 0000:02:00.0
> > > > >       00000000-00000000 : xhci-hcd
> > > > >   00000000-00000000 : PCI Bus 0000:01
> > > > >     00000000-00000000 : 0000:01:00.0
> > > > >     00000000-00000000 : 0000:01:00.0
> > > > >   00000000-00000000 : 0000:00:1b.0
> > > > >   00000000-00000000 : 0000:00:01.0
> > > > >   00000000-00000000 : 0000:00:02.0
> > > > >   00000000-00000000 : 0000:00:02.1
> > > > >   00000000-00000000 : 0000:00:02.2
> > > > >   00000000-00000000 : 0000:00:02.3
> > > > >   00000000-00000000 : 0000:00:02.4
> > > > >   00000000-00000000 : 0000:00:02.5
> > > > >   00000000-00000000 : 0000:00:02.6
> > > > >   00000000-00000000 : 0000:00:1f.2
> > > > >     00000000-00000000 : ahci
> > > > >   00000000-00000000 : PCI Bus 0000:07
> > > > >   00000000-00000000 : PCI Bus 0000:06
> > > > >     00000000-00000000 : 0000:06:00.0
> > > > >       00000000-00000000 : virtio-pci-modern
> > > > >   00000000-00000000 : PCI Bus 0000:05
> > > > >     00000000-00000000 : 0000:05:00.0
> > > > >       00000000-00000000 : virtio-pci-modern
> > > > >   00000000-00000000 : PCI Bus 0000:04
> > > > >     00000000-00000000 : 0000:04:00.0
> > > > >       00000000-00000000 : virtio-pci-modern
> > > > >   00000000-00000000 : PCI Bus 0000:03
> > > > >     00000000-00000000 : 0000:03:00.0
> > > > >       00000000-00000000 : virtio-pci-modern
> > > > >   00000000-00000000 : PCI Bus 0000:02
> > > > >   00000000-00000000 : PCI Bus 0000:01
> > > > >     00000000-00000000 : 0000:01:00.0
> > > > >       00000000-00000000 : virtio-pci-modern
> > > > > 00000000-00000000 : IOAPIC 0
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : Local APIC
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : Reserved
> > > > > 00000000-00000000 : PCI Bus 0000:00
> > > > >
> > > > >
> > > > > [8.5.] PCI information ('lspci -vvv' as root)
> > > > >
> > > > > Attached as: lspci-vvv-5.3.0-rc4.txt
> > > > >
> > > > >
> > > > > [8.6.] SCSI information (from /proc/scsi/scsi)
> > > > >
> > > > > $ cat //proc/scsi/scsi
> > > > > Attached devices:
> > > > > Host: scsi0 Channel: 00 Id: 00 Lun: 00
> > > > >   Vendor: QEMU     Model: QEMU DVD-ROM     Rev: 2.5+
> > > > >   Type:   CD-ROM                           ANSI  SCSI revision: 0=
5
> > > > >
> > > > >
> > > > > [8.7.] Other information that might be relevant to the problem
> > > > >
> > > > > During testing it looks like this:
> > > > > $ egrep -r ^ /sys/module/zswap/parameters
> > > > > /sys/module/zswap/parameters/same_filled_pages_enabled:Y
> > > > > /sys/module/zswap/parameters/enabled:Y
> > > > > /sys/module/zswap/parameters/max_pool_percent:20
> > > > > /sys/module/zswap/parameters/compressor:lzo
> > > > > /sys/module/zswap/parameters/zpool:z3fold
> > > > >
> > > > > $ cat /proc/meminfo
> > > > > MemTotal:         983056 kB
> > > > > MemFree:          377876 kB
> > > > > MemAvailable:     660820 kB
> > > > > Buffers:           14896 kB
> > > > > Cached:           368028 kB
> > > > > SwapCached:            0 kB
> > > > > Active:           247500 kB
> > > > > Inactive:         193120 kB
> > > > > Active(anon):      58016 kB
> > > > > Inactive(anon):      280 kB
> > > > > Active(file):     189484 kB
> > > > > Inactive(file):   192840 kB
> > > > > Unevictable:           0 kB
> > > > > Mlocked:               0 kB
> > > > > SwapTotal:       4194300 kB
> > > > > SwapFree:        4194300 kB
> > > > > Dirty:                 8 kB
> > > > > Writeback:             0 kB
> > > > > AnonPages:         57712 kB
> > > > > Mapped:            81984 kB
> > > > > Shmem:               596 kB
> > > > > KReclaimable:      56272 kB
> > > > > Slab:             128128 kB
> > > > > SReclaimable:      56272 kB
> > > > > SUnreclaim:        71856 kB
> > > > > KernelStack:        2208 kB
> > > > > PageTables:         1632 kB
> > > > > NFS_Unstable:          0 kB
> > > > > Bounce:                0 kB
> > > > > WritebackTmp:          0 kB
> > > > > CommitLimit:     4685828 kB
> > > > > Committed_AS:     268512 kB
> > > > > VmallocTotal:   34359738367 kB
> > > > > VmallocUsed:        9764 kB
> > > > > VmallocChunk:          0 kB
> > > > > Percpu:             9312 kB
> > > > > HardwareCorrupted:     0 kB
> > > > > AnonHugePages:         0 kB
> > > > > ShmemHugePages:        0 kB
> > > > > ShmemPmdMapped:        0 kB
> > > > > CmaTotal:              0 kB
> > > > > CmaFree:               0 kB
> > > > > HugePages_Total:       0
> > > > > HugePages_Free:        0
> > > > > HugePages_Rsvd:        0
> > > > > HugePages_Surp:        0
> > > > > Hugepagesize:       2048 kB
> > > > > Hugetlb:               0 kB
> > > > > DirectMap4k:      110452 kB
> > > > > DirectMap2M:      937984 kB
> > > > > DirectMap1G:           0 kB
> > > > >
> > > > >
> > > > > [9.] Other notes
> > > > >
> > > > > My workaround is to disable zswap:
> > > > >
> > > > > sudo bash -c 'echo 0 > /sys/module/zswap/parameters/enabled'
> > > > >
> > > > >
> > > > > Sometimes stress can die just because it is out of memory. Also
> some
> > > > > other programs might die because of page allocation failures etc.
> But
> > > > > that is not relevant here.
> > > > >
> > > > >
> > > > > Generally stress command is actually like:
> > > > >
> > > > > stress --vm 6 --vm-bytes 228608000 --timeout 10
> > > > >
> > > > >
> > > > > It seems to be essential to start and stop stress runs. Sometimes
> > > > > problem does not trigger until much later. To be sure there is no
> > > > > problems I'd suggest running stress at least an hour (--timeout
> 3600)
> > > > > and also couple of hundred times with short timeout. I've used 90
> > > > > minutes as mark of "good" run during bisect (start of). I'm not
> sure
> > > > > if this is only one issue here.
> > > > >
> > > > > I reboot machine with kernel under test. Run uname -r and collect
> boot
> > > > > logs using ssh. And then ssh in with test script. No other comman=
ds
> > > > > are run.
> > > > >
> > > > > Some timestamps of errors to give idea how log to wait for test t=
o
> > > > > give results. Testing starts when machine has been up about 8 or =
9
> > > > > seconds.
> > > > >
> > > > >  [   13.805105] general protection fault: 0000 [#1] SMP PTI
> > > > >  [   14.059768] general protection fault: 0000 [#1] SMP PTI
> > > > >  [   14.324867] general protection fault: 0000 [#1] SMP PTI
> > > > >  [   14.458709] general protection fault: 0000 [#1] SMP PTI
> > > > >  [   41.818966] BUG: unable to handle page fault for address:
> fffff54cf8000028
> > > > >  [  105.710330] BUG: unable to handle page fault for address:
> ffffd2df8a000028
> > > > >  [  135.390332] BUG: unable to handle page fault for address:
> ffffe5a34a000028
> > > > >  [  166.793041] BUG: unable to handle page fault for address:
> ffffd1be6f000028
> > > > >  [  311.602285] BUG: unable to handle page fault for address:
> fffff7f409000028
> > > >
> > > > > 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express
> DRAM Controller
> > > > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > > > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast
> >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >       Kernel modules: intel_agp
> > > > >
> > > > > 00:01.0 VGA compatible controller: Red Hat, Inc. QXL paravirtual
> graphic card (rev 04) (prog-if 00 [VGA controller])
> > > > >       Subsystem: Red Hat, Inc. QEMU Virtual Machine
> > > > >       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast
> >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >       Interrupt: pin A routed to IRQ 21
> > > > >       Region 0: Memory at f4000000 (32-bit, non-prefetchable)
> [size=3D64M]
> > > > >       Region 1: Memory at f8000000 (32-bit, non-prefetchable)
> [size=3D64M]
> > > > >       Region 2: Memory at fce14000 (32-bit, non-prefetchable)
> [size=3D8K]
> > > > >       Region 3: I/O ports at c040 [size=3D32]
> > > > >       Expansion ROM at 000c0000 [disabled] [size=3D128K]
> > > > >       Kernel driver in use: qxl
> > > > >       Kernel modules: qxl
> > > > >
> > > > > 00:02.0 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00
> [Normal decode])
> > > > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast
> >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >       Latency: 0
> > > > >       Interrupt: pin A routed to IRQ 22
> > > > >       Region 0: Memory at fce16000 (32-bit, non-prefetchable)
> [size=3D4K]
> > > > >       Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-la=
tency=3D0
> > > > >       I/O behind bridge: 00001000-00001fff [size=3D4K]
> > > > >       Memory behind bridge: fcc00000-fcdfffff [size=3D2M]
> > > > >       Prefetchable memory behind bridge:
> 00000000fea00000-00000000febfffff [size=3D2M]
> > > > >       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast
> >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > > > >       BridgeCtl: Parity- SERR+ NoISA- VGA- VGA16- MAbort- >Reset-
> FastB2B-
> > > > >               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > > > >       Capabilities: [54] Express (v2) Root Port (Slot+), MSI 00
> > > > >               DevCap: MaxPayload 128 bytes, PhantFunc 0
> > > > >                       ExtTag- RBE+
> > > > >               DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
> > > > >                       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop=
-
> > > > >                       MaxPayload 128 bytes, MaxReadReq 128 bytes
> > > > >               DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq-
> AuxPwr- TransPend-
> > > > >               LnkCap: Port #16, Speed 2.5GT/s, Width x1, ASPM L0s=
,
> Exit Latency L0s <64ns
> > > > >                       ClockPM- Surprise- LLActRep- BwNot-
> ASPMOptComp-
> > > > >               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-
> CommClk-
> > > > >                       ExtSynch- ClockPM- AutWidDis- BWInt-
> AutBWInt-
> > > > >               LnkSta: Speed 2.5GT/s (ok), Width x1 (ok)
> > > > >                       TrErr- Train- SlotClk- DLActive+ BWMgmt-
> ABWMgmt-
> > > > >               SltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+
> HotPlug+ Surprise+
> > > > >                       Slot #0, PowerLimit 0.000W; Interlock+
> NoCompl-
> > > > >               SltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet-
> CmdCplt+ HPIrq+ LinkChg-
> > > > >                       Control: AttnInd Off, PwrInd On, Power-
> Interlock-
> > > > >               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet+ Interlock-
> > > > >                       Changed: MRL- PresDet- LinkState-
> > > > >               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
> > > > >               RootCap: CRSVisible-
> > > > >               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > > > >               DevCap2: Completion Timeout: Not Supported,
> TimeoutDis-, LTR-, OBFF Not Supported ARIFwd+
> > > > >                        AtomicOpsCap: Routing- 32bit- 64bit-
> 128bitCAS-
> > > > >               DevCtl2: Completion Timeout: 50us to 50ms,
> TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
> > > > >                        AtomicOpsCtl: ReqEn- EgressBlck-
> > > > >               LnkCtl2: Target Link Speed: 2.5GT/s,
> EnterCompliance- SpeedDis-
> > > > >                        Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
> > > > >                        Compliance De-emphasis: -6dB
> > > > >               LnkSta2: Current De-emphasis Level: -6dB,
> EqualizationComplete-, EqualizationPhase1-
> > > > >                        EqualizationPhase2-, EqualizationPhase3-,
> LinkEqualizationRequest-
> > > > >       Capabilities: [48] MSI-X: Enable+ Count=3D1 Masked-
> > > > >               Vector table: BAR=3D0 offset=3D00000000
> > > > >               PBA: BAR=3D0 offset=3D00000800
> > > > >       Capabilities: [40] Subsystem: Red Hat, Inc. Device 0000
> > > > >       Capabilities: [100 v2] Advanced Error Reporting
> > > > >               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > > >               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > > >               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > > > >               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> AdvNonFatalErr-
> > > > >               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> AdvNonFatalErr+
> > > > >               AERCap: First Error Pointer: 00, ECRCGenCap+
> ECRCGenEn- ECRCChkCap+ ECRCChkEn-
> > > > >                       MultHdrRecCap+ MultHdrRecEn- TLPPfxPres-
> HdrLogCap-
> > > > >               HeaderLog: 00000000 00000000 00000000 00000000
> > > > >               RootCmd: CERptEn+ NFERptEn+ FERptEn+
> > > > >               RootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-
> > > > >                        FirstFatal- NonFatalMsg- FatalMsg- IntMsg =
0
> > > > >               ErrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000
> > > > >       Kernel driver in use: pcieport
> > > > >
> > > > > 00:02.1 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (prog-if 00
> [Normal decode])
> > > > >       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > > >       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast
> >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >       La

--000000000000f97b6305907b707f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" =
class=3D"gmail_attr">Den m=C3=A5n 19 aug. 2019 9:53 fmMarkus Linnala &lt;<a=
 href=3D"mailto:markus.linnala@gmail.com">markus.linnala@gmail.com</a>&gt; =
skrev:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">I&#39;ve started to test 5.3=
-rc5 and generally there is about the same<br>
issues as 5.3-rc4. I&#39;ll start testing with your patch righ away.<br></b=
lockquote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">I do no=
t expect any change in behavior with rc5. We can aim for rc6 though.=C2=A0<=
/div><div dir=3D"auto"><br></div><div dir=3D"auto">~Vitaly=C2=A0</div><div =
dir=3D"auto"><br></div><div dir=3D"auto"><div class=3D"gmail_quote"><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">
ma 19. elok. 2019 klo 18.27 Vitaly Wool (<a href=3D"mailto:vitalywool@gmail=
.com" target=3D"_blank" rel=3D"noreferrer">vitalywool@gmail.com</a>) kirjoi=
tti:<br>
&gt;<br>
&gt; On Mon, Aug 19, 2019 at 4:42 PM Vitaly Wool &lt;<a href=3D"mailto:vita=
lywool@gmail.com" target=3D"_blank" rel=3D"noreferrer">vitalywool@gmail.com=
</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; Hey Michal,<br>
&gt; &gt;<br>
&gt; &gt; On Mon, Aug 19, 2019 at 9:35 AM Michal Hocko &lt;<a href=3D"mailt=
o:mhocko@kernel.org" target=3D"_blank" rel=3D"noreferrer">mhocko@kernel.org=
</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Thanks a lot for a detailed bug report. CC Vitaly.<br>
&gt; &gt;<br>
&gt; &gt; thanks for CC&#39;ing me.<br>
&gt; &gt;<br>
&gt; &gt; &gt; The original email preserved for more context.<br>
&gt; &gt;<br>
&gt; &gt; Thanks Markus for bisecting. That really gave me the clue. I&#39;=
ll come<br>
&gt; &gt; up with a patch within hours, would you be up for trying it?<br>
&gt;<br>
&gt; Patch: <a href=3D"https://bugzilla.kernel.org/attachment.cgi?id=3D2845=
07&amp;action=3Ddiff" rel=3D"noreferrer noreferrer" target=3D"_blank">https=
://bugzilla.kernel.org/attachment.cgi?id=3D284507&amp;action=3Ddiff</a><br>
&gt;<br>
&gt; &gt; Best regards,<br>
&gt; &gt;=C2=A0 =C2=A0 Vitaly<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Sun 18-08-19 21:36:19, Markus Linnala wrote:<br>
&gt; &gt; &gt; &gt; [1.] One line summary of the problem:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; zswap with z3fold makes swap stuck<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [2.] Full description of the problem/report:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I&#39;ve enabled zwswap using kernel parameters: zswap.=
enabled=3D1 zswap.zpool=3Dz3fold<br>
&gt; &gt; &gt; &gt; When there is issue, every process using swapping is st=
uck.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I can reproduce almost always in vanilla v5.3-rc4 runni=
ng tool<br>
&gt; &gt; &gt; &gt; &quot;stress&quot;, repeatedly.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Issue starts with these messages:<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A041.818966] BUG: unable to handle page fau=
lt for address: fffff54cf8000028<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.458709] general protection fault: 0000=
 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.143173] kernel BUG at lib/list_debug.c=
:54!<br>
&gt; &gt; &gt; &gt; [=C2=A0 127.971860] kernel BUG at include/linux/mm.h:60=
7!<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [3.] Keywords (i.e., modules, networking, kernel):<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; zswap z3fold swapping swap bisect<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [4.] Kernel information<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [4.1.] Kernel version (from /proc/version):<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/version<br>
&gt; &gt; &gt; &gt; Linux version 5.3.0-rc4 (maage@workstation.lan) (gcc ve=
rsion 9.1.1<br>
&gt; &gt; &gt; &gt; 20190503 (Red Hat 9.1.1-1) (GCC)) #69 SMP Fri Aug 16 19=
:52:23 EEST<br>
&gt; &gt; &gt; &gt; 2019<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [4.2.] Kernel .config file:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Attached as config-5.3.0-rc4<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; My vanilla kernel config is based on Fedora kernel kern=
el config, but<br>
&gt; &gt; &gt; &gt; most drivers not used in testing machine disabled to sp=
eed up test<br>
&gt; &gt; &gt; &gt; builds.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [5.] Most recent kernel version which did not have the =
bug:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I&#39;m able to reproduce the issue in vanilla v5.3-rc4=
 and what ever came<br>
&gt; &gt; &gt; &gt; as bad during git bisect from v5.1 (good) and v5.3-rc4 =
(bad). And I<br>
&gt; &gt; &gt; &gt; can also reproduce issue with some Fedora kernels, at l=
east from<br>
&gt; &gt; &gt; &gt; 5.2.1-200.fc30.x86_64 on. About Fedora kernels:<br>
&gt; &gt; &gt; &gt; <a href=3D"https://bugzilla.redhat.com/show_bug.cgi?id=
=3D1740690" rel=3D"noreferrer noreferrer" target=3D"_blank">https://bugzill=
a.redhat.com/show_bug.cgi?id=3D1740690</a><br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Result from git bisect:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 7c2b8baa61fe578af905342938ad12f8dbaeae79 is the first b=
ad commit<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; commit 7c2b8baa61fe578af905342938ad12f8dbaeae79<br>
&gt; &gt; &gt; &gt; Author: Vitaly Wool &lt;<a href=3D"mailto:vitalywool@gm=
ail.com" target=3D"_blank" rel=3D"noreferrer">vitalywool@gmail.com</a>&gt;<=
br>
&gt; &gt; &gt; &gt; Date:=C2=A0 =C2=A0Mon May 13 17:22:49 2019 -0700<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0mm/z3fold.c: add structure for buddy=
 handles<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0For z3fold to be able to move its pa=
ges per request of the memory<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0subsystem, it should not use direct =
object addresses in handles.=C2=A0 Instead,<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0it will create abstract handles (3 p=
er page) which will contain pointers<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0to z3fold objects.=C2=A0 Thus, it wi=
ll be possible to change these pointers<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0when z3fold page is moved.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Link: <a href=3D"http://lkml.kernel.=
org/r/20190417103826.484eaf18c1294d682769880f@gmail.com" rel=3D"noreferrer =
noreferrer" target=3D"_blank">http://lkml.kernel.org/r/20190417103826.484ea=
f18c1294d682769880f@gmail.com</a><br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Signed-off-by: Vitaly Wool &lt;<a hr=
ef=3D"mailto:vitaly.vul@sony.com" target=3D"_blank" rel=3D"noreferrer">vita=
ly.vul@sony.com</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Cc: Bartlomiej Zolnierkiewicz &lt;<a=
 href=3D"mailto:b.zolnierkie@samsung.com" target=3D"_blank" rel=3D"noreferr=
er">b.zolnierkie@samsung.com</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Cc: Dan Streetman &lt;<a href=3D"mai=
lto:ddstreet@ieee.org" target=3D"_blank" rel=3D"noreferrer">ddstreet@ieee.o=
rg</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Cc: Krzysztof Kozlowski &lt;<a href=
=3D"mailto:k.kozlowski@samsung.com" target=3D"_blank" rel=3D"noreferrer">k.=
kozlowski@samsung.com</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Cc: Oleksiy Avramchenko &lt;<a href=
=3D"mailto:oleksiy.avramchenko@sonymobile.com" target=3D"_blank" rel=3D"nor=
eferrer">oleksiy.avramchenko@sonymobile.com</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Cc: Uladzislau Rezki &lt;<a href=3D"=
mailto:urezki@gmail.com" target=3D"_blank" rel=3D"noreferrer">urezki@gmail.=
com</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Signed-off-by: Andrew Morton &lt;<a =
href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank" rel=3D"noreferr=
er">akpm@linux-foundation.org</a>&gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0Signed-off-by: Linus Torvalds &lt;<a=
 href=3D"mailto:torvalds@linux-foundation.org" target=3D"_blank" rel=3D"nor=
eferrer">torvalds@linux-foundation.org</a>&gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; :040000 040000 1a27b311b3ad8556062e45fff84d46a57ba8a4b1=
<br>
&gt; &gt; &gt; &gt; a79e463e14ab8ea271a89fb5f3069c3c84221478 M mm<br>
&gt; &gt; &gt; &gt; bisect run success<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [6.] Output of Oops.. message (if applicable) with symb=
olic information<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 resolved (see Documentation/admin-g=
uide/bug-hunting.rst)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 1st Full dmesg attached: dmesg-5.3.0-rc4-1566111932.476=
354086.txt<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.710330] BUG: unable to handle page fault fo=
r address: ffffd2df8a000028<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.714547] #PF: supervisor read access in kern=
el mode<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.717893] #PF: error_code(0x0000) - not-prese=
nt page<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.721227] PGD 0 P4D 0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.722884] Oops: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.725152] CPU: 0 PID: 1240 Comm: stress Not t=
ainted 5.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.729219] Hardware name: QEMU Standard PC (Q3=
5 + ICH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.734756] RIP: 0010:z3fold_zpool_map+0x52/0x1=
10<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.737801] Code: e8 48 01 ea 0f 82 ca 00 00 00=
 48 c7 c3 00 00 00<br>
&gt; &gt; &gt; &gt; 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 0=
6 48 03 1d 4e<br>
&gt; &gt; &gt; &gt; eb e4 00 &lt;48&gt; 8b 53 28 83 e2 01 74 07 5b 5d 41 5c=
 41 5d c3 4c 8d 6d 10<br>
&gt; &gt; &gt; &gt; 4c 89<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.749901] RSP: 0018:ffffa82d809a33f8 EFLAGS: =
00010286<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.753230] RAX: 0000000000000000 RBX: ffffd2df=
8a000000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.757754] RDX: 0000000080000000 RSI: ffff90ed=
bab538d8 RDI: ffff90edb5fdd600<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.762362] RBP: 0000000000000000 R08: ffff90ed=
b5fdd600 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.766973] R10: 0000000000000003 R11: 00000000=
00000000 R12: ffff90edbab538d8<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.771577] R13: ffff90edb5fdd6a0 R14: ffff90ed=
b5fdd600 R15: ffffa82d809a3438<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.776190] FS:=C2=A0 00007ff6a887b740(0000) GS=
:ffff90edbe400000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.780549] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR=
0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.781436] CR2: ffffd2df8a000028 CR3: 00000000=
36fde006 CR4: 0000000000160ef0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.782365] Call Trace:<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.782668]=C2=A0 zswap_writeback_entry+0x50/0x=
410<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.783199]=C2=A0 z3fold_zpool_shrink+0x4a6/0x5=
40<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.783717]=C2=A0 zswap_frontswap_store+0x424/0=
x7c1<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.784329]=C2=A0 __frontswap_store+0xc4/0x162<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 105.784815]=C2=A0 swap_writepage+0x39/0x70<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.785282]=C2=A0 pageout.isra.0+0x12c/0x5d0<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 105.785730]=C2=A0 shrink_page_list+0x1124/0x183=
0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.786335]=C2=A0 shrink_inactive_list+0x1da/0x=
460<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.786882]=C2=A0 ? lruvec_lru_size+0x10/0x130<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 105.787472]=C2=A0 shrink_node_memcg+0x202/0x770=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.788011]=C2=A0 ? sched_clock_cpu+0xc/0xc0<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 105.788594]=C2=A0 shrink_node+0xdc/0x4a0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.789012]=C2=A0 do_try_to_free_pages+0xdb/0x3=
c0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.789528]=C2=A0 try_to_free_pages+0x112/0x2e0=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.790009]=C2=A0 __alloc_pages_slowpath+0x422/=
0x1000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.790547]=C2=A0 ? __lock_acquire+0x247/0x1900=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.791040]=C2=A0 __alloc_pages_nodemask+0x37f/=
0x400<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.791580]=C2=A0 alloc_pages_vma+0x79/0x1e0<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 105.792064]=C2=A0 __read_swap_cache_async+0x1ec=
/0x3e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.792639]=C2=A0 swap_cluster_readahead+0x184/=
0x330<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.793194]=C2=A0 ? find_held_lock+0x32/0x90<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 105.793681]=C2=A0 swapin_readahead+0x2b4/0x4e0<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 105.794182]=C2=A0 ? sched_clock_cpu+0xc/0xc0<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 105.794668]=C2=A0 do_swap_page+0x3ac/0xc30<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.795658]=C2=A0 __handle_mm_fault+0x8dd/0x190=
0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.796729]=C2=A0 handle_mm_fault+0x159/0x340<b=
r>
&gt; &gt; &gt; &gt; [=C2=A0 105.797723]=C2=A0 do_user_addr_fault+0x1fe/0x48=
0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.798736]=C2=A0 do_page_fault+0x31/0x210<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.799700]=C2=A0 page_fault+0x3e/0x50<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.800597] RIP: 0033:0x56076f49e298<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.801561] Code: 7e 01 00 00 89 df e8 47 e1 ff=
 ff 44 8b 2d 84 4d<br>
&gt; &gt; &gt; &gt; 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4=
c 01 f0 49 39<br>
&gt; &gt; &gt; &gt; c7 7e 2d &lt;80&gt; 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c=
 89 14 24 45 85 ed 0f<br>
&gt; &gt; &gt; &gt; 89 de<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.804770] RSP: 002b:00007ffe5fc72e70 EFLAGS: =
00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.805931] RAX: 00000000013ad000 RBX: ffffffff=
ffffffff RCX: 00007ff6a8974156<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.807300] RDX: 0000000000000000 RSI: 00000000=
0b78d000 RDI: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.808679] RBP: 00007ff69d0ee010 R08: 00007ff6=
9d0ee010 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.810055] R10: 00007ff69e49a010 R11: 00000000=
00000246 R12: 000056076f4a0004<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.811383] R13: 0000000000000002 R14: 00000000=
00001000 R15: 000000000b78cc00<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.812713] Modules linked in: ip6t_rpfilter ip=
6t_REJECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_=
net<br>
&gt; &gt; &gt; &gt; net_failover intel_agp failover intel_gtt qxl drm_kms_h=
elper<br>
&gt; &gt; &gt; &gt; syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm c=
rc32c_intel<br>
&gt; &gt; &gt; &gt; serio_raw agpgart virtio_blk virtio_console qemu_fw_cfg=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.821561] CR2: ffffd2df8a000028<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.822552] ---[ end trace d5f24e2cb83a2b76 ]--=
-<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.823659] RIP: 0010:z3fold_zpool_map+0x52/0x1=
10<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.824785] Code: e8 48 01 ea 0f 82 ca 00 00 00=
 48 c7 c3 00 00 00<br>
&gt; &gt; &gt; &gt; 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 0=
6 48 03 1d 4e<br>
&gt; &gt; &gt; &gt; eb e4 00 &lt;48&gt; 8b 53 28 83 e2 01 74 07 5b 5d 41 5c=
 41 5d c3 4c 8d 6d 10<br>
&gt; &gt; &gt; &gt; 4c 89<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.828082] RSP: 0018:ffffa82d809a33f8 EFLAGS: =
00010286<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.829287] RAX: 0000000000000000 RBX: ffffd2df=
8a000000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.830713] RDX: 0000000080000000 RSI: ffff90ed=
bab538d8 RDI: ffff90edb5fdd600<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.832157] RBP: 0000000000000000 R08: ffff90ed=
b5fdd600 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.833607] R10: 0000000000000003 R11: 00000000=
00000000 R12: ffff90edbab538d8<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.835054] R13: ffff90edb5fdd6a0 R14: ffff90ed=
b5fdd600 R15: ffffa82d809a3438<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.836489] FS:=C2=A0 00007ff6a887b740(0000) GS=
:ffff90edbe400000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.838103] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR=
0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.839405] CR2: ffffd2df8a000028 CR3: 00000000=
36fde006 CR4: 0000000000160ef0<br>
&gt; &gt; &gt; &gt; [=C2=A0 105.840883] ------------[ cut here ]-----------=
-<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *zswap_writeback_entry+0x50<br>
&gt; &gt; &gt; &gt; 0xffffffff812e8490 is in zswap_writeback_entry (/src/li=
nux/mm/zswap.c:858).<br>
&gt; &gt; &gt; &gt; 853 .sync_mode =3D WB_SYNC_NONE,<br>
&gt; &gt; &gt; &gt; 854 };<br>
&gt; &gt; &gt; &gt; 855<br>
&gt; &gt; &gt; &gt; 856 /* extract swpentry from data */<br>
&gt; &gt; &gt; &gt; 857 zhdr =3D zpool_map_handle(pool, handle, ZPOOL_MM_RO=
);<br>
&gt; &gt; &gt; &gt; 858 swpentry =3D zhdr-&gt;swpentry; /* here */<br>
&gt; &gt; &gt; &gt; 859 zpool_unmap_handle(pool, handle);<br>
&gt; &gt; &gt; &gt; 860 tree =3D zswap_trees[swp_type(swpentry)];<br>
&gt; &gt; &gt; &gt; 861 offset =3D swp_offset(swpentry);<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_map+0x52<br>
&gt; &gt; &gt; &gt; 0xffffffff81337b32 is in z3fold_zpool_map<br>
&gt; &gt; &gt; &gt; (/src/linux/arch/x86/include/asm/bitops.h:207).<br>
&gt; &gt; &gt; &gt; 202 return GEN_BINARY_RMWcc(LOCK_PREFIX __ASM_SIZE(btc)=
, *addr, c, &quot;Ir&quot;, nr);<br>
&gt; &gt; &gt; &gt; 203 }<br>
&gt; &gt; &gt; &gt; 204<br>
&gt; &gt; &gt; &gt; 205 static __always_inline bool constant_test_bit(long =
nr, const<br>
&gt; &gt; &gt; &gt; volatile unsigned long *addr)<br>
&gt; &gt; &gt; &gt; 206 {<br>
&gt; &gt; &gt; &gt; 207 return ((1UL &lt;&lt; (nr &amp; (BITS_PER_LONG-1)))=
 &amp;<br>
&gt; &gt; &gt; &gt; 208 (addr[nr &gt;&gt; _BITOPS_LONG_SHIFT])) !=3D 0;<br>
&gt; &gt; &gt; &gt; 209 }<br>
&gt; &gt; &gt; &gt; 210<br>
&gt; &gt; &gt; &gt; 211 static __always_inline bool variable_test_bit(long =
nr, volatile<br>
&gt; &gt; &gt; &gt; const unsigned long *addr)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_shrink+0x4a6<br>
&gt; &gt; &gt; &gt; 0xffffffff81338796 is in z3fold_zpool_shrink (/src/linu=
x/mm/z3fold.c:1173).<br>
&gt; &gt; &gt; &gt; 1168 ret =3D pool-&gt;ops-&gt;evict(pool, first_handle)=
;<br>
&gt; &gt; &gt; &gt; 1169 if (ret)<br>
&gt; &gt; &gt; &gt; 1170 goto next;<br>
&gt; &gt; &gt; &gt; 1171 }<br>
&gt; &gt; &gt; &gt; 1172 if (last_handle) {<br>
&gt; &gt; &gt; &gt; 1173 ret =3D pool-&gt;ops-&gt;evict(pool, last_handle);=
<br>
&gt; &gt; &gt; &gt; 1174 if (ret)<br>
&gt; &gt; &gt; &gt; 1175 goto next;<br>
&gt; &gt; &gt; &gt; 1176 }<br>
&gt; &gt; &gt; &gt; 1177 next:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Because of test setup and swapping, usually ssh/shell e=
tc are stuck<br>
&gt; &gt; &gt; &gt; and it is not possible to get dmesg of other situations=
. So I&#39;ve used<br>
&gt; &gt; &gt; &gt; console logging. It misses other boot messages though. =
They should be<br>
&gt; &gt; &gt; &gt; about the same as 1st case.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 2st console log attached: console-1566133726.340057021.=
log<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.324867] general protection fault: 0000=
 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.330269] CPU: 1 PID: 150 Comm: kswapd0 =
Tainted: G=C2=A0 =C2=A0 =C2=A0 =C2=A0 W<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A05.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.331359] Hardware name: QEMU Standard P=
C (Q35 + ICH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.332511] RIP: 0010:handle_to_buddy+0x20=
/0x30<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.333478] Code: 84 00 00 00 00 00 0f 1f =
40 00 0f 1f 44 00 00 53<br>
&gt; &gt; &gt; &gt; 48 89 fb 83 e7 01 0f 85 01 26 00 00 48 8b 03 5b 48 89 c=
2 48 81 e2 00<br>
&gt; &gt; &gt; &gt; f0 ff ff &lt;0f&gt; b6 92 ca 00 00 00 29 d0 83 e0 03 c3=
 0f 1f 00 0f 1f 44 00<br>
&gt; &gt; &gt; &gt; 00 55<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.336310] RSP: 0000:ffffb6cc0019f820 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.337112] RAX: 00ffff8b24c22ed0 RBX: fff=
ff46a4008bb40 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.338174] RDX: 00ffff8b24c22000 RSI: fff=
f8b24fe7d89c8 RDI: ffff8b24fe7d89c8<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.339112] RBP: ffff8b24c22ed000 R08: fff=
f8b24fe7d89c8 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.340407] R10: 0000000000000000 R11: 000=
0000000000000 R12: ffff8b24c22ed001<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.341445] R13: ffff8b24c22ed010 R14: fff=
f8b24f5f70a00 R15: ffffb6cc0019f868<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.342439] FS:=C2=A0 0000000000000000(000=
0) GS:ffff8b24fe600000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.343937] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.344771] CR2: 00007f37563d4010 CR3: 000=
0000008212005 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.345816] Call Trace:<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.346182]=C2=A0 z3fold_zpool_map+0x76/0x=
110<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.347111]=C2=A0 zswap_writeback_entry+0x=
50/0x410<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.347828]=C2=A0 z3fold_zpool_shrink+0x3c=
4/0x540<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.348457]=C2=A0 zswap_frontswap_store+0x=
424/0x7c1<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.349134]=C2=A0 __frontswap_store+0xc4/0=
x162<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.349746]=C2=A0 swap_writepage+0x39/0x70=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.350292]=C2=A0 pageout.isra.0+0x12c/0x5=
d0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.350899]=C2=A0 shrink_page_list+0x1124/=
0x1830<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.351473]=C2=A0 shrink_inactive_list+0x1=
da/0x460<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.352068]=C2=A0 shrink_node_memcg+0x202/=
0x770<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.352697]=C2=A0 shrink_node+0xdc/0x4a0<b=
r>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.353204]=C2=A0 balance_pgdat+0x2e7/0x58=
0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.353773]=C2=A0 kswapd+0x239/0x500<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.354241]=C2=A0 ? finish_wait+0x90/0x90<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.355003]=C2=A0 kthread+0x108/0x140<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.355619]=C2=A0 ? balance_pgdat+0x580/0x=
580<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.356216]=C2=A0 ? kthread_park+0x80/0x80=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.356782]=C2=A0 ret_from_fork+0x3a/0x50<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.357859] Modules linked in: ip6t_rpfilt=
er ip6t_REJECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_net net_failove=
r<br>
&gt; &gt; &gt; &gt; virtio_balloon failover intel_agp intel_gtt qxl drm_kms=
_helper<br>
&gt; &gt; &gt; &gt; syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm c=
rc32c_intel<br>
&gt; &gt; &gt; &gt; serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A014.369818] ---[ end trace 351ba6e5814522b=
d ]---<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_map+0x76<br>
&gt; &gt; &gt; &gt; 0xffffffff81337b56 is in z3fold_zpool_map (/src/linux/m=
m/z3fold.c:1239).<br>
&gt; &gt; &gt; &gt; 1234 if (test_bit(PAGE_HEADLESS, &amp;page-&gt;private)=
)<br>
&gt; &gt; &gt; &gt; 1235 goto out;<br>
&gt; &gt; &gt; &gt; 1236<br>
&gt; &gt; &gt; &gt; 1237 z3fold_page_lock(zhdr);<br>
&gt; &gt; &gt; &gt; 1238 buddy =3D handle_to_buddy(handle);<br>
&gt; &gt; &gt; &gt; 1239 switch (buddy) {<br>
&gt; &gt; &gt; &gt; 1240 case FIRST:<br>
&gt; &gt; &gt; &gt; 1241 addr +=3D ZHDR_SIZE_ALIGNED;<br>
&gt; &gt; &gt; &gt; 1242 break;<br>
&gt; &gt; &gt; &gt; 1243 case MIDDLE:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_shrink+0x3c4<br>
&gt; &gt; &gt; &gt; 0xffffffff813386b4 is in z3fold_zpool_shrink (/src/linu=
x/mm/z3fold.c:1168).<br>
&gt; &gt; &gt; &gt; 1163 ret =3D pool-&gt;ops-&gt;evict(pool, middle_handle=
);<br>
&gt; &gt; &gt; &gt; 1164 if (ret)<br>
&gt; &gt; &gt; &gt; 1165 goto next;<br>
&gt; &gt; &gt; &gt; 1166 }<br>
&gt; &gt; &gt; &gt; 1167 if (first_handle) {<br>
&gt; &gt; &gt; &gt; 1168 ret =3D pool-&gt;ops-&gt;evict(pool, first_handle)=
;<br>
&gt; &gt; &gt; &gt; 1169 if (ret)<br>
&gt; &gt; &gt; &gt; 1170 goto next;<br>
&gt; &gt; &gt; &gt; 1171 }<br>
&gt; &gt; &gt; &gt; 1172 if (last_handle) {<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *handle_to_buddy+0x20<br>
&gt; &gt; &gt; &gt; 0xffffffff81337550 is in handle_to_buddy (/src/linux/mm=
/z3fold.c:425).<br>
&gt; &gt; &gt; &gt; 420 unsigned long addr;<br>
&gt; &gt; &gt; &gt; 421<br>
&gt; &gt; &gt; &gt; 422 WARN_ON(handle &amp; (1 &lt;&lt; PAGE_HEADLESS));<b=
r>
&gt; &gt; &gt; &gt; 423 addr =3D *(unsigned long *)handle;<br>
&gt; &gt; &gt; &gt; 424 zhdr =3D (struct z3fold_header *)(addr &amp; PAGE_M=
ASK);<br>
&gt; &gt; &gt; &gt; 425 return (addr - zhdr-&gt;first_num) &amp; BUDDY_MASK=
;<br>
&gt; &gt; &gt; &gt; 426 }<br>
&gt; &gt; &gt; &gt; 427<br>
&gt; &gt; &gt; &gt; 428 static inline struct z3fold_pool *zhdr_to_pool(stru=
ct z3fold_header *zhdr)<br>
&gt; &gt; &gt; &gt; 429 {<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 3st console log attached: console-1566146080.512045588.=
log<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [ 4180.615506] kernel BUG at lib/list_debug.c:54!<br>
&gt; &gt; &gt; &gt; [ 4180.617034] invalid opcode: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [ 4180.618059] CPU: 3 PID: 2129 Comm: stress Tainted: G=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 W<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A05.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [ 4180.619811] Hardware name: QEMU Standard PC (Q35 + I=
CH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [ 4180.621757] RIP: 0010:__list_del_entry_valid.cold+0x=
1d/0x55<br>
&gt; &gt; &gt; &gt; [ 4180.623035] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0=
f 0b 48 89 fe<br>
&gt; &gt; &gt; &gt; 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 f=
c 11 8f e8 36<br>
&gt; &gt; &gt; &gt; 7e bf ff &lt;0f&gt; 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc=
 11 8f e8 22 7e bf ff<br>
&gt; &gt; &gt; &gt; 0f 0b<br>
&gt; &gt; &gt; &gt; [ 4180.627262] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010=
246<br>
&gt; &gt; &gt; &gt; [ 4180.628459] RAX: 0000000000000054 RBX: ffff88a102053=
000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.630077] RDX: 0000000000000000 RSI: ffff88a13bbd8=
9c8 RDI: ffff88a13bbd89c8<br>
&gt; &gt; &gt; &gt; [ 4180.631693] RBP: ffff88a102053000 R08: ffff88a13bbd8=
9c8 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.633271] R10: 0000000000000000 R11: 0000000000000=
000 R12: ffff88a13098a200<br>
&gt; &gt; &gt; &gt; [ 4180.634899] R13: ffff88a13098a208 R14: 0000000000000=
000 R15: ffff88a102053010<br>
&gt; &gt; &gt; &gt; [ 4180.636539] FS:=C2=A0 00007f86b900e740(0000) GS:ffff=
88a13ba00000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.638394] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 00=
00000080050033<br>
&gt; &gt; &gt; &gt; [ 4180.639733] CR2: 00007f86b1e1f010 CR3: 000000002f21e=
002 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [ 4180.641383] Call Trace:<br>
&gt; &gt; &gt; &gt; [ 4180.641965]=C2=A0 z3fold_zpool_malloc+0x106/0xa40<br=
>
&gt; &gt; &gt; &gt; [ 4180.642965]=C2=A0 zswap_frontswap_store+0x2e8/0x7c1<=
br>
&gt; &gt; &gt; &gt; [ 4180.643978]=C2=A0 __frontswap_store+0xc4/0x162<br>
&gt; &gt; &gt; &gt; [ 4180.644875]=C2=A0 swap_writepage+0x39/0x70<br>
&gt; &gt; &gt; &gt; [ 4180.645695]=C2=A0 pageout.isra.0+0x12c/0x5d0<br>
&gt; &gt; &gt; &gt; [ 4180.646553]=C2=A0 shrink_page_list+0x1124/0x1830<br>
&gt; &gt; &gt; &gt; [ 4180.647538]=C2=A0 shrink_inactive_list+0x1da/0x460<b=
r>
&gt; &gt; &gt; &gt; [ 4180.648564]=C2=A0 shrink_node_memcg+0x202/0x770<br>
&gt; &gt; &gt; &gt; [ 4180.649529]=C2=A0 ? sched_clock_cpu+0xc/0xc0<br>
&gt; &gt; &gt; &gt; [ 4180.650432]=C2=A0 shrink_node+0xdc/0x4a0<br>
&gt; &gt; &gt; &gt; [ 4180.651258]=C2=A0 do_try_to_free_pages+0xdb/0x3c0<br=
>
&gt; &gt; &gt; &gt; [ 4180.652261]=C2=A0 try_to_free_pages+0x112/0x2e0<br>
&gt; &gt; &gt; &gt; [ 4180.653217]=C2=A0 __alloc_pages_slowpath+0x422/0x100=
0<br>
&gt; &gt; &gt; &gt; [ 4180.654294]=C2=A0 ? __lock_acquire+0x247/0x1900<br>
&gt; &gt; &gt; &gt; [ 4180.655254]=C2=A0 __alloc_pages_nodemask+0x37f/0x400=
<br>
&gt; &gt; &gt; &gt; [ 4180.656312]=C2=A0 alloc_pages_vma+0x79/0x1e0<br>
&gt; &gt; &gt; &gt; [ 4180.657169]=C2=A0 __read_swap_cache_async+0x1ec/0x3e=
0<br>
&gt; &gt; &gt; &gt; [ 4180.658197]=C2=A0 swap_cluster_readahead+0x184/0x330=
<br>
&gt; &gt; &gt; &gt; [ 4180.659211]=C2=A0 ? find_held_lock+0x32/0x90<br>
&gt; &gt; &gt; &gt; [ 4180.660111]=C2=A0 swapin_readahead+0x2b4/0x4e0<br>
&gt; &gt; &gt; &gt; [ 4180.661046]=C2=A0 ? sched_clock_cpu+0xc/0xc0<br>
&gt; &gt; &gt; &gt; [ 4180.661949]=C2=A0 do_swap_page+0x3ac/0xc30<br>
&gt; &gt; &gt; &gt; [ 4180.662807]=C2=A0 __handle_mm_fault+0x8dd/0x1900<br>
&gt; &gt; &gt; &gt; [ 4180.663790]=C2=A0 handle_mm_fault+0x159/0x340<br>
&gt; &gt; &gt; &gt; [ 4180.664713]=C2=A0 do_user_addr_fault+0x1fe/0x480<br>
&gt; &gt; &gt; &gt; [ 4180.665691]=C2=A0 do_page_fault+0x31/0x210<br>
&gt; &gt; &gt; &gt; [ 4180.666552]=C2=A0 page_fault+0x3e/0x50<br>
&gt; &gt; &gt; &gt; [ 4180.667818] RIP: 0033:0x555b3127d298<br>
&gt; &gt; &gt; &gt; [ 4180.669153] Code: 7e 01 00 00 89 df e8 47 e1 ff ff 4=
4 8b 2d 84 4d<br>
&gt; &gt; &gt; &gt; 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4=
c 01 f0 49 39<br>
&gt; &gt; &gt; &gt; c7 7e 2d &lt;80&gt; 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c=
 89 14 24 45 85 ed 0f<br>
&gt; &gt; &gt; &gt; 89 de<br>
&gt; &gt; &gt; &gt; [ 4180.676117] RSP: 002b:00007ffc7a9f9bf0 EFLAGS: 00010=
206<br>
&gt; &gt; &gt; &gt; [ 4180.678515] RAX: 0000000000038000 RBX: fffffffffffff=
fff RCX: 00007f86b9107156<br>
&gt; &gt; &gt; &gt; [ 4180.681657] RDX: 0000000000000000 RSI: 000000000b805=
000 RDI: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.684762] RBP: 00007f86ad809010 R08: 00007f86ad809=
010 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.687846] R10: 00007f86ad840010 R11: 0000000000000=
246 R12: 0000555b3127f004<br>
&gt; &gt; &gt; &gt; [ 4180.690919] R13: 0000000000000002 R14: 0000000000001=
000 R15: 000000000b804000<br>
&gt; &gt; &gt; &gt; [ 4180.693967] Modules linked in: ip6t_rpfilter ip6t_RE=
JECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_net virtio_ball=
oon<br>
&gt; &gt; &gt; &gt; net_failover intel_agp failover intel_gtt qxl drm_kms_h=
elper<br>
&gt; &gt; &gt; &gt; syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm c=
rc32c_intel<br>
&gt; &gt; &gt; &gt; serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg=
<br>
&gt; &gt; &gt; &gt; [ 4180.715768] ---[ end trace 6eab0ae003d4d2ea ]---<br>
&gt; &gt; &gt; &gt; [ 4180.718021] RIP: 0010:__list_del_entry_valid.cold+0x=
1d/0x55<br>
&gt; &gt; &gt; &gt; [ 4180.720602] Code: c7 c7 20 fb 11 8f e8 55 7e bf ff 0=
f 0b 48 89 fe<br>
&gt; &gt; &gt; &gt; 48 c7 c7 b0 fb 11 8f e8 44 7e bf ff 0f 0b 48 c7 c7 60 f=
c 11 8f e8 36<br>
&gt; &gt; &gt; &gt; 7e bf ff &lt;0f&gt; 0b 48 89 f2 48 89 fe 48 c7 c7 20 fc=
 11 8f e8 22 7e bf ff<br>
&gt; &gt; &gt; &gt; 0f 0b<br>
&gt; &gt; &gt; &gt; [ 4180.728474] RSP: 0000:ffffacfcc097f4c8 EFLAGS: 00010=
246<br>
&gt; &gt; &gt; &gt; [ 4180.730969] RAX: 0000000000000054 RBX: ffff88a102053=
000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.734130] RDX: 0000000000000000 RSI: ffff88a13bbd8=
9c8 RDI: ffff88a13bbd89c8<br>
&gt; &gt; &gt; &gt; [ 4180.737285] RBP: ffff88a102053000 R08: ffff88a13bbd8=
9c8 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.740442] R10: 0000000000000000 R11: 0000000000000=
000 R12: ffff88a13098a200<br>
&gt; &gt; &gt; &gt; [ 4180.743609] R13: ffff88a13098a208 R14: 0000000000000=
000 R15: ffff88a102053010<br>
&gt; &gt; &gt; &gt; [ 4180.746774] FS:=C2=A0 00007f86b900e740(0000) GS:ffff=
88a13ba00000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [ 4180.750294] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 00=
00000080050033<br>
&gt; &gt; &gt; &gt; [ 4180.752986] CR2: 00007f86b1e1f010 CR3: 000000002f21e=
002 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [ 4180.756176] ------------[ cut here ]------------<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_malloc+0x106<br>
&gt; &gt; &gt; &gt; 0xffffffff81338936 is in z3fold_zpool_malloc<br>
&gt; &gt; &gt; &gt; (/src/linux/include/linux/list.h:190).<br>
&gt; &gt; &gt; &gt; 185 * list_del_init - deletes entry from list and reini=
tialize it.<br>
&gt; &gt; &gt; &gt; 186 * @entry: the element to delete from the list.<br>
&gt; &gt; &gt; &gt; 187 */<br>
&gt; &gt; &gt; &gt; 188 static inline void list_del_init(struct list_head *=
entry)<br>
&gt; &gt; &gt; &gt; 189 {<br>
&gt; &gt; &gt; &gt; 190 __list_del_entry(entry);<br>
&gt; &gt; &gt; &gt; 191 INIT_LIST_HEAD(entry);<br>
&gt; &gt; &gt; &gt; 192 }<br>
&gt; &gt; &gt; &gt; 193<br>
&gt; &gt; &gt; &gt; 194 /**<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *zswap_frontswap_store+0x2e8<br>
&gt; &gt; &gt; &gt; 0xffffffff812e8b38 is in zswap_frontswap_store (/src/li=
nux/mm/zswap.c:1073).<br>
&gt; &gt; &gt; &gt; 1068 goto put_dstmem;<br>
&gt; &gt; &gt; &gt; 1069 }<br>
&gt; &gt; &gt; &gt; 1070<br>
&gt; &gt; &gt; &gt; 1071 /* store */<br>
&gt; &gt; &gt; &gt; 1072 hlen =3D zpool_evictable(entry-&gt;pool-&gt;zpool)=
 ? sizeof(zhdr) : 0;<br>
&gt; &gt; &gt; &gt; 1073 ret =3D zpool_malloc(entry-&gt;pool-&gt;zpool, hle=
n + dlen,<br>
&gt; &gt; &gt; &gt; 1074=C2=A0 =C2=A0 __GFP_NORETRY | __GFP_NOWARN | __GFP_=
KSWAPD_RECLAIM,<br>
&gt; &gt; &gt; &gt; 1075=C2=A0 =C2=A0 &amp;handle);<br>
&gt; &gt; &gt; &gt; 1076 if (ret =3D=3D -ENOSPC) {<br>
&gt; &gt; &gt; &gt; 1077 zswap_reject_compress_poor++;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 4th console log attached: console-1566151496.204958451.=
log<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.090333] BUG: unable to handle page fau=
lt for address: ffffeab2e2000028<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.091245] #PF: supervisor read access in=
 kernel mode<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.091904] #PF: error_code(0x0000) - not-=
present page<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.092552] PGD 0 P4D 0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.092885] Oops: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.093332] CPU: 2 PID: 1193 Comm: stress =
Not tainted 5.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.094127] Hardware name: QEMU Standard P=
C (Q35 + ICH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.095204] RIP: 0010:z3fold_zpool_map+0x5=
2/0x110<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.095799] Code: e8 48 01 ea 0f 82 ca 00 =
00 00 48 c7 c3 00 00 00<br>
&gt; &gt; &gt; &gt; 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 0=
6 48 03 1d 4e<br>
&gt; &gt; &gt; &gt; eb e4 00 &lt;48&gt; 8b 53 28 83 e2 01 74 07 5b 5d 41 5c=
 41 5d c3 4c 8d 6d 10<br>
&gt; &gt; &gt; &gt; 4c 89<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.098132] RSP: 0000:ffffb7a2009375e8 EFL=
AGS: 00010286<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.098792] RAX: 0000000000000000 RBX: fff=
feab2e2000000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.099685] RDX: 0000000080000000 RSI: fff=
f9f67bb10e688 RDI: ffff9f67b39bca00<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.100579] RBP: 0000000000000000 R08: fff=
f9f67b39bca00 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.101477] R10: 0000000000000003 R11: 000=
0000000000000 R12: ffff9f67bb10e688<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.102367] R13: ffff9f67b39bcaa0 R14: fff=
f9f67b39bca00 R15: ffffb7a200937628<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.103263] FS:=C2=A0 00007f33df62b740(000=
0) GS:ffff9f67be800000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.104264] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.104988] CR2: ffffeab2e2000028 CR3: 000=
000003798a001 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.105878] Call Trace:<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.106202]=C2=A0 zswap_writeback_entry+0x=
50/0x410<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.106761]=C2=A0 z3fold_zpool_shrink+0x29=
d/0x540<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.107305]=C2=A0 zswap_frontswap_store+0x=
424/0x7c1<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.107870]=C2=A0 __frontswap_store+0xc4/0=
x162<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.108383]=C2=A0 swap_writepage+0x39/0x70=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.108847]=C2=A0 pageout.isra.0+0x12c/0x5=
d0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.109340]=C2=A0 shrink_page_list+0x1124/=
0x1830<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.109872]=C2=A0 shrink_inactive_list+0x1=
da/0x460<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.110430]=C2=A0 shrink_node_memcg+0x202/=
0x770<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.110955]=C2=A0 shrink_node+0xdc/0x4a0<b=
r>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.111403]=C2=A0 do_try_to_free_pages+0xd=
b/0x3c0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.111946]=C2=A0 try_to_free_pages+0x112/=
0x2e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.112468]=C2=A0 __alloc_pages_slowpath+0=
x422/0x1000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.113064]=C2=A0 ? __lock_acquire+0x247/0=
x1900<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.113596]=C2=A0 __alloc_pages_nodemask+0=
x37f/0x400<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.114179]=C2=A0 alloc_pages_vma+0x79/0x1=
e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.114675]=C2=A0 __handle_mm_fault+0x99c/=
0x1900<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.115218]=C2=A0 handle_mm_fault+0x159/0x=
340<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.115719]=C2=A0 do_user_addr_fault+0x1fe=
/0x480<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.116256]=C2=A0 do_page_fault+0x31/0x210=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.116730]=C2=A0 page_fault+0x3e/0x50<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.117168] RIP: 0033:0x556945873250<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.117624] Code: 0f 84 88 02 00 00 8b 54 =
24 0c 31 c0 85 d2 0f 94<br>
&gt; &gt; &gt; &gt; c0 89 04 24 41 83 fd 02 0f 8f f1 00 00 00 31 c0 4d 85 f=
f 7e 12 0f 1f<br>
&gt; &gt; &gt; &gt; 44 00 00 &lt;c6&gt; 44 05 00 5a 4c 01 f0 49 39 c7 7f f3=
 48 85 db 0f 84 dd 01<br>
&gt; &gt; &gt; &gt; 00 00<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.120514] RSP: 002b:00007fffa5fc06c0 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.121722] RAX: 000000000a0ad000 RBX: fff=
fffffffffffff RCX: 00007f33df724156<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.123171] RDX: 0000000000000000 RSI: 000=
000000b7a4000 RDI: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.124616] RBP: 00007f33d3e87010 R08: 000=
07f33d3e87010 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.126064] R10: 0000000000000022 R11: 000=
0000000000246 R12: 0000556945875004<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.127499] R13: 0000000000000002 R14: 000=
0000000001000 R15: 000000000b7a3000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.128936] Modules linked in: ip6t_rpfilt=
er ip6t_REJECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_balloon intel_a=
gp virtio_net<br>
&gt; &gt; &gt; &gt; net_failover failover intel_gtt qxl drm_kms_helper sysc=
opyarea<br>
&gt; &gt; &gt; &gt; sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel =
serio_raw<br>
&gt; &gt; &gt; &gt; virtio_blk virtio_console agpgart qemu_fw_cfg<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.138533] CR2: ffffeab2e2000028<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.139562] ---[ end trace bfa9f40a545e454=
4 ]---<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.140733] RIP: 0010:z3fold_zpool_map+0x5=
2/0x110<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.141886] Code: e8 48 01 ea 0f 82 ca 00 =
00 00 48 c7 c3 00 00 00<br>
&gt; &gt; &gt; &gt; 80 48 2b 1d 70 eb e4 00 48 01 d3 48 c1 eb 0c 48 c1 e3 0=
6 48 03 1d 4e<br>
&gt; &gt; &gt; &gt; eb e4 00 &lt;48&gt; 8b 53 28 83 e2 01 74 07 5b 5d 41 5c=
 41 5d c3 4c 8d 6d 10<br>
&gt; &gt; &gt; &gt; 4c 89<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.145387] RSP: 0000:ffffb7a2009375e8 EFL=
AGS: 00010286<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.146654] RAX: 0000000000000000 RBX: fff=
feab2e2000000 RCX: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.148137] RDX: 0000000080000000 RSI: fff=
f9f67bb10e688 RDI: ffff9f67b39bca00<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.149626] RBP: 0000000000000000 R08: fff=
f9f67b39bca00 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.151128] R10: 0000000000000003 R11: 000=
0000000000000 R12: ffff9f67bb10e688<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.152606] R13: ffff9f67b39bcaa0 R14: fff=
f9f67b39bca00 R15: ffffb7a200937628<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.154076] FS:=C2=A0 00007f33df62b740(000=
0) GS:ffff9f67be800000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.155695] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.157020] CR2: ffffeab2e2000028 CR3: 000=
000003798a001 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A066.158535] ------------[ cut here ]------=
------<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_shrink+0x29d<br>
&gt; &gt; &gt; &gt; 0xffffffff8133858d is in z3fold_zpool_shrink (/src/linu=
x/mm/z3fold.c:1168).<br>
&gt; &gt; &gt; &gt; 1163 ret =3D pool-&gt;ops-&gt;evict(pool, middle_handle=
);<br>
&gt; &gt; &gt; &gt; 1164 if (ret)<br>
&gt; &gt; &gt; &gt; 1165 goto next;<br>
&gt; &gt; &gt; &gt; 1166 }<br>
&gt; &gt; &gt; &gt; 1167 if (first_handle) {<br>
&gt; &gt; &gt; &gt; 1168 ret =3D pool-&gt;ops-&gt;evict(pool, first_handle)=
;<br>
&gt; &gt; &gt; &gt; 1169 if (ret)<br>
&gt; &gt; &gt; &gt; 1170 goto next;<br>
&gt; &gt; &gt; &gt; 1171 }<br>
&gt; &gt; &gt; &gt; 1172 if (last_handle) {<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 5th console log is: console-1566152424.019311951.log<br=
>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.529023] kernel BUG at include/linux/mm=
.h:607!<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.529092] BUG: kernel NULL pointer deref=
erence, address: 0000000000000008<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.531789] #PF: supervisor read access in=
 kernel mode<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.532954] #PF: error_code(0x0000) - not-=
present page<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.533722] PGD 0 P4D 0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.534097] Oops: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.534585] CPU: 0 PID: 186 Comm: kworker/=
u8:4 Not tainted 5.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.535488] Hardware name: QEMU Standard P=
C (Q35 + ICH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.536633] Workqueue: zswap1 compact_page=
_work<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.537263] RIP: 0010:__list_add_valid+0x3=
/0x40<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.537868] Code: f4 ff ff ff e9 3a ff ff =
ff 49 c7 07 00 00 00 00<br>
&gt; &gt; &gt; &gt; 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 9=
0 90 90 90 90<br>
&gt; &gt; &gt; &gt; 49 89 d0 &lt;48&gt; 8b 52 08 48 39 f2 0f 85 7c 00 00 00=
 4c 8b 0a 4d 39 c1 0f<br>
&gt; &gt; &gt; &gt; 85 98<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.540322] RSP: 0000:ffffa073802cfdf8 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.540953] RAX: 00000000000003c0 RBX: fff=
f8d69ad052000 RCX: 8888888888888889<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.541838] RDX: 0000000000000000 RSI: fff=
fc0737f6012e8 RDI: ffff8d69ad052000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.542747] RBP: ffffc0737f6012e8 R08: 000=
0000000000000 R09: 0000000000000001<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.543660] R10: 0000000000000001 R11: 000=
0000000000000 R12: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.544614] R13: ffff8d69bd0dfc00 R14: fff=
f8d69bd0dfc08 R15: ffff8d69ad052010<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.545578] FS:=C2=A0 0000000000000000(000=
0) GS:ffff8d69be400000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.546662] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.547452] CR2: 0000000000000008 CR3: 000=
0000035304001 CR4: 0000000000160ef0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.548488] Call Trace:<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.548845]=C2=A0 do_compact_page+0x31e/0x=
430<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.549406]=C2=A0 process_one_work+0x272/0=
x5a0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.549972]=C2=A0 worker_thread+0x50/0x3b0=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.550488]=C2=A0 kthread+0x108/0x140<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.550939]=C2=A0 ? process_one_work+0x5a0=
/0x5a0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.551531]=C2=A0 ? kthread_park+0x80/0x80=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.552034]=C2=A0 ret_from_fork+0x3a/0x50<=
br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.552554] Modules linked in: ip6t_rpfilt=
er ip6t_REJECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_=
net<br>
&gt; &gt; &gt; &gt; net_failover intel_agp intel_gtt failover qxl drm_kms_h=
elper<br>
&gt; &gt; &gt; &gt; syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm c=
rc32c_intel<br>
&gt; &gt; &gt; &gt; serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.559889] CR2: 0000000000000008<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.560328] ---[ end trace cfa4596e3813768=
7 ]---<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.560330] invalid opcode: 0000 [#2] SMP =
PTI<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.560981] RIP: 0010:__list_add_valid+0x3=
/0x40<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.561515] CPU: 2 PID: 1063 Comm: stress =
Tainted: G=C2=A0 =C2=A0 =C2=A0 D<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A05.3.0-rc4 #69<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.562143] Code: f4 ff ff ff e9 3a ff ff =
ff 49 c7 07 00 00 00 00<br>
&gt; &gt; &gt; &gt; 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 9=
0 90 90 90 90<br>
&gt; &gt; &gt; &gt; 49 89 d0 &lt;48&gt; 8b 52 08 48 39 f2 0f 85 7c 00 00 00=
 4c 8b 0a 4d 39 c1 0f<br>
&gt; &gt; &gt; &gt; 85 98<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.563034] Hardware name: QEMU Standard P=
C (Q35 + ICH9, 2009),<br>
&gt; &gt; &gt; &gt; BIOS 1.12.0-2.fc30 04/01/2014<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565759] RSP: 0000:ffffa073802cfdf8 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565760] RAX: 00000000000003c0 RBX: fff=
f8d69ad052000 RCX: 8888888888888889<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565761] RDX: 0000000000000000 RSI: fff=
fc0737f6012e8 RDI: ffff8d69ad052000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565761] RBP: ffffc0737f6012e8 R08: 000=
0000000000000 R09: 0000000000000001<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565762] R10: 0000000000000001 R11: 000=
0000000000000 R12: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565763] R13: ffff8d69bd0dfc00 R14: fff=
f8d69bd0dfc08 R15: ffff8d69ad052010<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565765] FS:=C2=A0 0000000000000000(000=
0) GS:ffff8d69be400000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565766] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565766] CR2: 0000000000000008 CR3: 000=
0000035304001 CR4: 0000000000160ef0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.565797] note: kworker/u8:4[186] exited=
 with preempt_count 3<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.581957] RIP: 0010:__free_pages+0x2d/0x=
30<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.583146] Code: 00 00 8b 47 34 85 c0 74 =
15 f0 ff 4f 34 75 09 85<br>
&gt; &gt; &gt; &gt; f6 75 06 e9 75 ff ff ff c3 e9 4f e2 ff ff 48 c7 c6 e8 8=
c 0a bb e8 d3<br>
&gt; &gt; &gt; &gt; 7f fd ff &lt;0f&gt; 0b 90 0f 1f 44 00 00 89 f1 41 bb 01=
 00 00 00 49 89 fa 41<br>
&gt; &gt; &gt; &gt; d3 e3<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.586649] RSP: 0018:ffffa073809ef4d0 EFL=
AGS: 00010246<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.587963] RAX: 000000000000003e RBX: fff=
f8d6992d10000 RCX: 0000000000000006<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.589579] RDX: 0000000000000000 RSI: 000=
0000000000000 RDI: ffffffffbb0e5774<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.591181] RBP: ffffd090004b4408 R08: 000=
000053ed5634a R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.592781] R10: 0000000000000000 R11: 000=
0000000000000 R12: ffffd090004b4400<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.594339] R13: ffff8d69bd0dfca0 R14: fff=
f8d69bd0dfc00 R15: ffff8d69bd0dfc08<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.595832] FS:=C2=A0 00007f48316b7740(000=
0) GS:ffff8d69be800000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.598649] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.601196] CR2: 00007fbcae5049b0 CR3: 000=
00000352fe002 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.603539] Call Trace:<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.605103]=C2=A0 z3fold_zpool_shrink+0x25=
f/0x540<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.607218]=C2=A0 zswap_frontswap_store+0x=
424/0x7c1<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.609115]=C2=A0 __frontswap_store+0xc4/0=
x162<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.610819]=C2=A0 swap_writepage+0x39/0x70=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.612525]=C2=A0 pageout.isra.0+0x12c/0x5=
d0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.613957]=C2=A0 shrink_page_list+0x1124/=
0x1830<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.615130]=C2=A0 shrink_inactive_list+0x1=
da/0x460<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.616311]=C2=A0 shrink_node_memcg+0x202/=
0x770<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.617473]=C2=A0 ? sched_clock_cpu+0xc/0x=
c0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.619145]=C2=A0 shrink_node+0xdc/0x4a0<b=
r>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.620279]=C2=A0 do_try_to_free_pages+0xd=
b/0x3c0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.621450]=C2=A0 try_to_free_pages+0x112/=
0x2e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.622582]=C2=A0 __alloc_pages_slowpath+0=
x422/0x1000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.623749]=C2=A0 ? __lock_acquire+0x247/0=
x1900<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.624876]=C2=A0 __alloc_pages_nodemask+0=
x37f/0x400<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.626007]=C2=A0 alloc_pages_vma+0x79/0x1=
e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.627040]=C2=A0 __read_swap_cache_async+=
0x1ec/0x3e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.628143]=C2=A0 swap_cluster_readahead+0=
x184/0x330<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.629234]=C2=A0 ? find_held_lock+0x32/0x=
90<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.630292]=C2=A0 swapin_readahead+0x2b4/0=
x4e0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.631370]=C2=A0 ? sched_clock_cpu+0xc/0x=
c0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.632379]=C2=A0 do_swap_page+0x3ac/0xc30=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.633356]=C2=A0 __handle_mm_fault+0x8dd/=
0x1900<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.634373]=C2=A0 handle_mm_fault+0x159/0x=
340<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.635714]=C2=A0 do_user_addr_fault+0x1fe=
/0x480<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.636738]=C2=A0 do_page_fault+0x31/0x210=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.637674]=C2=A0 page_fault+0x3e/0x50<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.638559] RIP: 0033:0x562b503bd298<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.639476] Code: 7e 01 00 00 89 df e8 47 =
e1 ff ff 44 8b 2d 84 4d<br>
&gt; &gt; &gt; &gt; 00 00 4d 85 ff 7e 40 31 c0 eb 0f 0f 1f 80 00 00 00 00 4=
c 01 f0 49 39<br>
&gt; &gt; &gt; &gt; c7 7e 2d &lt;80&gt; 7c 05 00 5a 4c 8d 54 05 00 74 ec 4c=
 89 14 24 45 85 ed 0f<br>
&gt; &gt; &gt; &gt; 89 de<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.642658] RSP: 002b:00007ffd83e31e80 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.643900] RAX: 0000000000f09000 RBX: fff=
fffffffffffff RCX: 00007f48317b0156<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.645242] RDX: 0000000000000000 RSI: 000=
000000b276000 RDI: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.646571] RBP: 00007f4826441010 R08: 000=
07f4826441010 R09: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.647888] R10: 00007f4827349010 R11: 000=
0000000000246 R12: 0000562b503bf004<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.649210] R13: 0000000000000002 R14: 000=
0000000001000 R15: 000000000b275800<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.650518] Modules linked in: ip6t_rpfilt=
er ip6t_REJECT<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack i=
p6table_nat<br>
&gt; &gt; &gt; &gt; ip6table_mangle ip6table_raw ip6table_security iptable_=
nat nf_nat<br>
&gt; &gt; &gt; &gt; iptable_mangle iptable_raw iptable_security nf_conntrac=
k<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlin=
k<br>
&gt; &gt; &gt; &gt; ip6table_filter ip6_tables iptable_filter ip_tables crc=
t10dif_pclmul<br>
&gt; &gt; &gt; &gt; crc32_pclmul ghash_clmulni_intel virtio_balloon virtio_=
net<br>
&gt; &gt; &gt; &gt; net_failover intel_agp intel_gtt failover qxl drm_kms_h=
elper<br>
&gt; &gt; &gt; &gt; syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm c=
rc32c_intel<br>
&gt; &gt; &gt; &gt; serio_raw virtio_console virtio_blk agpgart qemu_fw_cfg=
<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.659276] ---[ end trace cfa4596e3813768=
8 ]---<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.660398] RIP: 0010:__list_add_valid+0x3=
/0x40<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.661493] Code: f4 ff ff ff e9 3a ff ff =
ff 49 c7 07 00 00 00 00<br>
&gt; &gt; &gt; &gt; 41 c7 47 08 00 00 00 00 e9 66 ff ff ff e8 15 f6 b6 ff 9=
0 90 90 90 90<br>
&gt; &gt; &gt; &gt; 49 89 d0 &lt;48&gt; 8b 52 08 48 39 f2 0f 85 7c 00 00 00=
 4c 8b 0a 4d 39 c1 0f<br>
&gt; &gt; &gt; &gt; 85 98<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.664800] RSP: 0000:ffffa073802cfdf8 EFL=
AGS: 00010206<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.666779] RAX: 00000000000003c0 RBX: fff=
f8d69ad052000 RCX: 8888888888888889<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.669830] RDX: 0000000000000000 RSI: fff=
fc0737f6012e8 RDI: ffff8d69ad052000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.672878] RBP: ffffc0737f6012e8 R08: 000=
0000000000000 R09: 0000000000000001<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.675920] R10: 0000000000000001 R11: 000=
0000000000000 R12: 0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.678966] R13: ffff8d69bd0dfc00 R14: fff=
f8d69bd0dfc08 R15: ffff8d69ad052010<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.682014] FS:=C2=A0 00007f48316b7740(000=
0) GS:ffff8d69be800000(0000)<br>
&gt; &gt; &gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.685399] CS:=C2=A0 0010 DS: 0000 ES: 00=
00 CR0: 0000000080050033<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.687991] CR2: 00007fbcae5049b0 CR3: 000=
00000352fe002 CR4: 0000000000160ee0<br>
&gt; &gt; &gt; &gt; [=C2=A0 =C2=A022.691068] ------------[ cut here ]------=
------<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *__list_add_valid+0x3<br>
&gt; &gt; &gt; &gt; 0xffffffff81551b43 is in __list_add_valid<br>
&gt; &gt; &gt; &gt; (/srv/s_maage/pkg/linux/linux/lib/list_debug.c:23).<br>
&gt; &gt; &gt; &gt; 18 */<br>
&gt; &gt; &gt; &gt; 19<br>
&gt; &gt; &gt; &gt; 20 bool __list_add_valid(struct list_head *new, struct =
list_head *prev,<br>
&gt; &gt; &gt; &gt; 21=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *next)<br=
>
&gt; &gt; &gt; &gt; 22 {<br>
&gt; &gt; &gt; &gt; 23 if (CHECK_DATA_CORRUPTION(next-&gt;prev !=3D prev,<b=
r>
&gt; &gt; &gt; &gt; 24 &quot;list_add corruption. next-&gt;prev should be p=
rev (%px), but was %px.<br>
&gt; &gt; &gt; &gt; (next=3D%px).\n&quot;,<br>
&gt; &gt; &gt; &gt; 25 prev, next-&gt;prev, next) ||<br>
&gt; &gt; &gt; &gt; 26=C2=A0 =C2=A0 =C2=A0CHECK_DATA_CORRUPTION(prev-&gt;ne=
xt !=3D next,<br>
&gt; &gt; &gt; &gt; 27 &quot;list_add corruption. prev-&gt;next should be n=
ext (%px), but was %px.<br>
&gt; &gt; &gt; &gt; (prev=3D%px).\n&quot;,<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *do_compact_page+0x31e<br>
&gt; &gt; &gt; &gt; 0xffffffff813396fe is in do_compact_page<br>
&gt; &gt; &gt; &gt; (/srv/s_maage/pkg/linux/linux/include/linux/list.h:60).=
<br>
&gt; &gt; &gt; &gt; 55 */<br>
&gt; &gt; &gt; &gt; 56 static inline void __list_add(struct list_head *new,=
<br>
&gt; &gt; &gt; &gt; 57=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *prev,<br=
>
&gt; &gt; &gt; &gt; 58=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *next)<br=
>
&gt; &gt; &gt; &gt; 59 {<br>
&gt; &gt; &gt; &gt; 60 if (!__list_add_valid(new, prev, next))<br>
&gt; &gt; &gt; &gt; 61 return;<br>
&gt; &gt; &gt; &gt; 62<br>
&gt; &gt; &gt; &gt; 63 next-&gt;prev =3D new;<br>
&gt; &gt; &gt; &gt; 64 new-&gt;next =3D next;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *z3fold_zpool_shrink+0x25f<br>
&gt; &gt; &gt; &gt; 0xffffffff8133854f is in z3fold_zpool_shrink<br>
&gt; &gt; &gt; &gt; (/srv/s_maage/pkg/linux/linux/arch/x86/include/asm/atom=
ic64_64.h:102).<br>
&gt; &gt; &gt; &gt; 97 *<br>
&gt; &gt; &gt; &gt; 98 * Atomically decrements @v by 1.<br>
&gt; &gt; &gt; &gt; 99 */<br>
&gt; &gt; &gt; &gt; 100 static __always_inline void arch_atomic64_dec(atomi=
c64_t *v)<br>
&gt; &gt; &gt; &gt; 101 {<br>
&gt; &gt; &gt; &gt; 102 asm volatile(LOCK_PREFIX &quot;decq %0&quot;<br>
&gt; &gt; &gt; &gt; 103=C2=A0 =C2=A0 =C2=A0 : &quot;=3Dm&quot; (v-&gt;count=
er)<br>
&gt; &gt; &gt; &gt; 104=C2=A0 =C2=A0 =C2=A0 : &quot;m&quot; (v-&gt;counter)=
 : &quot;memory&quot;);<br>
&gt; &gt; &gt; &gt; 105 }<br>
&gt; &gt; &gt; &gt; 106 #define arch_atomic64_dec arch_atomic64_dec<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (gdb) l *zswap_frontswap_store+0x424<br>
&gt; &gt; &gt; &gt; 0xffffffff812e8c74 is in zswap_frontswap_store<br>
&gt; &gt; &gt; &gt; (/srv/s_maage/pkg/linux/linux/mm/zswap.c:955).<br>
&gt; &gt; &gt; &gt; 950<br>
&gt; &gt; &gt; &gt; 951 pool =3D zswap_pool_last_get();<br>
&gt; &gt; &gt; &gt; 952 if (!pool)<br>
&gt; &gt; &gt; &gt; 953 return -ENOENT;<br>
&gt; &gt; &gt; &gt; 954<br>
&gt; &gt; &gt; &gt; 955 ret =3D zpool_shrink(pool-&gt;zpool, 1, NULL);<br>
&gt; &gt; &gt; &gt; 956<br>
&gt; &gt; &gt; &gt; 957 zswap_pool_put(pool);<br>
&gt; &gt; &gt; &gt; 958<br>
&gt; &gt; &gt; &gt; 959 return ret;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [7.] A small shell script or example program which trig=
gers the<br>
&gt; &gt; &gt; &gt; problem (if possible)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; for tmout in 10 10 10 20 20 20 30 120 $((3600/2)) 10; d=
o<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0stress --vm $(($(nproc)+2)) --vm-byt=
es $(($(awk<br>
&gt; &gt; &gt; &gt; &#39;&quot;&#39;&quot;&#39;/MemAvail/{print $2}&#39;&qu=
ot;&#39;&quot;&#39; /proc/meminfo)*1024/$(nproc)))<br>
&gt; &gt; &gt; &gt; --timeout &#39;&quot;$tmout&quot;<br>
&gt; &gt; &gt; &gt; done<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.] Environment<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; My test machine is Fedora 30 (minimal install) virtual =
machine running<br>
&gt; &gt; &gt; &gt; 4 vCPU and 1GiB RAM and 2GiB swap. Origninally I notice=
d the problem<br>
&gt; &gt; &gt; &gt; in other machines (Fedora 30). I guess any amount of me=
mory pressure<br>
&gt; &gt; &gt; &gt; and zswap activation can cause problems.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Test machine does only have whatever comes from install=
 and whatever<br>
&gt; &gt; &gt; &gt; is enabled by default. Then I&#39;ve also enabled seria=
l console<br>
&gt; &gt; &gt; &gt; &quot;console=3Dtty0 console=3DttyS0&quot;. Enabled pas=
swordless sudo to help<br>
&gt; &gt; &gt; &gt; testing and then installed &quot;stress.&quot;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; stress package version is stress-1.0.4-22.fc30<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.1.] Software (add the output of the ver_linux script=
 here)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ ./ver_linux<br>
&gt; &gt; &gt; &gt; If some fields are empty or look unusual you may have a=
n old version.<br>
&gt; &gt; &gt; &gt; Compare to the current minimal requirements in Document=
ation/Changes.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Linux localhost.localdomain 5.3.0-rc4 #69 SMP Fri Aug 1=
6 19:52:23 EEST<br>
&gt; &gt; &gt; &gt; 2019 x86_64 x86_64 x86_64 GNU/Linux<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Util-linux=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2.33.2<br>
&gt; &gt; &gt; &gt; Mount=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 2.33.2<br>
&gt; &gt; &gt; &gt; Module-init-tools=C2=A0 =C2=A0 25<br>
&gt; &gt; &gt; &gt; E2fsprogs=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.44=
.6<br>
&gt; &gt; &gt; &gt; Linux C Library=C2=A0 =C2=A0 =C2=A0 2.29<br>
&gt; &gt; &gt; &gt; Dynamic linker (ldd) 2.29<br>
&gt; &gt; &gt; &gt; Linux C++ Library=C2=A0 =C2=A0 6.0.26<br>
&gt; &gt; &gt; &gt; Procps=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
3.3.15<br>
&gt; &gt; &gt; &gt; Kbd=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 2.0.4<br>
&gt; &gt; &gt; &gt; Console-tools=C2=A0 =C2=A0 =C2=A0 =C2=A0 2.0.4<br>
&gt; &gt; &gt; &gt; Sh-utils=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 8.31<=
br>
&gt; &gt; &gt; &gt; Udev=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 241<br>
&gt; &gt; &gt; &gt; Modules Loaded=C2=A0 =C2=A0 =C2=A0 agpgart crc32c_intel=
 crc32_pclmul crct10dif_pclmul<br>
&gt; &gt; &gt; &gt; drm drm_kms_helper failover fb_sys_fops ghash_clmulni_i=
ntel intel_agp<br>
&gt; &gt; &gt; &gt; intel_gtt ip6table_filter ip6table_mangle ip6table_nat =
ip6table_raw<br>
&gt; &gt; &gt; &gt; ip6_tables ip6table_security ip6t_REJECT ip6t_rpfilter =
ip_set<br>
&gt; &gt; &gt; &gt; iptable_filter iptable_mangle iptable_nat iptable_raw i=
p_tables<br>
&gt; &gt; &gt; &gt; iptable_security ipt_REJECT libcrc32c net_failover nf_c=
onntrack<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv4 nf_defrag_ipv6 nf_nat nfnetlink nf_rejec=
t_ipv4<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 qemu_fw_cfg qxl serio_raw syscopyarea sy=
sfillrect<br>
&gt; &gt; &gt; &gt; sysimgblt ttm virtio_balloon virtio_blk virtio_console =
virtio_net<br>
&gt; &gt; &gt; &gt; xt_conntrack<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.2.] Processor information (from /proc/cpuinfo):<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/cpuinfo<br>
&gt; &gt; &gt; &gt; processor : 0<br>
&gt; &gt; &gt; &gt; vendor_id : GenuineIntel<br>
&gt; &gt; &gt; &gt; cpu family : 6<br>
&gt; &gt; &gt; &gt; model : 60<br>
&gt; &gt; &gt; &gt; model name : Intel Core Processor (Haswell, no TSX, IBR=
S)<br>
&gt; &gt; &gt; &gt; stepping : 1<br>
&gt; &gt; &gt; &gt; microcode : 0x1<br>
&gt; &gt; &gt; &gt; cpu MHz : 3198.099<br>
&gt; &gt; &gt; &gt; cache size : 16384 KB<br>
&gt; &gt; &gt; &gt; physical id : 0<br>
&gt; &gt; &gt; &gt; siblings : 1<br>
&gt; &gt; &gt; &gt; core id : 0<br>
&gt; &gt; &gt; &gt; cpu cores : 1<br>
&gt; &gt; &gt; &gt; apicid : 0<br>
&gt; &gt; &gt; &gt; initial apicid : 0<br>
&gt; &gt; &gt; &gt; fpu : yes<br>
&gt; &gt; &gt; &gt; fpu_exception : yes<br>
&gt; &gt; &gt; &gt; cpuid level : 13<br>
&gt; &gt; &gt; &gt; wp : yes<br>
&gt; &gt; &gt; &gt; flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtr=
r pge mca cmov<br>
&gt; &gt; &gt; &gt; pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1=
gb rdtscp lm<br>
&gt; &gt; &gt; &gt; constant_tsc rep_good nopl xtopology cpuid pni pclmulqd=
q vmx ssse3 fma<br>
&gt; &gt; &gt; &gt; cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadlin=
e_timer aes<br>
&gt; &gt; &gt; &gt; xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_faul=
t<br>
&gt; &gt; &gt; &gt; invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexp=
riority ept<br>
&gt; &gt; &gt; &gt; vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erm=
s invpcid<br>
&gt; &gt; &gt; &gt; xsaveopt arat umip md_clear<br>
&gt; &gt; &gt; &gt; bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_by=
pass l1tf mds swapgs<br>
&gt; &gt; &gt; &gt; bogomips : 6396.19<br>
&gt; &gt; &gt; &gt; clflush size : 64<br>
&gt; &gt; &gt; &gt; cache_alignment : 64<br>
&gt; &gt; &gt; &gt; address sizes : 40 bits physical, 48 bits virtual<br>
&gt; &gt; &gt; &gt; power management:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; processor : 1<br>
&gt; &gt; &gt; &gt; vendor_id : GenuineIntel<br>
&gt; &gt; &gt; &gt; cpu family : 6<br>
&gt; &gt; &gt; &gt; model : 60<br>
&gt; &gt; &gt; &gt; model name : Intel Core Processor (Haswell, no TSX, IBR=
S)<br>
&gt; &gt; &gt; &gt; stepping : 1<br>
&gt; &gt; &gt; &gt; microcode : 0x1<br>
&gt; &gt; &gt; &gt; cpu MHz : 3198.099<br>
&gt; &gt; &gt; &gt; cache size : 16384 KB<br>
&gt; &gt; &gt; &gt; physical id : 1<br>
&gt; &gt; &gt; &gt; siblings : 1<br>
&gt; &gt; &gt; &gt; core id : 0<br>
&gt; &gt; &gt; &gt; cpu cores : 1<br>
&gt; &gt; &gt; &gt; apicid : 1<br>
&gt; &gt; &gt; &gt; initial apicid : 1<br>
&gt; &gt; &gt; &gt; fpu : yes<br>
&gt; &gt; &gt; &gt; fpu_exception : yes<br>
&gt; &gt; &gt; &gt; cpuid level : 13<br>
&gt; &gt; &gt; &gt; wp : yes<br>
&gt; &gt; &gt; &gt; flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtr=
r pge mca cmov<br>
&gt; &gt; &gt; &gt; pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1=
gb rdtscp lm<br>
&gt; &gt; &gt; &gt; constant_tsc rep_good nopl xtopology cpuid pni pclmulqd=
q vmx ssse3 fma<br>
&gt; &gt; &gt; &gt; cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadlin=
e_timer aes<br>
&gt; &gt; &gt; &gt; xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_faul=
t<br>
&gt; &gt; &gt; &gt; invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexp=
riority ept<br>
&gt; &gt; &gt; &gt; vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erm=
s invpcid<br>
&gt; &gt; &gt; &gt; xsaveopt arat umip md_clear<br>
&gt; &gt; &gt; &gt; bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_by=
pass l1tf mds swapgs<br>
&gt; &gt; &gt; &gt; bogomips : 6468.62<br>
&gt; &gt; &gt; &gt; clflush size : 64<br>
&gt; &gt; &gt; &gt; cache_alignment : 64<br>
&gt; &gt; &gt; &gt; address sizes : 40 bits physical, 48 bits virtual<br>
&gt; &gt; &gt; &gt; power management:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; processor : 2<br>
&gt; &gt; &gt; &gt; vendor_id : GenuineIntel<br>
&gt; &gt; &gt; &gt; cpu family : 6<br>
&gt; &gt; &gt; &gt; model : 60<br>
&gt; &gt; &gt; &gt; model name : Intel Core Processor (Haswell, no TSX, IBR=
S)<br>
&gt; &gt; &gt; &gt; stepping : 1<br>
&gt; &gt; &gt; &gt; microcode : 0x1<br>
&gt; &gt; &gt; &gt; cpu MHz : 3198.099<br>
&gt; &gt; &gt; &gt; cache size : 16384 KB<br>
&gt; &gt; &gt; &gt; physical id : 2<br>
&gt; &gt; &gt; &gt; siblings : 1<br>
&gt; &gt; &gt; &gt; core id : 0<br>
&gt; &gt; &gt; &gt; cpu cores : 1<br>
&gt; &gt; &gt; &gt; apicid : 2<br>
&gt; &gt; &gt; &gt; initial apicid : 2<br>
&gt; &gt; &gt; &gt; fpu : yes<br>
&gt; &gt; &gt; &gt; fpu_exception : yes<br>
&gt; &gt; &gt; &gt; cpuid level : 13<br>
&gt; &gt; &gt; &gt; wp : yes<br>
&gt; &gt; &gt; &gt; flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtr=
r pge mca cmov<br>
&gt; &gt; &gt; &gt; pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1=
gb rdtscp lm<br>
&gt; &gt; &gt; &gt; constant_tsc rep_good nopl xtopology cpuid pni pclmulqd=
q vmx ssse3 fma<br>
&gt; &gt; &gt; &gt; cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadlin=
e_timer aes<br>
&gt; &gt; &gt; &gt; xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_faul=
t<br>
&gt; &gt; &gt; &gt; invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexp=
riority ept<br>
&gt; &gt; &gt; &gt; vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erm=
s invpcid<br>
&gt; &gt; &gt; &gt; xsaveopt arat umip md_clear<br>
&gt; &gt; &gt; &gt; bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_by=
pass l1tf mds swapgs<br>
&gt; &gt; &gt; &gt; bogomips : 6627.92<br>
&gt; &gt; &gt; &gt; clflush size : 64<br>
&gt; &gt; &gt; &gt; cache_alignment : 64<br>
&gt; &gt; &gt; &gt; address sizes : 40 bits physical, 48 bits virtual<br>
&gt; &gt; &gt; &gt; power management:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; processor : 3<br>
&gt; &gt; &gt; &gt; vendor_id : GenuineIntel<br>
&gt; &gt; &gt; &gt; cpu family : 6<br>
&gt; &gt; &gt; &gt; model : 60<br>
&gt; &gt; &gt; &gt; model name : Intel Core Processor (Haswell, no TSX, IBR=
S)<br>
&gt; &gt; &gt; &gt; stepping : 1<br>
&gt; &gt; &gt; &gt; microcode : 0x1<br>
&gt; &gt; &gt; &gt; cpu MHz : 3198.099<br>
&gt; &gt; &gt; &gt; cache size : 16384 KB<br>
&gt; &gt; &gt; &gt; physical id : 3<br>
&gt; &gt; &gt; &gt; siblings : 1<br>
&gt; &gt; &gt; &gt; core id : 0<br>
&gt; &gt; &gt; &gt; cpu cores : 1<br>
&gt; &gt; &gt; &gt; apicid : 3<br>
&gt; &gt; &gt; &gt; initial apicid : 3<br>
&gt; &gt; &gt; &gt; fpu : yes<br>
&gt; &gt; &gt; &gt; fpu_exception : yes<br>
&gt; &gt; &gt; &gt; cpuid level : 13<br>
&gt; &gt; &gt; &gt; wp : yes<br>
&gt; &gt; &gt; &gt; flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtr=
r pge mca cmov<br>
&gt; &gt; &gt; &gt; pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1=
gb rdtscp lm<br>
&gt; &gt; &gt; &gt; constant_tsc rep_good nopl xtopology cpuid pni pclmulqd=
q vmx ssse3 fma<br>
&gt; &gt; &gt; &gt; cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadlin=
e_timer aes<br>
&gt; &gt; &gt; &gt; xsave avx f16c rdrand hypervisor lahf_lm abm cpuid_faul=
t<br>
&gt; &gt; &gt; &gt; invpcid_single pti ssbd ibrs ibpb tpr_shadow vnmi flexp=
riority ept<br>
&gt; &gt; &gt; &gt; vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erm=
s invpcid<br>
&gt; &gt; &gt; &gt; xsaveopt arat umip md_clear<br>
&gt; &gt; &gt; &gt; bugs : cpu_meltdown spectre_v1 spectre_v2 spec_store_by=
pass l1tf mds swapgs<br>
&gt; &gt; &gt; &gt; bogomips : 6662.16<br>
&gt; &gt; &gt; &gt; clflush size : 64<br>
&gt; &gt; &gt; &gt; cache_alignment : 64<br>
&gt; &gt; &gt; &gt; address sizes : 40 bits physical, 48 bits virtual<br>
&gt; &gt; &gt; &gt; power management:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.3.] Module information (from /proc/modules):<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/modules<br>
&gt; &gt; &gt; &gt; ip6t_rpfilter 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6t_REJECT 16384 2 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; nf_reject_ipv6 20480 1 ip6t_REJECT, Live 0x000000000000=
0000<br>
&gt; &gt; &gt; &gt; ipt_REJECT 16384 2 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; nf_reject_ipv4 16384 1 ipt_REJECT, Live 0x0000000000000=
000<br>
&gt; &gt; &gt; &gt; xt_conntrack 16384 13 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6table_nat 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6table_mangle 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6table_raw 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6table_security 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; iptable_nat 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; nf_nat 126976 2 ip6table_nat,iptable_nat, Live 0x000000=
0000000000<br>
&gt; &gt; &gt; &gt; iptable_mangle 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; iptable_raw 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; iptable_security 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; nf_conntrack 241664 2 xt_conntrack,nf_nat, Live 0x00000=
00000000000<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv6 24576 1 nf_conntrack, Live 0x00000000000=
00000<br>
&gt; &gt; &gt; &gt; nf_defrag_ipv4 16384 1 nf_conntrack, Live 0x00000000000=
00000<br>
&gt; &gt; &gt; &gt; libcrc32c 16384 2 nf_nat,nf_conntrack, Live 0x000000000=
0000000<br>
&gt; &gt; &gt; &gt; ip_set 69632 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; nfnetlink 20480 1 ip_set, Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6table_filter 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip6_tables 36864 7<br>
&gt; &gt; &gt; &gt; ip6table_nat,ip6table_mangle,ip6table_raw,ip6table_secu=
rity,ip6table_filter,<br>
&gt; &gt; &gt; &gt; Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; iptable_filter 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ip_tables 32768 5<br>
&gt; &gt; &gt; &gt; iptable_nat,iptable_mangle,iptable_raw,iptable_security=
,iptable_filter,<br>
&gt; &gt; &gt; &gt; Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; crct10dif_pclmul 16384 1 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; crc32_pclmul 16384 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; ghash_clmulni_intel 16384 0 - Live 0x0000000000000000<b=
r>
&gt; &gt; &gt; &gt; virtio_net 61440 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; virtio_balloon 24576 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; net_failover 24576 1 virtio_net, Live 0x000000000000000=
0<br>
&gt; &gt; &gt; &gt; failover 16384 1 net_failover, Live 0x0000000000000000<=
br>
&gt; &gt; &gt; &gt; intel_agp 24576 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; intel_gtt 24576 1 intel_agp, Live 0x0000000000000000<br=
>
&gt; &gt; &gt; &gt; qxl 77824 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; drm_kms_helper 221184 3 qxl, Live 0x0000000000000000<br=
>
&gt; &gt; &gt; &gt; syscopyarea 16384 1 drm_kms_helper, Live 0x000000000000=
0000<br>
&gt; &gt; &gt; &gt; sysfillrect 16384 1 drm_kms_helper, Live 0x000000000000=
0000<br>
&gt; &gt; &gt; &gt; sysimgblt 16384 1 drm_kms_helper, Live 0x00000000000000=
00<br>
&gt; &gt; &gt; &gt; fb_sys_fops 16384 1 drm_kms_helper, Live 0x000000000000=
0000<br>
&gt; &gt; &gt; &gt; ttm 126976 1 qxl, Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; drm 602112 4 qxl,drm_kms_helper,ttm, Live 0x00000000000=
00000<br>
&gt; &gt; &gt; &gt; crc32c_intel 24576 5 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; serio_raw 20480 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; virtio_blk 20480 3 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; virtio_console 45056 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; qemu_fw_cfg 20480 0 - Live 0x0000000000000000<br>
&gt; &gt; &gt; &gt; agpgart 53248 4 intel_agp,intel_gtt,ttm,drm, Live 0x000=
0000000000000<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.4.] Loaded driver and hardware information (/proc/io=
ports, /proc/iomem)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/ioports<br>
&gt; &gt; &gt; &gt; 0000-0000 : PCI Bus 0000:00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : dma1<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : pic1<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : timer0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : timer1<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : keyboard<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : keyboard<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : rtc0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : dma page reg<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : pic2<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : dma2<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : fpu<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : vga+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : serial<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : QEMU0002:00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : fw_cfg_io<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : 0000:00:1f.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : ACPI PM1a_EVT_BLK<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : ACPI PM1a_CNT_BLK<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : ACPI PM_TMR<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : ACPI GPE0_BLK<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : 0000:00:1f.3<br>
&gt; &gt; &gt; &gt; 0000-0000 : PCI conf1<br>
&gt; &gt; &gt; &gt; 0000-0000 : PCI Bus 0000:00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:01<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:02<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:03<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:04<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:05<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:06<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : PCI Bus 0000:07<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : 0000:00:01.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A00000-0000 : 0000:00:1f.2<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A00000-0000 : ahci<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/iomem<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : System RAM<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : PCI Bus 0000:00<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Video ROM<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Adapter ROM<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Adapter ROM<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : System ROM<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : System RAM<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : Kernel code<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : Kernel data<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : Kernel bss<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : PCI MMCONFIG 0000 [bus 00-ff]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : PCI Bus 0000:00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:01.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:01.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:07<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:06<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:05<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:04<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:04:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:03<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:03:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:02<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:02:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : xhci-hcd<=
br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:01<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:01:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:01:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:1b.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:01.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.1<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.2<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.3<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.4<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.5<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:02.6<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : 0000:00:1f.2<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : ahci<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:07<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:06<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:06:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : virtio-pc=
i-modern<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:05<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:05:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : virtio-pc=
i-modern<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:04<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:04:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : virtio-pc=
i-modern<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:03<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:03:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : virtio-pc=
i-modern<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:02<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A000000000-00000000 : PCI Bus 0000:01<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A000000000-00000000 : 0000:01:00.0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A000000000-00000000 : virtio-pc=
i-modern<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : IOAPIC 0<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Local APIC<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : Reserved<br>
&gt; &gt; &gt; &gt; 00000000-00000000 : PCI Bus 0000:00<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.5.] PCI information (&#39;lspci -vvv&#39; as root)<b=
r>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Attached as: lspci-vvv-5.3.0-rc4.txt<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.6.] SCSI information (from /proc/scsi/scsi)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat //proc/scsi/scsi<br>
&gt; &gt; &gt; &gt; Attached devices:<br>
&gt; &gt; &gt; &gt; Host: scsi0 Channel: 00 Id: 00 Lun: 00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0Vendor: QEMU=C2=A0 =C2=A0 =C2=A0Model: QEMU=
 DVD-ROM=C2=A0 =C2=A0 =C2=A0Rev: 2.5+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0Type:=C2=A0 =C2=A0CD-ROM=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0ANSI=C2=A0 SCSI revision: 05<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [8.7.] Other information that might be relevant to the =
problem<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; During testing it looks like this:<br>
&gt; &gt; &gt; &gt; $ egrep -r ^ /sys/module/zswap/parameters<br>
&gt; &gt; &gt; &gt; /sys/module/zswap/parameters/same_filled_pages_enabled:=
Y<br>
&gt; &gt; &gt; &gt; /sys/module/zswap/parameters/enabled:Y<br>
&gt; &gt; &gt; &gt; /sys/module/zswap/parameters/max_pool_percent:20<br>
&gt; &gt; &gt; &gt; /sys/module/zswap/parameters/compressor:lzo<br>
&gt; &gt; &gt; &gt; /sys/module/zswap/parameters/zpool:z3fold<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; $ cat /proc/meminfo<br>
&gt; &gt; &gt; &gt; MemTotal:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0983056 kB<br=
>
&gt; &gt; &gt; &gt; MemFree:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 377876 kB<br=
>
&gt; &gt; &gt; &gt; MemAvailable:=C2=A0 =C2=A0 =C2=A0660820 kB<br>
&gt; &gt; &gt; &gt; Buffers:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A014896 =
kB<br>
&gt; &gt; &gt; &gt; Cached:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0368028 =
kB<br>
&gt; &gt; &gt; &gt; SwapCached:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =
kB<br>
&gt; &gt; &gt; &gt; Active:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0247500 =
kB<br>
&gt; &gt; &gt; &gt; Inactive:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0193120 kB<br=
>
&gt; &gt; &gt; &gt; Active(anon):=C2=A0 =C2=A0 =C2=A0 58016 kB<br>
&gt; &gt; &gt; &gt; Inactive(anon):=C2=A0 =C2=A0 =C2=A0 280 kB<br>
&gt; &gt; &gt; &gt; Active(file):=C2=A0 =C2=A0 =C2=A0189484 kB<br>
&gt; &gt; &gt; &gt; Inactive(file):=C2=A0 =C2=A0192840 kB<br>
&gt; &gt; &gt; &gt; Unevictable:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
kB<br>
&gt; &gt; &gt; &gt; Mlocked:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 kB<br>
&gt; &gt; &gt; &gt; SwapTotal:=C2=A0 =C2=A0 =C2=A0 =C2=A04194300 kB<br>
&gt; &gt; &gt; &gt; SwapFree:=C2=A0 =C2=A0 =C2=A0 =C2=A0 4194300 kB<br>
&gt; &gt; &gt; &gt; Dirty:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A08 kB<br>
&gt; &gt; &gt; &gt; Writeback:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 kB<br>
&gt; &gt; &gt; &gt; AnonPages:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A057712 kB<br=
>
&gt; &gt; &gt; &gt; Mapped:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 81984 =
kB<br>
&gt; &gt; &gt; &gt; Shmem:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0596 kB<br>
&gt; &gt; &gt; &gt; KReclaimable:=C2=A0 =C2=A0 =C2=A0 56272 kB<br>
&gt; &gt; &gt; &gt; Slab:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A012=
8128 kB<br>
&gt; &gt; &gt; &gt; SReclaimable:=C2=A0 =C2=A0 =C2=A0 56272 kB<br>
&gt; &gt; &gt; &gt; SUnreclaim:=C2=A0 =C2=A0 =C2=A0 =C2=A0 71856 kB<br>
&gt; &gt; &gt; &gt; KernelStack:=C2=A0 =C2=A0 =C2=A0 =C2=A0 2208 kB<br>
&gt; &gt; &gt; &gt; PageTables:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01632 kB<br=
>
&gt; &gt; &gt; &gt; NFS_Unstable:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB<br=
>
&gt; &gt; &gt; &gt; Bounce:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 0 kB<br>
&gt; &gt; &gt; &gt; WritebackTmp:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB<br=
>
&gt; &gt; &gt; &gt; CommitLimit:=C2=A0 =C2=A0 =C2=A04685828 kB<br>
&gt; &gt; &gt; &gt; Committed_AS:=C2=A0 =C2=A0 =C2=A0268512 kB<br>
&gt; &gt; &gt; &gt; VmallocTotal:=C2=A0 =C2=A034359738367 kB<br>
&gt; &gt; &gt; &gt; VmallocUsed:=C2=A0 =C2=A0 =C2=A0 =C2=A0 9764 kB<br>
&gt; &gt; &gt; &gt; VmallocChunk:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB<br=
>
&gt; &gt; &gt; &gt; Percpu:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
9312 kB<br>
&gt; &gt; &gt; &gt; HardwareCorrupted:=C2=A0 =C2=A0 =C2=A00 kB<br>
&gt; &gt; &gt; &gt; AnonHugePages:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB<br=
>
&gt; &gt; &gt; &gt; ShmemHugePages:=C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB<br>
&gt; &gt; &gt; &gt; ShmemPmdMapped:=C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB<br>
&gt; &gt; &gt; &gt; CmaTotal:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 0 kB<br>
&gt; &gt; &gt; &gt; CmaFree:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 kB<br>
&gt; &gt; &gt; &gt; HugePages_Total:=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
&gt; &gt; &gt; &gt; HugePages_Free:=C2=A0 =C2=A0 =C2=A0 =C2=A0 0<br>
&gt; &gt; &gt; &gt; HugePages_Rsvd:=C2=A0 =C2=A0 =C2=A0 =C2=A0 0<br>
&gt; &gt; &gt; &gt; HugePages_Surp:=C2=A0 =C2=A0 =C2=A0 =C2=A0 0<br>
&gt; &gt; &gt; &gt; Hugepagesize:=C2=A0 =C2=A0 =C2=A0 =C2=A02048 kB<br>
&gt; &gt; &gt; &gt; Hugetlb:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 kB<br>
&gt; &gt; &gt; &gt; DirectMap4k:=C2=A0 =C2=A0 =C2=A0 110452 kB<br>
&gt; &gt; &gt; &gt; DirectMap2M:=C2=A0 =C2=A0 =C2=A0 937984 kB<br>
&gt; &gt; &gt; &gt; DirectMap1G:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
kB<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; [9.] Other notes<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; My workaround is to disable zswap:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; sudo bash -c &#39;echo 0 &gt; /sys/module/zswap/paramet=
ers/enabled&#39;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Sometimes stress can die just because it is out of memo=
ry. Also some<br>
&gt; &gt; &gt; &gt; other programs might die because of page allocation fai=
lures etc. But<br>
&gt; &gt; &gt; &gt; that is not relevant here.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Generally stress command is actually like:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; stress --vm 6 --vm-bytes 228608000 --timeout 10<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; It seems to be essential to start and stop stress runs.=
 Sometimes<br>
&gt; &gt; &gt; &gt; problem does not trigger until much later. To be sure t=
here is no<br>
&gt; &gt; &gt; &gt; problems I&#39;d suggest running stress at least an hou=
r (--timeout 3600)<br>
&gt; &gt; &gt; &gt; and also couple of hundred times with short timeout. I&=
#39;ve used 90<br>
&gt; &gt; &gt; &gt; minutes as mark of &quot;good&quot; run during bisect (=
start of). I&#39;m not sure<br>
&gt; &gt; &gt; &gt; if this is only one issue here.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I reboot machine with kernel under test. Run uname -r a=
nd collect boot<br>
&gt; &gt; &gt; &gt; logs using ssh. And then ssh in with test script. No ot=
her commands<br>
&gt; &gt; &gt; &gt; are run.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Some timestamps of errors to give idea how log to wait =
for test to<br>
&gt; &gt; &gt; &gt; give results. Testing starts when machine has been up a=
bout 8 or 9<br>
&gt; &gt; &gt; &gt; seconds.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 =C2=A013.805105] general protection fault=
: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 =C2=A014.059768] general protection fault=
: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 =C2=A014.324867] general protection fault=
: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 =C2=A014.458709] general protection fault=
: 0000 [#1] SMP PTI<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 =C2=A041.818966] BUG: unable to handle pa=
ge fault for address: fffff54cf8000028<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 105.710330] BUG: unable to handle page fa=
ult for address: ffffd2df8a000028<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 135.390332] BUG: unable to handle page fa=
ult for address: ffffe5a34a000028<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 166.793041] BUG: unable to handle page fa=
ult for address: ffffd1be6f000028<br>
&gt; &gt; &gt; &gt;=C2=A0 [=C2=A0 311.602285] BUG: unable to handle page fa=
ult for address: fffff7f409000028<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P3=
1 Express DRAM Controller<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Subsystem: Red Hat, Inc. QEMU=
 Virtual Machine<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Control: I/O+ Mem+ BusMaster-=
 SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-<br=
>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Status: Cap- 66MHz- UDF- Fast=
B2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &l=
t;PERR- INTx-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel modules: intel_agp<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 00:01.0 VGA compatible controller: Red Hat, Inc. QXL pa=
ravirtual graphic card (rev 04) (prog-if 00 [VGA controller])<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Subsystem: Red Hat, Inc. QEMU=
 Virtual Machine<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Control: I/O+ Mem+ BusMaster-=
 SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-<br=
>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Status: Cap- 66MHz- UDF- Fast=
B2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &l=
t;PERR- INTx-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Interrupt: pin A routed to IR=
Q 21<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Region 0: Memory at f4000000 =
(32-bit, non-prefetchable) [size=3D64M]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Region 1: Memory at f8000000 =
(32-bit, non-prefetchable) [size=3D64M]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Region 2: Memory at fce14000 =
(32-bit, non-prefetchable) [size=3D8K]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Region 3: I/O ports at c040 [=
size=3D32]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Expansion ROM at 000c0000 [di=
sabled] [size=3D128K]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel driver in use: qxl<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel modules: qxl<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 00:02.0 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (=
prog-if 00 [Normal decode])<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Control: I/O+ Mem+ BusMaster+=
 SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+<br=
>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Status: Cap+ 66MHz- UDF- Fast=
B2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &l=
t;PERR- INTx-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Latency: 0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Interrupt: pin A routed to IR=
Q 22<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Region 0: Memory at fce16000 =
(32-bit, non-prefetchable) [size=3D4K]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Bus: primary=3D00, secondary=
=3D01, subordinate=3D01, sec-latency=3D0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0I/O behind bridge: 00001000-0=
0001fff [size=3D4K]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Memory behind bridge: fcc0000=
0-fcdfffff [size=3D2M]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Prefetchable memory behind br=
idge: 00000000fea00000-00000000febfffff [size=3D2M]<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Secondary status: 66MHz- Fast=
B2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &lt;SERR- &l=
t;PERR-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0BridgeCtl: Parity- SERR+ NoIS=
A- VGA- VGA16- MAbort- &gt;Reset- FastB2B-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0P=
riDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [54] Express (v=
2) Root Port (Slot+), MSI 00<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
evCap: MaxPayload 128 bytes, PhantFunc 0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0ExtTag- RBE+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
evCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0MaxPayload 128 bytes, MaxReadReq 128 bytes<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
evSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPwr- TransPend-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L=
nkCap: Port #16, Speed 2.5GT/s, Width x1, ASPM L0s, Exit Latency L0s &lt;64=
ns<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-=
<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L=
nkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-<b=
r>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L=
nkSta: Speed 2.5GT/s (ok), Width x1 (ok)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0TrErr- Train- SlotClk- DLActive+ BWMgmt- ABWMgmt=
-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0S=
ltCap: AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0Slot #0, PowerLimit 0.000W; Interlock+ NoCompl-<=
br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0S=
ltCtl: Enable: AttnBtn+ PwrFlt- MRL- PresDet- CmdCplt+ HPIrq+ LinkChg-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0Control: AttnInd Off, PwrInd On, Power- Interloc=
k-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0S=
ltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0Changed: MRL- PresDet- LinkState-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0R=
ootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0R=
ootCap: CRSVisible-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0R=
ootSta: PME ReqID 0000, PMEStatus- PMEPending-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
evCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supp=
orted ARIFwd+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS-=
<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
evCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled =
ARIFwd-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 AtomicOpsCtl: ReqEn- EgressBlck-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L=
nkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Transmit Margin: Normal Operating Range, EnterM=
odifiedCompliance- ComplianceSOS-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Compliance De-emphasis: -6dB<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L=
nkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, Equalizatio=
nPhase1-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 EqualizationPhase2-, EqualizationPhase3-, LinkE=
qualizationRequest-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [48] MSI-X: Ena=
ble+ Count=3D1 Masked-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0V=
ector table: BAR=3D0 offset=3D00000000<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0P=
BA: BAR=3D0 offset=3D00000800<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [40] Subsystem:=
 Red Hat, Inc. Device 0000<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Capabilities: [100 v2] Advanc=
ed Error Reporting<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0U=
ESta:=C2=A0 DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTL=
P- ECRC- UnsupReq- ACSViol-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0U=
EMsk:=C2=A0 DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTL=
P- ECRC- UnsupReq- ACSViol-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0U=
ESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ EC=
RC- UnsupReq- ACSViol-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0C=
ESta:=C2=A0 RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0C=
EMsk:=C2=A0 RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0A=
ERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn- ECRCChkCap+ ECRCChkE=
n-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0MultHdrRecCap+ MultHdrRecEn- TLPPfxPres- HdrLogC=
ap-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0H=
eaderLog: 00000000 00000000 00000000 00000000<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0R=
ootCmd: CERptEn+ NFERptEn+ FERptEn+<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0R=
ootSta: CERcvd- MultCERcvd- UERcvd- MultUERcvd-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 FirstFatal- NonFatalMsg- FatalMsg- IntMsg 0<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0E=
rrorSrc: ERR_COR: 0000 ERR_FATAL/NONFATAL: 0000<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel driver in use: pciepor=
t<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 00:02.1 PCI bridge: Red Hat, Inc. QEMU PCIe Root port (=
prog-if 00 [Normal decode])<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Control: I/O+ Mem+ BusMaster+=
 SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+<br=
>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Status: Cap+ 66MHz- UDF- Fast=
B2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &l=
t;PERR- INTx-<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0La</blockquote></div></div></=
div>

--000000000000f97b6305907b707f--

