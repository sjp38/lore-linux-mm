Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB542C0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 20:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A259208C2
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 20:30:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i+F73R7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A259208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B310E6B0005; Sun, 11 Aug 2019 16:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADE896B0006; Sun, 11 Aug 2019 16:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A71D6B0007; Sun, 11 Aug 2019 16:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id 6788E6B0005
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 16:30:58 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 056B0180AD7C3
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 20:30:58 +0000 (UTC)
X-FDA: 75811290996.05.route62_42905e3dc295b
X-HE-Tag: route62_42905e3dc295b
X-Filterd-Recvd-Size: 11326
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 20:30:57 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id r12so67164373edo.5
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 13:30:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nafEfKXbQl1+hQylZUVXeBJysaFRkExoJWJLknhPpck=;
        b=i+F73R7ALrzuE8au8cscfRSSrpu4dW5HQp/Z8Az47eX5uVGl68gXS3lz71OpHEH/6Z
         8ALaxQB0ZI4bXx5h5fifaaazsJZUkxnK/aQOyqsE9M6wFSpJdWdvfJgXBbkiF0Ku2k/9
         dTM0h/LZfjNquxBKhgq3uCXXzbx6lxAN9wvIe7W0XpAtoPD6H53lNy51QiYVLXVs7gst
         50arRsISleNFqxrXud/kavyip/7kL9ZP0NLO8fFzrcT4o4LF5WHo4pKHuarYX7Ra/6wm
         x95TD5R31iiBc25H7Xz8GQjh0/K2QhBlS7NA3uYiFMvNGgGKC/+t1cfcWzPlx1JvTkwS
         SmJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nafEfKXbQl1+hQylZUVXeBJysaFRkExoJWJLknhPpck=;
        b=WIBR09JA2Elwi4llOh3FCHK+OiC9P9XZ91sdB+aIDPyzDLGj6QHQwGj/lzeayzvP1I
         UCntDnxfhcYoxE9biwa/1hkoP7tsDFs47CWjZ3YHr5WUvUHL2336IncPxONfNsee7f0V
         fCOcOpa4/QW29Sq8ofmwo3pgJKbq2xwxOtIsoeDaoXrdnINSTCRcChkxoBht7xWt1i3/
         o6EXzSDCR/JJmOzuO8j6aGHoxFDJ7ZBzAaJMDBsn0GKXx5jvKNKc5rY9qTm2+Np7PQzh
         ZxarzwFJQTu++kFEAPEoGCVMJxHNl5XgmemtV2XEr5yMZ2UZAgoM0Li0FXTCOecLm08E
         G5MA==
X-Gm-Message-State: APjAAAWVXL5f43huA8NtJIWyYHhPDUCy8NErCHE/rksamG/NGN4vhFUX
	b7AUklGQCKcTldJfywBviOY1xcjO+2u5KseQ8F0=
X-Google-Smtp-Source: APXvYqwgw6t7E+Uv/2To2o+wLarI9bvNDuwYnQ9LJTZEq1eprTiFjGJvLtimpAuNa2l8gP80RlH+d3yxQgEpadyUh/Y=
X-Received: by 2002:a17:906:d298:: with SMTP id ay24mr6185536ejb.230.1565555455905;
 Sun, 11 Aug 2019 13:30:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org> <CADxRZqy61-JOYSv3xtdeW_wTDqKovqDg2G+a-=LH3w=mrf2zUQ@mail.gmail.com>
 <20190810071701.GA23686@lst.de> <CAM43=SNbjVJRZs7r=GqFG0ajOs5wY4pZzr_QfVZinFRWV8ioBg@mail.gmail.com>
In-Reply-To: <CAM43=SNbjVJRZs7r=GqFG0ajOs5wY4pZzr_QfVZinFRWV8ioBg@mail.gmail.com>
From: Anatoly Pugachev <matorola@gmail.com>
Date: Sun, 11 Aug 2019 23:30:46 +0300
Message-ID: <CADxRZqyiL-BqvUMJzk_7aX0gE0b2=ms6bpqk7a+ZVhnZZyq-DQ@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: Mikael Pettersson <mikpelinux@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, "Dmitry V. Levin" <ldv@altlinux.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	"David S. Miller" <davem@davemloft.net>, Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 10:36 PM Mikael Pettersson <mikpelinux@gmail.com> wrote:
> For the record the futex test case OOPSes a 5.3-rc3 kernel running on
> a Sun Blade 2500 (2 x USIIIi).  This system runs a custom distro with
> a custom toolchain (gcc-8.3 based), so I doubt it's a distro problem.

Mikael, Khalid,

can you please test util-linux source code with 'make check' on
current git kernel and post the results?
https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git

Thanks.

As with my test machine/LDOM, util-linux 'make check' hangs git kernel
with the OOPS in the end of this message.

PS: And I was able to revert patch so current kernel git master branch
works again, futex strace test works as before (not being killed and
does not produce kernel OOPS), as well util-linux 'make check' does
not kills kernel. If anyone interested I can post the patch, but I'm
not sure it's a right thing to do, if all other architectures were
converted to use generic GUP code (mm/gup.c).


[   47.600488] BUG: Bad rss-counter state mm:00000000ae46ef00 idx:0 val:-17
[   47.600645] BUG: Bad rss-counter state mm:00000000ae46ef00 idx:1 val:102
[   47.673090] fdisk[4270]: segfault at 20 ip fff8000100007ed8 (rpc
fff8000100007e30) sp 000007feffe79661 error 1 in
ld-2.28.so[fff8000100000000+22000]
[   47.674415] BUG: Bad rss-counter state mm:00000000ca65883c idx:0 val:17
[   47.674722] BUG: Bad rss-counter state mm:00000000ca65883c idx:1 val:1
[   47.785453] ------------[ cut here ]------------
[   47.785722] WARNING: CPU: 17 PID: 96 at mm/slab.h:410
kmem_cache_free+0xb4/0x300
[   47.785880] virt_to_cache: Object is not a Slab page!
[   47.786003] Modules linked in: tun ip_set_hash_net ip_set nf_tables
nfnetlink binfmt_misc camellia_sparc64 des_sparc64 des_generic
aes_sparc64 md5_sparc64 sha512_sparc64 sha256_sparc64 n2_rng rng_core
flash sha1_sparc64 ip_tables x_tables ipv6 nf_defrag_ipv6 autofs4 ext4
crc16 mbcache jbd2 raid10 raid456 async_raid6_recov async_memcpy
async_pq async_xor xor async_tx raid6_pq raid1 raid0 multipath linear
md_mod crc32c_sparc64
[   47.787041] CPU: 17 PID: 96 Comm: ksoftirqd/17 Not tainted 5.3.0-rc3 #1143
[   47.787181] Call Trace:
[   47.787268]  [0000000000464540] __warn+0xc0/0x100
[   47.787384]  [00000000004645b4] warn_slowpath_fmt+0x34/0x60
[   47.787512]  [00000000006758f4] kmem_cache_free+0xb4/0x300
[   47.787648]  [0000000000451b68] pgtable_free+0x28/0x40
[   47.787779]  [00000000006470fc] tlb_remove_table_rcu+0x3c/0x80
[   47.787928]  [00000000004fae94] rcu_core+0xbd4/0x1000
[   47.788048]  [00000000004fb7ac] rcu_core_si+0xc/0x20
[   47.788177]  [0000000000abc648] __do_softirq+0x288/0x500
[   47.788296]  [000000000046beb0] run_ksoftirqd+0x30/0x80
[   47.788433]  [0000000000493c64] smpboot_thread_fn+0x244/0x280
[   47.788575]  [000000000048ef50] kthread+0x110/0x140
[   47.788707]  [00000000004060e4] ret_from_fork+0x1c/0x2c
[   47.788835]  [0000000000000000] 0x0
[   47.788927] irq event stamp: 19420
[   47.789028] hardirqs last  enabled at (19428): [<00000000004e2910>]
console_unlock+0x630/0x6c0
[   47.789230] hardirqs last disabled at (19435): [<00000000004e23dc>]
console_unlock+0xfc/0x6c0
[   47.789420] softirqs last  enabled at (19254): [<0000000000abc854>]
__do_softirq+0x494/0x500
[   47.789612] softirqs last disabled at (19259): [<000000000046beb0>]
run_ksoftirqd+0x30/0x80
[   47.789795] ---[ end trace afb11a4826780c48 ]---
[   47.925975] Unable to handle kernel paging request at virtual
address 0006120000000000
[   47.926088] tsk->{mm,active_mm}->context = 0000000000001b68
[   47.926150] tsk->{mm,active_mm}->pgd = fff8002438f90000
[   47.926202]               \|/ ____ \|/
[   47.926202]               "@'/ .. \`@"
[   47.926202]               /_| \__/ |_\
[   47.926202]                  \__U_/
[   47.926311] kworker/25:2(653): Oops [#1]
[   47.926354] CPU: 25 PID: 653 Comm: kworker/25:2 Tainted: G        W
        5.3.0-rc3 #1143
[   47.926433] Workqueue: xfs-conv/dm-0 xfs_end_io
[   47.926479] TSTATE: 0000000080001605 TPC: 000000000067588c TNPC:
0000000000675890 Y: 00000000    Tainted: G        W
[   47.926570] TPC: <kmem_cache_free+0x4c/0x300>
[   47.926611] g0: 0000000000675668 g1: 0006120000000000 g2:
0000004000000000 g3: 0006000000000000
[   47.926682] g4: fff80024938c8e40 g5: fff80024a83bc000 g6:
fff8002490254000 g7: 0000000000000102
[   47.926751] o0: 0000000000000000 o1: 0000000000d02c30 o2:
fff80024938c96b8 o3: 000000000000c000
[   47.926821] o4: 00000000014c3000 o5: 0000000000000000 sp:
fff80024ad577121 ret_pc: 00000000004d5148
[   47.926898] RPC: <lock_is_held_type+0x68/0xe0>
[   47.926940] l0: 0000000000000000 l1: 0000000000000000 l2:
00000000f0000000 l3: 0000000000000080
[   47.927010] l4: 0000000000d953c0 l5: 0000000000d953c0 l6:
0000000000000002 l7: 000000000000000b
[   47.927080] i0: fff800003040b1e0 i1: 0000000000000000 i2:
fff80024938c96b8 i3: fff80024938c8e40
[   47.927149] i4: 0000000000000004 i5: fff80024938c9730 i6:
fff80024ad5771d1 i7: 00000000006409f4
[   47.927223] I7: <ptlock_free+0x14/0x40>
[   47.927261] Call Trace:
[   47.927291]  [00000000006409f4] ptlock_free+0x14/0x40
[   47.927342]  [0000000000450a54] __pte_free+0x34/0x80
[   47.927388]  [0000000000451b54] pgtable_free+0x14/0x40
[   47.927436]  [00000000006470fc] tlb_remove_table_rcu+0x3c/0x80
[   47.927497]  [00000000004fae94] rcu_core+0xbd4/0x1000
[   47.927543]  [00000000004fb7ac] rcu_core_si+0xc/0x20
[   47.927593]  [0000000000abc648] __do_softirq+0x288/0x500
[   47.927644]  [000000000042d054] do_softirq_own_stack+0x34/0x60
[   47.927697]  [000000000046c1c8] irq_exit+0x68/0xe0
[   47.927742]  [0000000000abc1b8] timer_interrupt+0x98/0xc0
[   47.927791]  [0000000000427490] sys_call_table+0x780/0x970
[   47.927845]  [0000000000609ba8] test_clear_page_writeback+0x2c8/0x300
[   47.927900]  [00000000005f9d18] end_page_writeback+0x58/0xa0
[   47.927951]  [00000000007b83f8] xfs_destroy_ioend+0xf8/0x240
[   47.928002]  [00000000007b86a4] xfs_end_ioend+0x164/0x1e0
[   47.928050]  [00000000007b9550] xfs_end_io+0x90/0xc0
[   47.928095] Disabling lock debugging due to kernel taint
[   47.928118] Caller[00000000006409f4]: ptlock_free+0x14/0x40
[   47.928140] Caller[0000000000450a54]: __pte_free+0x34/0x80
[   47.928162] Caller[0000000000451b54]: pgtable_free+0x14/0x40
[   47.928184] Caller[00000000006470fc]: tlb_remove_table_rcu+0x3c/0x80
[   47.928208] Caller[00000000004fae94]: rcu_core+0xbd4/0x1000
[   47.928230] Caller[00000000004fb7ac]: rcu_core_si+0xc/0x20
[   47.928252] Caller[0000000000abc648]: __do_softirq+0x288/0x500
[   47.928278] Caller[000000000042d054]: do_softirq_own_stack+0x34/0x60
[   47.928306] Caller[000000000046c1c8]: irq_exit+0x68/0xe0
[   47.928330] Caller[0000000000abc1b8]: timer_interrupt+0x98/0xc0
[   47.928357] Caller[0000000000427490]: sys_call_table+0x780/0x970
[   47.928384] Caller[0000000000609b9c]: test_clear_page_writeback+0x2bc/0x300
[   47.928412] Caller[00000000005f9d18]: end_page_writeback+0x58/0xa0
[   47.928736] Caller[00000000007b83f8]: xfs_destroy_ioend+0xf8/0x240
[   47.928770] Caller[00000000007b86a4]: xfs_end_ioend+0x164/0x1e0
[   47.928798] Caller[00000000007b9550]: xfs_end_io+0x90/0xc0
[   47.928829] Caller[0000000000486ea4]: process_one_work+0x3e4/0x720
[   47.928858] Caller[00000000004874b8]: worker_thread+0x2d8/0x5a0
[   47.928888] Caller[000000000048ef50]: kthread+0x110/0x140
[   47.928922] Caller[00000000004060e4]: ret_from_fork+0x1c/0x2c
[   47.928952] Caller[0000000000000000]: 0x0
[   47.928973] Instruction DUMP:
[   47.928976]  82004002
[   47.928995]  83287003
[   47.929013]  82004003
[   47.929031] <c4586008>
[   47.929048]  8608a001
[   47.929065]  8400bfff
[   47.929082]  8578c401
[   47.929098]  82100002
[   47.929115]  c458a008
[   47.929132]
[   47.929161] Kernel panic - not syncing: Aiee, killing interrupt handler!
[   47.933949] Press Stop-A (L1-A) from sun keyboard or send break
[   47.933949] twice on console to return to the boot prom
[   47.933995] ---[ end Kernel panic - not syncing: Aiee, killing
interrupt handler! ]---

