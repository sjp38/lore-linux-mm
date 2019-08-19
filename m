Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF2E9C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EFED218BA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:28:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xeoq2S9u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EFED218BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7196B000A; Mon, 19 Aug 2019 14:28:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7DA6B000C; Mon, 19 Aug 2019 14:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A97E16B000D; Mon, 19 Aug 2019 14:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id 7C35E6B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 14:28:00 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1CCFE181AC9B4
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:28:00 +0000 (UTC)
X-FDA: 75840011520.22.team24_28a5d2b9a7c22
X-HE-Tag: team24_28a5d2b9a7c22
X-Filterd-Recvd-Size: 15926
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com [209.85.208.194])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:27:59 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id h15so2679005ljg.10
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:27:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2Uhn1WQSv06ksN37dFDEFH7yXxJJzBud7jwe2stfefU=;
        b=Xeoq2S9uneaNoMMIX72JwjjUlWWwZo2f4HetNYInqMfELi7b0vsOnSkCi5Fx2Fc7Ej
         f3ufMpIB08PccJuTFZPijksWFvY79l7VmKarN2UIo8IN+7y5GKb5UoTD9M90HiZp0Pzk
         AcROh9rn2BzPMjJNiMJaZ7XgHRKnFthWlamkMub1vkMf/fZDDX6FA9wgA/7rtzq1LdpG
         DlLy4QVtdM2JxvLBf9/NfAtpKoQsLkR4uJaCEKCplr5B4TaRSbWuma/KBKIUwHoIdNAJ
         fmJRi0UG2kK9NNKQ1kH/zRAnMS/ycDyn1SmBB3v02jcFz1vylYO1mb8yL59uodOMnjrX
         ST2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2Uhn1WQSv06ksN37dFDEFH7yXxJJzBud7jwe2stfefU=;
        b=VL/I+suo72K1nB58KA0NpJKLUsh33W13O+9rOX8CRuWpVC+wesBui57VW/unoCCO5M
         DSe/KEd6LddWdiTbWmk5rpj1Cvv6mCcOobnNtQuVqzCxS1hs8XV16w9hMwAXZm9CXMLx
         XYHCbeKmD10exo5IAnuyGuXsRCgIT7hVb4eaYSvyMdmrKrFPsmlisj7Y37NdRfPlpti3
         tQDE9xSPgtvztaqEK8VWWs33TWubhSEu6ErnsK4bUkJNMv0ag/5n2LpbYkuwbDn+DTkc
         mwR9mCAgBjAzg5KjYD78Uk806ZhN6uIjLi2TXUbuBwGtJvVCHv4XwY2oxf480dwvdBak
         w6ow==
X-Gm-Message-State: APjAAAX3oFwCWTjjF5px7L634+Q9XOjiNf4frGisBYq9UmC3BalMZhRz
	rAimqIip5rq8i9P4xjsOo7tVV6CdPvMlwVTUtMw=
X-Google-Smtp-Source: APXvYqw2B0oKIyYCcqzlj1E4yq14IWF+A1kWu2SQsNRGowV4/PL4cIhtxxpZM6f8iImOI69CdmmalsWwId1PGKCgCKo=
X-Received: by 2002:a2e:b4d4:: with SMTP id r20mr13468515ljm.5.1566239277367;
 Mon, 19 Aug 2019 11:27:57 -0700 (PDT)
MIME-Version: 1.0
References: <CAH6yVy3s6Z6EH+7QRcN740pZe6CP-kkC83VwYd4RvbRm6LF4OQ@mail.gmail.com>
 <20190819073456.GC3111@dhcp22.suse.cz> <CAMJBoFPGT0_GqZLuOxLWPtrYkwM2WLvZ9=8F7phnGEoGYSEW8Q@mail.gmail.com>
 <CAMJBoFN-TPggasbaEnpubXt+77XHQt+AGmu9A9JX2c=h7Tog0Q@mail.gmail.com>
 <CAH6yVy0S_=2tOcx2+LMT7DOe8xg+4KaVnzQiSGwLfGPsxD1g1Q@mail.gmail.com>
 <CAMJBoFPAOSd3w9YECBqT3nudBozEsMi7ODNE+3nCvKEjT-nhnQ@mail.gmail.com> <CAH6yVy3N0Khp8sdwU-h=jgX_ynoWfCVRzk3uJiYJGAYXBnHJTQ@mail.gmail.com>
In-Reply-To: <CAH6yVy3N0Khp8sdwU-h=jgX_ynoWfCVRzk3uJiYJGAYXBnHJTQ@mail.gmail.com>
From: Markus Linnala <markus.linnala@gmail.com>
Date: Mon, 19 Aug 2019 21:27:45 +0300
Message-ID: <CAH6yVy2T6rtcXgC+DRR=nRHCE-NFyiXELYf1PMhrR5=uF1eQOQ@mail.gmail.com>
Subject: Re: PROBLEM: zswap with z3fold makes swap stuck
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I got different call trace. Attached as console-1566238241.520493280.log

[  460.814661] kernel BUG at lib/list_debug.c:51!
[  460.815798] invalid opcode: 0000 [#1] SMP PTI
[  460.816417] CPU: 0 PID: 1829 Comm: stress Tainted: G        W
  5.3.0-rc5+ #71
[  460.817470] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
BIOS 1.12.0-2.fc30 04/01/2014
[  460.818658] RIP: 0010:__list_del_entry_valid.cold+0x31/0x55
[  460.819500] Code: fc 11 a6 e8 34 7d bf ff 0f 0b 48 c7 c7 a0 fd 11
a6 e8 26 7d bf ff 0f 0b 48 89 f2 48 89 fe 48 c7 c7 60 fd 11 a6 e8 12
7d bf ff <0f> 0b 48 89 fe 4c 89 c2 48 c7 c7 28 fd 11 a6 e8 fe 7c bf ff
0f 0b
[  460.822146] RSP: 0018:ffffbdad80947b20 EFLAGS: 00010046
[  460.822908] RAX: 0000000000000054 RBX: ffffa03f75f1fe00 RCX: 0000000000000000
[  460.823919] RDX: 0000000000000000 RSI: ffffa03f7e5d89c8 RDI: ffffa03f7e5d89c8
[  460.824931] RBP: ffffa03f75f1fe08 R08: ffffa03f7e5d89c8 R09: 0000000000000001
[  460.825954] R10: 0000000000000001 R11: 0000000000000000 R12: ffffa03f55c08058
[  460.826975] R13: ffffa03f55c08000 R14: ffffa03f55c08010 R15: 0000000000000000
[  460.828008] FS:  00007fe19aa85740(0000) GS:ffffa03f7e400000(0000)
knlGS:0000000000000000
[  460.829160] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  460.830011] CR2: 00007fe19ac482c8 CR3: 0000000035a1c002 CR4: 0000000000160ef0
[  460.831032] Call Trace:
[  460.831380]  z3fold_zpool_free+0x234/0x323
[  460.831969]  zswap_free_entry+0x43/0x50
[  460.832522]  zswap_frontswap_invalidate_page+0x8c/0x90
[  460.833261]  __frontswap_invalidate_page+0x56/0x90
[  460.833963]  swap_range_free+0xb2/0xd0
[  460.834494]  swapcache_free_entries+0x128/0x1a0
[  460.835167]  free_swap_slot+0xd5/0xf0
[  460.835706]  __swap_entry_free.constprop.0+0x8c/0xa0
[  460.836418]  free_swap_and_cache+0x35/0x70
[  460.837020]  unmap_page_range+0x4c8/0xd00
[  460.837595]  unmap_vmas+0x70/0xd0
[  460.838042]  unmap_region+0xa8/0x110
[  460.838533]  __do_munmap+0x297/0x460
[  460.839008]  __vm_munmap+0x6a/0xc0
[  460.839462]  __x64_sys_munmap+0x28/0x30
[  460.839982]  do_syscall_64+0x5a/0x220
[  460.840488]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  460.841147] RIP: 0033:0x7fe19ab7e1eb
[  460.841646] Code: 8b 15 a1 9c 0c 00 f7 d8 64 89 02 48 c7 c0 ff ff
ff ff eb 89 66 2e 0f 1f 84 00 00 00 00 00 90 f3 0f 1e fa b8 0b 00 00
00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 6d 9c 0c 00 f7 d8 64 89
01 48
[  460.844838] RSP: 002b:00007fffd016cc18 EFLAGS: 00000206 ORIG_RAX:
000000000000000b
[  460.845657] RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 00007fe19ab7e1eb
[  460.846424] RDX: 000000000000000f RSI: 000000000b87f000 RDI: 00007fe18f206000
[  460.850824] RBP: 00007fe18f206010 R08: 00007fe18f206000 R09: 0000000000000000
[  460.855463] R10: 00007fe19aa84010 R11: 0000000000000206 R12: 000056292b3c8004
[  460.860138] R13: 0000000000000002 R14: 0000000000001000 R15: 000000000b87ec00
[  460.864922] Modules linked in: ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
iptable_mangle iptable_raw iptable_security nf_conntrack
nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon
net_failover failover intel_agp intel_gtt qxl drm_kms_helper
syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
serio_raw virtio_blk virtio_console agpgart qemu_fw_cfg
[  460.903490] ---[ end trace bd72aa26a921e57c ]---


(gdb) l *z3fold_zpool_free+0x234
0xffffffff81339be4 is in z3fold_zpool_free
(/src/linux/include/linux/list.h:190).
185 * list_del_init - deletes entry from list and reinitialize it.
186 * @entry: the element to delete from the list.
187 */
188 static inline void list_del_init(struct list_head *entry)
189 {
190 __list_del_entry(entry);
191 INIT_LIST_HEAD(entry);
192 }
193
194 /**
(gdb) l *zswap_free_entry+0x43
0xffffffff812e7ed3 is in zswap_free_entry (/src/linux/mm/zswap.c:329).
324 {
325 if (!entry->length)
326 atomic_dec(&zswap_same_filled_pages);
327 else {
328 zpool_free(entry->pool->zpool, entry->handle);
329 zswap_pool_put(entry->pool);
330 }
331 zswap_entry_cache_free(entry);
332 atomic_dec(&zswap_stored_pages);
333 zswap_update_total_size();
(gdb) l *zswap_frontswap_invalidate_page+0x8c
0xffffffff812e7f9c is in zswap_frontswap_invalidate_page
(/src/linux/include/linux/spinlock.h:378).
373 raw_spin_lock_irqsave_nested(spinlock_check(lock), flags, subclass); \
374 } while (0)
375
376 static __always_inline void spin_unlock(spinlock_t *lock)
377 {
378 raw_spin_unlock(&lock->rlock);
379 }
380
381 static __always_inline void spin_unlock_bh(spinlock_t *lock)
382 {

ma 19. elok. 2019 klo 20.49 Markus Linnala (markus.linnala@gmail.com) kirjoitti:
>
> I have applied your patch against vanilla v5.3-rc5. There was no config changes.
>
> So far I've gotten couple of these GPF. I guess this is different
> issue. It will take several hours to get full view.
>
> I've attached one full console log as: console-1566235171.001993084.log
>
> [   13.821223] general protection fault: 0000 [#1] SMP PTI
> [   13.821882] CPU: 0 PID: 151 Comm: kswapd0 Tainted: G        W
>   5.3.0-rc5+ #71
> [   13.822755] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> BIOS 1.12.0-2.fc30 04/01/2014
> [   13.824272] RIP: 0010:handle_to_buddy+0x20/0x30
> [   13.824786] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 53
> 48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00
> f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 00
> 00 55
> [   13.826854] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206
> [   13.827452] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX: 0000000000000000
> [   13.828256] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI: ffff97ddbe5d89c8
> [   13.829056] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09: 0000000000000000
> [   13.829860] R10: 0000000000000000 R11: 0000000000000000 R12: ffff97dd890fd001
> [   13.830660] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15: ffffb18cc0197838
> [   13.831468] FS:  0000000000000000(0000) GS:ffff97ddbe400000(0000)
> knlGS:0000000000000000
> [   13.832673] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   13.833593] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4: 0000000000160ef0
> [   13.834508] Call Trace:
> [   13.834828]  z3fold_zpool_map+0x76/0x110
> [   13.835332]  zswap_writeback_entry+0x50/0x410
> [   13.835888]  z3fold_zpool_shrink+0x3d1/0x570
> [   13.836434]  ? sched_clock_cpu+0xc/0xc0
> [   13.836919]  zswap_frontswap_store+0x424/0x7c1
> [   13.837484]  __frontswap_store+0xc4/0x162
> [   13.837992]  swap_writepage+0x39/0x70
> [   13.838460]  pageout.isra.0+0x12c/0x5d0
> [   13.838950]  shrink_page_list+0x1124/0x1830
> [   13.839484]  shrink_inactive_list+0x1da/0x460
> [   13.840036]  shrink_node_memcg+0x202/0x770
> [   13.840746]  shrink_node+0xdf/0x490
> [   13.841931]  balance_pgdat+0x2db/0x580
> [   13.842396]  kswapd+0x239/0x500
> [   13.842772]  ? finish_wait+0x90/0x90
> [   13.847323]  kthread+0x108/0x140
> [   13.848358]  ? balance_pgdat+0x580/0x580
> [   13.849626]  ? kthread_park+0x80/0x80
> [   13.850352]  ret_from_fork+0x3a/0x50
> [   13.851086] Modules linked in: ip6t_rpfilter ip6t_REJECT
> nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> iptable_mangle iptable_raw iptable_security nf_conntrack
> nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon
> net_failover failover intel_agp intel_gtt qxl drm_kms_helper
> syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> virtio_blk virtio_console serio_raw agpgart qemu_fw_cfg
> [   13.857818] ---[ end trace 4517028df5e476fe ]---
> [   13.858400] RIP: 0010:handle_to_buddy+0x20/0x30
> [   13.859761] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 53
> 48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00
> f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 00
> 00 55
> [   13.862703] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206
> [   13.864232] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX: 0000000000000000
> [   13.865834] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI: ffff97ddbe5d89c8
> [   13.867362] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09: 0000000000000000
> [   13.869121] R10: 0000000000000000 R11: 0000000000000000 R12: ffff97dd890fd001
> [   13.871091] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15: ffffb18cc0197838
> [   13.872742] FS:  0000000000000000(0000) GS:ffff97ddbe400000(0000)
> knlGS:0000000000000000
> [   13.874448] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   13.876382] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4: 0000000000160ef0
> [   13.878007] ------------[ cut here ]------------
>
>
> (gdb) l *handle_to_buddy+0x20
> 0xffffffff813376b0 is in handle_to_buddy (/src/linux/mm/z3fold.c:429).
> 424 unsigned long addr;
> 425
> 426 WARN_ON(handle & (1 << PAGE_HEADLESS));
> 427 addr = *(unsigned long *)handle;
> 428 zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
> 429 return (addr - zhdr->first_num) & BUDDY_MASK;
> 430 }
> 431
> 432 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
> 433 {
> (gdb) l *z3fold_zpool_map+0x76
> 0xffffffff81337cb6 is in z3fold_zpool_map (/src/linux/mm/z3fold.c:1257).
> 1252 if (test_bit(PAGE_HEADLESS, &page->private))
> 1253 goto out;
> 1254
> 1255 z3fold_page_lock(zhdr);
> 1256 buddy = handle_to_buddy(handle);
> 1257 switch (buddy) {
> 1258 case FIRST:
> 1259 addr += ZHDR_SIZE_ALIGNED;
> 1260 break;
> 1261 case MIDDLE:
> (gdb) l *zswap_writeback_entry+0x50
> 0xffffffff812e8260 is in zswap_writeback_entry (/src/linux/mm/zswap.c:858).
> 853 .sync_mode = WB_SYNC_NONE,
> 854 };
> 855
> 856 /* extract swpentry from data */
> 857 zhdr = zpool_map_handle(pool, handle, ZPOOL_MM_RO);
> 858 swpentry = zhdr->swpentry; /* here */
> 859 zpool_unmap_handle(pool, handle);
> 860 tree = zswap_trees[swp_type(swpentry)];
> 861 offset = swp_offset(swpentry);
> (gdb) l *z3fold_zpool_shrink+0x3d1
> 0xffffffff81338821 is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:1186).
> 1181 ret = pool->ops->evict(pool, middle_handle);
> 1182 if (ret)
> 1183 goto next;
> 1184 }
> 1185 if (first_handle) {
> 1186 ret = pool->ops->evict(pool, first_handle);
> 1187 if (ret)
> 1188 goto next;
> 1189 }
> 1190 if (last_handle) {
>
>
> To compare, I got following Call Trace "signatures" against vanilla
> v5.3-rc5. Some of them might not be related to zswap at all.
>
> [   15.469831] Call Trace:
> [   15.470171]  migrate_pages+0x20c/0xfb0
> [   15.470678]  ? isolate_freepages_block+0x410/0x410
> [   15.471344]  ? __ClearPageMovable+0x90/0x90
> [   15.471914]  compact_zone+0x74c/0xef0
> --
> [  105.611480] Call Trace:
> [  105.611817]  zswap_writeback_entry+0x50/0x410
> [  105.612417]  z3fold_zpool_shrink+0x29d/0x540
> [  105.612947]  zswap_frontswap_store+0x424/0x7c1
> [  105.613494]  __frontswap_store+0xc4/0x162
> --
> [   15.103942] Call Trace:
> [   15.104280]  z3fold_zpool_map+0x76/0x110
> [   15.104824]  zswap_writeback_entry+0x50/0x410
> [   15.105398]  z3fold_zpool_shrink+0x3c4/0x540
> [   15.105960]  zswap_frontswap_store+0x424/0x7c1
> --
> [  632.066122] Call Trace:
> [  632.066124]  z3fold_zpool_map+0x76/0x110
> [  632.066128]  zswap_writeback_entry+0x50/0x410
> [  632.069101]  do_user_addr_fault+0x1fe/0x480
> [  632.069650]  z3fold_zpool_shrink+0x3c4/0x540
> --
> [  133.419601] Call Trace:
> [  133.420199]  zswap_writeback_entry+0x50/0x410
> [  133.421244]  z3fold_zpool_shrink+0x4a6/0x540
> [  133.422266]  zswap_frontswap_store+0x424/0x7c1
> [  133.423386]  __frontswap_store+0xc4/0x162
> --
> [  155.374773] Call Trace:
> [  155.375122]  get_page_from_freelist+0x57d/0x1a40
> [  155.375725]  __alloc_pages_nodemask+0x19d/0x400
> [  155.376354]  alloc_pages_vma+0xcc/0x170
> [  155.376854]  __read_swap_cache_async+0x1e9/0x3e0
> --
> [   23.849834] Call Trace:
> [   23.851038]  get_page_from_freelist+0x57d/0x1a40
> [   23.853300]  ? wake_all_kswapds+0x54/0xb0
> [   23.855280]  __alloc_pages_slowpath+0x1ae/0x1000
> [   23.857512]  ? __lock_acquire+0x247/0x1900
> --
> [  197.206331] Call Trace:
> [  197.207923]  __release_z3fold_page.constprop.0+0x7e/0x130
> [  197.211387]  do_compact_page+0x2c9/0x430
> [  197.213830]  process_one_work+0x272/0x5a0
> [  197.216392]  worker_thread+0x50/0x3b0

