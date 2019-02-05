Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE39C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1571D2080F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:48:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="ypMGXNKL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1571D2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75B248E008A; Tue,  5 Feb 2019 09:48:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E0598E001C; Tue,  5 Feb 2019 09:48:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583A28E008A; Tue,  5 Feb 2019 09:48:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5EF18E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 09:48:21 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id v19so618093lfg.0
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 06:48:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AncC85zFERTHGpOCeJQU+o23rarS4+H0wwME5FR7jc4=;
        b=U2ZyibQvYvvCv7JJGaIrT+CxO/nGBwcLqL4VIXk2leN3VP7ttBay4iYrP8OGXs3Spd
         /3rNEIeaaXQ1mOXii1KLZkbGtufqUy4Ri4w3KKGDAfLD4SwCFHm/wtKS7HC6OJLLkCwJ
         1qsR26pmDyC9+Y0l17XPQrAawsC54/3mfrH1yyN7VVShhxwEgT0Qc8uyyQk9UexPGR29
         tbbX35+efhQToL6GzycrLgXkQtRBhzjCPtAohVST9OpA6CGLercu0zzZYdPiTlectWT/
         sZwLUAaaOJ9/TG+JMdZkcWymg071Nfj9Qm0wtft3PwHeHovoZylFnnrj6NXrGrhjd3Ik
         xVaA==
X-Gm-Message-State: AHQUAuaAaARlu37aBf2iPFcgw0UabS8628ffyfVids+8kNgB9zVR6Uy5
	MQw53wx9Zj7GhgcDbsdgo6bscBzKD6m+K4EYpfEjebKlcPk1MOoTsqLJ834MQ7+hPuqAq9nxgRu
	Dy93q1j05lv/BtO6J3RwNVpMDETpzTHdq820JVY9ZUI6PMEl7uM1C00LDJKMEg7CN4g==
X-Received: by 2002:a19:9555:: with SMTP id x82mr3112346lfd.113.1549378100820;
        Tue, 05 Feb 2019 06:48:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaa8d6wvy0p8ouMnMWlmMhBfqQINwNzRbykwA7NKup8FyKomzBq0zRoSL9c6NJ6vjvIThyM
X-Received: by 2002:a19:9555:: with SMTP id x82mr3112246lfd.113.1549378098589;
        Tue, 05 Feb 2019 06:48:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549378098; cv=none;
        d=google.com; s=arc-20160816;
        b=bOAKGLLsnBUkNTuSs7OdF0hZctvALmRP3+A69sPdrQdfdHTAYJ3Ou/Hkcyws+zJLtB
         t3Rp1QcYU1vTlB2rKvd0OL0ydKcWC+naFnoeDdd01xR42KCKwXHY9zMOg7ZhvL8BekFE
         F6GxZimGl6IADqiuxy8lSfK2pMAIx+kzjvb5EPOkpaGHlpQjjVWSxU3yI+zuTUxqVEm6
         cN0p8p+ZIJ7mMXxuGuvedPCXvJMLC43rnsbWZaSeJuwNra21QGd5IaTNQC/bWkZ+EIRc
         3CUKJRrE8SrTljCPZyUFlhzPKQVap9N2ScSbK3NeopPO1B0tc21RBjllRdzalkUQpKlS
         FcTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:to:from:subject
         :dkim-signature;
        bh=AncC85zFERTHGpOCeJQU+o23rarS4+H0wwME5FR7jc4=;
        b=Hofr8UcoQlXgAZC+V+RmFkLFWss0+CefrFUZQKomsVU1R0WpB0uwLePzl2UnvYAHME
         +6WIs4T6+c8ldhxEJbBq9DqPcsOPZdjYvPl7lZ8vWfF+JVX7SiI5cZgIp99AoC83XNlw
         ZYssYiilWfBGMlBQTsFz3qxDnM9j47HLP1v0yGnTVauMQ2WGQ2H/4hpHxNUkPH4pIrT0
         UHKM1OdcaKoQakS44fMfuEVO9TUQLzh86pVwVnSZLRak0shSOVdUnUYqDRLqgLEAe/n3
         aQ0OtNSz+CBMuGrPqgyGg0iI0EFS/rX4+yCsyNbMNLsf7Hp0eU4IgXduZHIpZ/bOBYpu
         P4Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=ypMGXNKL;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 87.250.241.190 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id b24si11227581lff.51.2019.02.05.06.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 06:48:18 -0800 (PST)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 87.250.241.190 as permitted sender) client-ip=87.250.241.190;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=ypMGXNKL;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 87.250.241.190 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1g.cmail.yandex.net (Yandex) with ESMTP id DE9FC21774;
	Tue,  5 Feb 2019 17:48:17 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 9YKs2IA4Ep-mHWWHU5b;
	Tue, 05 Feb 2019 17:48:17 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1549378097; bh=AncC85zFERTHGpOCeJQU+o23rarS4+H0wwME5FR7jc4=;
	h=Subject:From:To:References:Message-ID:Date:In-Reply-To;
	b=ypMGXNKLcCQhPhXhF044mWeCxsdMQ3ARa1m12/ydhB5x4O5Fk2R6eEInsLTsp0/Gy
	 7Cdn8OoamQMubqHczerANsybkP/8jvYNmkanLgGfm6Tq8PbJPTkD7MPG2Etcpim/1S
	 Sio+vRMyjGAHjfIzFi7JWg12tP37T8ae9v156pdM=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ccb1:d36:e945:f357])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id YUxb0NvJjE-mH5Cedxo;
	Tue, 05 Feb 2019 17:48:17 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: kernel BUG at mm/huge_memory.c:LINE!
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: syzbot <syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com>,
 akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com,
 hughd@google.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com,
 rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz,
 willy@infradead.org
References: <0000000000004d2e19057e8b6d78@google.com>
 <3478bd83-6f5c-bf8e-6b62-56139110f712@yandex-team.ru>
Message-ID: <c3a96e1f-1a44-ddac-7b46-7abba2e12a9c@yandex-team.ru>
Date: Tue, 5 Feb 2019 17:48:16 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <3478bd83-6f5c-bf8e-6b62-56139110f712@yandex-team.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.01.2019 19:57, Konstantin Khlebnikov wrote:
> 
> I've got couple of these for 4.14.
> Maybe related but this happened with THP tmpfs.
> 
> 
> <1>[220723.475439] huge_memory: total_mapcount: 63, page_count(): 576
> <0>[220723.475474] page:ffffea0024ee8000 count:576 mapcount:0 mapping:ffff881813235550 index:0x0 compound_mapcount: 0
> <0>[220723.475512] flags: 0x10000000004807d(locked|referenced|uptodate|dirty|lru|active|head|swapbacked)
> <1>[220723.475545] raw: 010000000004807d ffff881813235550 0000000000000000 00000240ffffffff
> <1>[220723.475573] raw: ffffea004c099a20 ffffea002bd9e020 0000000000000000 ffff883018044800
> <1>[220723.475601] page dumped because: total_mapcount(head) > 0
> <1>[220723.475621] page->mem_cgroup:ffff883018044800
> <4>[220723.475644] ------------[ cut here ]------------
> <2>[220723.475645] kernel BUG at mm/huge_memory.c:2652!
> <4>[220723.475667] invalid opcode: 0000 [#1] SMP PTI
> <4>[220723.475684] Modules linked in: xt_nat xt_limit overlay ip6table_nat nf_nat_ipv6 nf_nat veth tcp_diag inet_diag unix_diag xt_NFLOG 
> nfnetlink_log nfnetlink ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common xt_LOG nf_conntrack_ipv6 nf_defrag_ipv6 xt_u32 ip6table_raw 
> xt_conntrack ip6table_filter xt_tcpudp xt_CT nf_conntrack iptable_raw xt_multiport iptable_filter bridge ip6_tables ip_tables x_tables 
> sch_fq_codel sch_hfsc netconsole configfs 8021q mrp garp stp llc intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp mgag200 coretemp 
> ttm kvm_intel drm_kms_helper drm kvm fb_sys_fops sysimgblt input_leds sysfillrect syscopyarea irqbypass lpc_ich mfd_core ghash_clmulni_intel 
> shpchp ioatdma wmi tcp_bbr ip6_tunnel tunnel6 mlx4_en mlx4_core devlink tcp_nv tcp_htcp raid456 async_raid6_recov async_pq async_xor
> <4>[220723.475954]  xor async_memcpy async_tx raid10 igb isci dca libsas i2c_algo_bit ptp scsi_transport_sas pps_core raid6_pq libcrc32c 
> raid1 raid0 multipath linear [last unloaded: ipmi_msghandler]
> <4>[220723.476021] CPU: 5 PID: 529913 Comm: qpipe-updater Not tainted 4.14.80-33 #1
> <4>[220723.476047] Hardware name: Aquarius Aquarius Server/X9DRW, BIOS 3.0c 10/30/2014
> <4>[220723.476074] task: ffff8817b98f3900 task.stack: ffffc900311d4000
> <4>[220723.476099] RIP: 0010:split_huge_page_to_list+0x7b5/0x8d0
> <4>[220723.476120] RSP: 0018:ffffc900311d76a0 EFLAGS: 00010086
> <4>[220723.476140] RAX: 0000000000000021 RBX: ffff881813235550 RCX: 0000000000000006
> <4>[220723.476165] RDX: 0000000000000007 RSI: 0000000000000082 RDI: ffff88181fb55730
> <4>[220723.476190] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000c20
> <4>[220723.476216] R10: ffffc900311d7690 R11: 0000000000000001 R12: 0000000000000000
> <4>[220723.476241] R13: ffffea0024ee8000 R14: ffff88187fffb000 R15: ffffea0024ee8000
> <4>[220723.476267] FS:  00007fe7a69097c0(0000) GS:ffff88181fb40000(0000) knlGS:0000000000000000
> <4>[220723.476296] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <4>[220723.476317] CR2: 00007fe78c1e1000 CR3: 0000001815530005 CR4: 00000000000606e0
> <4>[220723.476342] Call Trace:
> <4>[220723.476358]  ? find_get_entry+0x20/0x140
> <4>[220723.476377]  shmem_unused_huge_shrink+0x184/0x3f0
> <4>[220723.476398]  super_cache_scan+0x184/0x190
> <4>[220723.476416]  shrink_slab.part.54+0x1ec/0x430
> <4>[220723.476434]  shrink_node+0x300/0x310
> <4>[220723.476451]  do_try_to_free_pages+0xe3/0x350
> <4>[220723.476469]  try_to_free_pages+0xe4/0x1d0
> <4>[220723.476487]  __alloc_pages_slowpath+0x3a5/0xe70
> <4>[220723.476507]  __alloc_pages_nodemask+0x25c/0x2a0
> <4>[220723.476526]  shmem_alloc_hugepage+0xc7/0x110
> <4>[220723.476545]  ? __radix_tree_create+0x168/0x1f0
> <4>[220723.476563]  ? release_pages+0x2c8/0x3a0
> <4>[220723.476579]  ? release_pages+0x2c8/0x3a0
> <4>[220723.477420]  ? __activate_page+0x200/0x2d0
> <4>[220723.478254]  ? percpu_counter_add_batch+0x52/0x70
> <4>[220723.479095]  shmem_alloc_and_acct_page+0x108/0x1d0
> <4>[220723.479926]  shmem_getpage_gfp+0x4ef/0xdf0
> <4>[220723.480736]  shmem_write_begin+0x35/0x60
> <4>[220723.481514]  generic_perform_write+0xaf/0x1b0
> <4>[220723.482293]  __generic_file_write_iter+0x196/0x1e0
> <4>[220723.483061]  generic_file_write_iter+0xe6/0x1f0
> <4>[220723.483820]  __vfs_write+0xdc/0x150
> <4>[220723.484573]  vfs_write+0xc5/0x1c0
> <4>[220723.485324]  SyS_write+0x42/0x90
> <4>[220723.486067]  do_syscall_64+0x67/0x120
> <4>[220723.486790]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> <4>[220723.487496] RIP: 0033:0x7fe7a60d8330
> <4>[220723.488175] RSP: 002b:00007ffc05104af8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> <4>[220723.488851] RAX: ffffffffffffffda RBX: 00007fe785e00000 RCX: 00007fe7a60d8330
> <4>[220723.489511] RDX: 0000000011be3b28 RSI: 00007fe785e00000 RDI: 0000000000000003
> <4>[220723.490156] RBP: 0000000011be3b28 R08: 00007fe7a69097c0 R09: 00007ffc05104bb7
> <4>[220723.490770] R10: 00007ffc051048c0 R11: 0000000000000246 R12: 0000000107b88c00
> <4>[220723.491364] R13: 00007ffc051057b8 R14: 0000000011be3b28 R15: 00000001072886b8
> <4>[220723.491933] Code: 8b 54 24 08 48 c7 c7 28 54 06 82 e8 51 59 eb ff 49 8b 45 20 a8 01 0f 85 1b 01 00 00 48 c7 c6 8c 50 06 82 4c 89 ef 
> e8 cb 64 fb ff <0f> 0b 48 c7 c6 60 53 06 82 4c 89 ff e8 ba 64 fb ff 0f 0b e8 23
> <1>[220723.493137] RIP: split_huge_page_to_list+0x7b5/0x8d0 RSP: ffffc900311d76a0
> <4>[220723.493731] ---[ end trace 74a2900540d3546c ]---
> <5>[220723.494322] ---[ now 2018-12-24 07:08:37+03 ]---
> 
> 

with this debug patch on top of 4.14.94

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2651,12 +2651,14 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
                         ret = 0;
         } else {
                 if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
+                       int i;
+
                         pr_alert("total_mapcount: %u, page_count(): %u\n",
                                         mapcount, count);
-                       if (PageTail(page))
-                               dump_page(head, NULL);
-                       dump_page(page, "total_mapcount(head) > 0");
-                       BUG();
+                       for (i = 0; i < HPAGE_PMD_NR; i++)
+                               if (!i || (atomic_read(&head[i]._mapcount) + 1))
+                                       dump_page(head + i, "mapcount > 0");
+                       WARN_ON(1);
                 }
                 spin_unlock(&pgdata->split_queue_lock);
  fail:          if (mapping)



I've that some tail pages are still mapped:


huge_memory: total_mapcount: 63, page_count(): 576
page:ffffea007b588000 count:576 mapcount:0 mapping:ffff8897a557c4a0 index:0x0 compound_mapcount: 0
flags: 0x50000000004807d(locked|referenced|uptodate|dirty|lru|active|head|swapbacked)
raw: 050000000004807d ffff8897a557c4a0 0000000000000000 00000240ffffffff
raw: ffffea0063818020 ffffea008a67a020 0000000000000000 ffff88af2e528800
page dumped because: mapcount > 0
page->mem_cgroup:ffff88af2e528800
page:ffffea007b588f80 count:0 mapcount:1 mapping:dead000000000400 index:0x3e compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b588fc0 count:0 mapcount:1 mapping:dead000000000400 index:0x3f compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589000 count:0 mapcount:1 mapping:dead000000000400 index:0x40 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589040 count:0 mapcount:1 mapping:dead000000000400 index:0x41 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589080 count:0 mapcount:1 mapping:dead000000000400 index:0x42 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5890c0 count:0 mapcount:1 mapping:dead000000000400 index:0x43 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589100 count:0 mapcount:1 mapping:dead000000000400 index:0x44 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589140 count:0 mapcount:1 mapping:dead000000000400 index:0x45 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589180 count:0 mapcount:1 mapping:dead000000000400 index:0x46 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5891c0 count:0 mapcount:1 mapping:dead000000000400 index:0x47 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589200 count:0 mapcount:1 mapping:dead000000000400 index:0x48 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589240 count:0 mapcount:1 mapping:dead000000000400 index:0x49 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589280 count:0 mapcount:1 mapping:dead000000000400 index:0x4a compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5892c0 count:0 mapcount:1 mapping:dead000000000400 index:0x4b compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589300 count:0 mapcount:1 mapping:dead000000000400 index:0x4c compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589340 count:0 mapcount:1 mapping:dead000000000400 index:0x4d compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589380 count:0 mapcount:1 mapping:dead000000000400 index:0x4e compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5893c0 count:0 mapcount:1 mapping:dead000000000400 index:0x4f compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589400 count:0 mapcount:1 mapping:dead000000000400 index:0x50 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589440 count:0 mapcount:1 mapping:dead000000000400 index:0x51 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589480 count:0 mapcount:1 mapping:dead000000000400 index:0x52 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5894c0 count:0 mapcount:1 mapping:dead000000000400 index:0x53 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589500 count:0 mapcount:1 mapping:dead000000000400 index:0x54 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589540 count:0 mapcount:1 mapping:dead000000000400 index:0x55 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589580 count:0 mapcount:1 mapping:dead000000000400 index:0x56 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5895c0 count:0 mapcount:1 mapping:dead000000000400 index:0x57 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589600 count:0 mapcount:1 mapping:dead000000000400 index:0x58 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589640 count:0 mapcount:1 mapping:dead000000000400 index:0x59 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589680 count:0 mapcount:1 mapping:dead000000000400 index:0x5a compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5896c0 count:0 mapcount:1 mapping:dead000000000400 index:0x5b compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589700 count:0 mapcount:1 mapping:dead000000000400 index:0x5c compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589740 count:0 mapcount:1 mapping:dead000000000400 index:0x5d compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589780 count:0 mapcount:1 mapping:dead000000000400 index:0x5e compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5897c0 count:0 mapcount:1 mapping:dead000000000400 index:0x5f compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589800 count:0 mapcount:1 mapping:dead000000000400 index:0x60 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589840 count:0 mapcount:1 mapping:dead000000000400 index:0x61 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589880 count:0 mapcount:1 mapping:dead000000000400 index:0x62 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5898c0 count:0 mapcount:1 mapping:dead000000000400 index:0x63 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589900 count:0 mapcount:1 mapping:dead000000000400 index:0x64 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589940 count:0 mapcount:1 mapping:dead000000000400 index:0x65 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589980 count:0 mapcount:1 mapping:dead000000000400 index:0x66 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b5899c0 count:0 mapcount:1 mapping:dead000000000400 index:0x67 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589a00 count:0 mapcount:1 mapping:dead000000000400 index:0x68 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589a40 count:0 mapcount:1 mapping:dead000000000400 index:0x69 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589a80 count:0 mapcount:1 mapping:dead000000000400 index:0x6a compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589ac0 count:0 mapcount:1 mapping:dead000000000400 index:0x6b compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589b00 count:0 mapcount:1 mapping:dead000000000400 index:0x6c compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589b40 count:0 mapcount:1 mapping:dead000000000400 index:0x6d compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589b80 count:0 mapcount:1 mapping:dead000000000400 index:0x6e compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589bc0 count:0 mapcount:1 mapping:dead000000000400 index:0x6f compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589c00 count:0 mapcount:1 mapping:dead000000000400 index:0x70 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589c40 count:0 mapcount:1 mapping:dead000000000400 index:0x71 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589c80 count:0 mapcount:1 mapping:dead000000000400 index:0x72 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589cc0 count:0 mapcount:1 mapping:dead000000000400 index:0x73 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589d00 count:0 mapcount:1 mapping:dead000000000400 index:0x74 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589d40 count:0 mapcount:1 mapping:dead000000000400 index:0x75 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589d80 count:0 mapcount:1 mapping:dead000000000400 index:0x76 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589dc0 count:0 mapcount:1 mapping:dead000000000400 index:0x77 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589e00 count:0 mapcount:1 mapping:dead000000000400 index:0x78 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589e40 count:0 mapcount:1 mapping:dead000000000400 index:0x79 compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589e80 count:0 mapcount:1 mapping:dead000000000400 index:0x7a compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589ec0 count:0 mapcount:1 mapping:dead000000000400 index:0x7b compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
page:ffffea007b589f00 count:0 mapcount:1 mapping:dead000000000400 index:0x7c compound_mapcount: 0
flags: 0x500000000000000()
raw: 0500000000000000 dead000000000400 0000000000000001 0000000000000000
raw: ffffea007b588001 dead000000000200 0000000000000000 0000000000000000
page dumped because: mapcount > 0
------------[ cut here ]------------
WARNING: CPU: 5 PID: 237 at mm/huge_memory.c:2661 split_huge_page_to_list+0x790/0x8e0
Modules linked in: overlay tcp_nv i2c_i801 binfmt_misc veth ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common 
xt_LOG nf_conntrack_ipv6 nf_defrag_ipv6 xt_u32 ip6table_raw xt_conntrack xt_tcpudp xt_CT nf_conntrack iptable_raw xt_multiport 
ip6table_filter iptable_filter ip6_tables ip_tables x_tables tcp_htcp ip6_tunnel tunnel6 tcp_bbr sch_fq_codel sch_hfsc netconsole tcp_diag 
inet_diag unix_diag configfs 8021q garp mrp stp llc intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp ipmi_ssif coretemp kvm_intel 
kvm irqbypass input_leds ghash_clmulni_intel ipmi_si ipmi_devintf ioatdma ipmi_msghandler lpc_ich mfd_core shpchp mlx4_en mlx4_core devlink 
autofs4 raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath
  linear raid10 mgag200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm isci igb drm dca libsas ptp scsi_transport_sas 
pps_core i2c_algo_bit wmi [last unloaded: netconsole]
CPU: 5 PID: 237 Comm: kswapd0 Not tainted 4.14.94-38 #1
Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0c 10/30/2014
task: ffff8898149ae3c0 task.stack: ffffc9000d734000
RIP: 0010:split_huge_page_to_list+0x790/0x8e0
RSP: 0018:ffffc9000d737b68 EFLAGS: 00010046
RAX: 00000000ffffffff RBX: ffff8897a557c4a0 RCX: 0000000000000006
RDX: ffffea007b590000 RSI: 0000000000000000 RDI: ffff88981fb55730
RBP: 0000000000000000 R08: 0000000000000000 R09: 000000000000100e
R10: ffffc9000d737b58 R11: 0000000000000001 R12: 0000000000000200
R13: ffff88b07fff8000 R14: 0000000000000286 R15: ffffea007b588000
FS:  0000000000000000(0000) GS:ffff88981fb40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f7b0f746018 CR3: 000000000220a006 CR4: 00000000001606e0
Call Trace:
  ? find_get_entry+0x20/0x140
  shmem_unused_huge_shrink+0x184/0x3f0
  super_cache_scan+0x184/0x190
  shrink_slab.part.54+0x1c2/0x3f0
  shrink_node+0x468/0x480
  balance_pgdat+0x176/0x340
  kswapd+0x1ba/0x440
  ? wait_woken+0xb0/0xb0
  kthread+0x10a/0x140
  ? balance_pgdat+0x340/0x340
  ? kthread_create_on_node+0x40/0x40
  ret_from_fork+0x35/0x40
Code: ff 74 17 48 89 d7 48 c7 c6 c4 5a 06 82 48 89 14 24 e8 b5 63 fb ff 48 8b 14 24 41 83 c4 01 48 83 c2 40 41 81 fc 00 02 00 00 75 cb <0f> 
0b 41 c6 85 c4 45 00 00 00 65 ff 0d cf 74 dd 7e 48 85 db 0f
---[ end trace 4c5fba0af251fbf4 ]---


> 
>>
>> ---
>> This bug is generated by a bot. It may contain errors.
>> See https://goo.gl/tpsmEJ for more information about syzbot.
>> syzbot engineers can be reached at syzkaller@googlegroups.com.
>>
>> syzbot will keep track of this bug report. See:
>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with syzbot.

