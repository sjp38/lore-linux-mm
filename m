Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B34BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC2A20700
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:43:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ArI8bkRo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC2A20700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2E086B0008; Thu, 28 Mar 2019 21:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DDB96B000C; Thu, 28 Mar 2019 21:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4A76B000D; Thu, 28 Mar 2019 21:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0956B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:43:32 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x58so837548qtc.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gv6hWDFttTfp7Z+q9DmSrCaQCc0nzY2zjIjOCBbe07w=;
        b=KRAOUnGoVxcHfZEGs55XauE9F/d7/02dRzxhMUEL5yNKAl/n0Ua1pc6HSdZM8zNjkJ
         xSU39NDADvK1R5AF1qSW0Vtymm+2+Mt0DK4KE/0sSe3IuIjqtNkuSNxkd/eyg18TlnaE
         VdmiLObPFGymRGavGqHwyQb4ETPcQgZXeMigBxD98ReRSbJzh2Y4sGeQCKliGAD+Jz12
         BUyOrCwUa0u5Kt5odYvVzeydLDFkolDwxu5OJaNdidQtSXyY6u9z9l1rek5jMS+RJXCo
         bHq1aWt2AVXuTdvAfPqRwMSo5rIwM0GimrU2b6FJy1/mzoogsgAc3GKJiO6rB2Y9s470
         UMlA==
X-Gm-Message-State: APjAAAWmMpceZ3fev2z60Evs7PvhSnaOLoBlhlG/DCeSJ99dAyrafDZ2
	byjeNShaosuL+WROJnTxyMq1nfnwa7Q1VA0cnxn7Oo7VIknaNeGdsKtgR3U/lmP3RvzYdzC8zzX
	WF9DzyxZZ25ixX0SFwAycUddifTkJQUHhAXzSptBILDT017/x/bI6PL9qPJJC8It7vw==
X-Received: by 2002:a05:620a:1305:: with SMTP id o5mr36584426qkj.35.1553823812129;
        Thu, 28 Mar 2019 18:43:32 -0700 (PDT)
X-Received: by 2002:a05:620a:1305:: with SMTP id o5mr36584400qkj.35.1553823811000;
        Thu, 28 Mar 2019 18:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553823810; cv=none;
        d=google.com; s=arc-20160816;
        b=Xt2nP3FUhRwp1tbILp2dPJ/Gxi4TeWNM6kkb9HZCIHE4+l2IO68uHPNLL7oFdPiDzW
         5Suz2dJpEOhtTo4N338UOG/+6bUP/PgSW8LzlyVofGAIAdaSxCX+OoyTfWydMeLc7m3V
         rJbgEQ5RNxm1g8oIvuoxmlfaoT86Vbems8yww7U71n28O+fUXNh6u9X0sns5i0DtiqOa
         r8GF1wdlIifUJ3H+ePP0c0eMMegPqmvXS42m1+svuuucVZd2urVOgdoPjjue0kRkkgnZ
         x+OoqEGhykMsHLy5ZQCp5myO2lWgve44oOmV9W6QIhHE/PJvbAbM/lnSTDc6LAeAQ3OT
         81PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=gv6hWDFttTfp7Z+q9DmSrCaQCc0nzY2zjIjOCBbe07w=;
        b=gNaJlr6lO1XnBToYiPPenxkKIL/wH0WDrsIr/NwH0JaXWqm8SnsF4xRB3n6p84VjIx
         JBXIZsCiLaYhpcqyRR+iDq6auGq2w0WHZu7XUwp97AdIEXLyxl6C2HA8Jh2mDRECIFZm
         B4HHVXod/q76qAiSVbRuL+b4ldGDdQO/zOYJJcFOL4uGHuhBxeC3QYgFT5lur8D8eIJ+
         Lw1aYxQVRzN9VJ4+Hqo0gmfiJas7sdldgJgIh3r1im4JRrPjwTn3VVPuotT0drxGlcmY
         KkYh29+8KTe+oieMHo8dNCJIWZgj+xNUEe/O5BOaSnIFjxlee1rO5Jbb2IPtWdHfFKHk
         FRbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ArI8bkRo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m38sor651077qtm.37.2019.03.28.18.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 18:43:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ArI8bkRo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=gv6hWDFttTfp7Z+q9DmSrCaQCc0nzY2zjIjOCBbe07w=;
        b=ArI8bkRoP8Pu7YXvxFCaq/w2IWF4Qrck9PvQTkmB5OoAKmUO0wRqiC5YYz6BCoEYS4
         M3Oc2MB0em8qj76wsrYzhEYhUL/wXNzn7X23F7eRAaTCtuAc8oWy+uCvTZPDdz8CvGg8
         EIqhXzLWNbQaTXv0HcpC+OCjvQU1Ly8tWKPJEI3OA45u/44idRDFZGncdTJW3jzkpUhv
         TeXLGU1i47h2QBXPYjWdE0yqxvKeCP2aE481shxR+gAIMZ8CP1s7MmsJ1dESLup4xYK5
         KpqD6kAUAGYA29suS/s58/9xdta1F95fjBj4MO5yaUNOvjZhWh63NigR49YOiMpIY/cD
         MjfQ==
X-Google-Smtp-Source: APXvYqxrE88bXL0Ox1H+2qKUWqTKAYcEei6k3D8vsA9kzxYkCrDY9LP/bwcIUKZTTNFUNuNzKrwHbw==
X-Received: by 2002:aed:32e1:: with SMTP id z88mr31785334qtd.137.1553823810361;
        Thu, 28 Mar 2019 18:43:30 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id m4sm307370qtp.16.2019.03.28.18.43.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:43:29 -0700 (PDT)
Subject: Re: page cache: Store only head pages in i_pages
To: Matthew Wilcox <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
Date: Thu, 28 Mar 2019 21:43:29 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190324030422.GE10344@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/23/19 11:04 PM, Matthew Wilcox wrote> @@ -335,11 +335,12 @@ static inline
struct page *grab_cache_page_nowait(struct address_space *mapping,
>  
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
> +       unsigned long index = page_index(page);
> +
>         VM_BUG_ON_PAGE(PageTail(page), page);
> -       VM_BUG_ON_PAGE(page->index > offset, page);
> -       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> -                       page);
> -       return page - page->index + offset;
> +       VM_BUG_ON_PAGE(index > offset, page);
> +       VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> +       return page - index + offset;
>  }

Even with this patch, it is still able to trigger a panic below by running LTP
mm tests. Always triggered by oom02 (or oom04) at the end.

# /opt/ltp/runltp -f mm

The problem is that in scan_swap_map_slots(),

/* reuse swap entry of cache-only swap if not busy. */
	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
		int swap_was_freed;
		unlock_cluster(ci);
		spin_unlock(&si->lock);
		swap_was_freed = __try_to_reclaim_swap(si, offset, TTRS_ANYWAY);

but that swap entry has already been freed, and the page has PageSwapCache
cleared and page->private is 0.

swp_entry_t entry = swp_entry(si->type, offset)

and then in find_subpage(),

its page->index has a different meaning again and the calculation is now all wrong.

return page - page->index + offset;

[ 7439.033573] oom_reaper: reaped process 47172 (oom02), now anon-rss:0kB,
file-rss:0kB, shmem-rss:0kB
[ 7456.445737] LTP: starting oom03
[ 7456.535940] LTP: starting oom04
[ 7493.077222] page:ffffea00877a13c0 count:1 mapcount:0 mapping:ffff88a79061d009
index:0x7fa81584f
[ 7493.086963] anon
[ 7493.086968] flags: 0x15fffe00008005c(uptodate|dirty|lru|workingset|swapbacked)
[ 7493.097201] raw: 015fffe00008005c ffffea00b4bf9508 ffffea007f45efc8
ffff88a79061d009
[ 7493.105853] raw: 00000007fa81584f 0000000000000000 00000001ffffffff
ffff888f18278008
[ 7493.114504] page dumped because: VM_BUG_ON_PAGE(index + (1 <<
compound_order(page)) <= offset)
[ 7493.124126] page->mem_cgroup:ffff888f18278008
[ 7493.129036] page_owner info is not active (free page?)
[ 7493.134782] ------------[ cut here ]------------
[ 7493.139937] kernel BUG at include/linux/pagemap.h:342!
[ 7493.145682] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[ 7493.152679] CPU: 5 PID: 47308 Comm: oom04 Kdump: loaded Tainted: G        W
      5.1.0-rc2-mm1+ #13
[ 7493.163068] Hardware name: Lenovo ThinkSystem SR530
-[7X07RCZ000]-/-[7X07RCZ000]-, BIOS -[TEE113T-1.00]- 07/07/2017
[ 7493.174721] RIP: 0010:find_get_entry+0x751/0x9b0
[ 7493.179876] Code: c6 e0 aa a9 8d 4c 89 ff e8 3c 18 0d 00 0f 0b 48 c7 c7 20 40
02 8e e8 a3 17 58 00 48 c7 c6 40 ad a9 8d 4c 89 ff e8 1f 18 0d 00 <0f> 0b 48 c7
c7 e0 3f 02 8e e8 86 17 58 00 48 c7 c7 68 11 3f 8e e8
[ 7493.200834] RSP: 0000:ffff888d50536ba8 EFLAGS: 00010282
[ 7493.206666] RAX: 0000000000000000 RBX: 0000000000000001 RCX: ffffffff8cd6401e
[ 7493.214632] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff88979e8b5480
[ 7493.222599] RBP: ffff888d50536cb8 R08: ffffed12f3d16a91 R09: ffffed12f3d16a90
[ 7493.230566] R10: ffffed12f3d16a90 R11: ffff88979e8b5487 R12: ffffea00877a13c0
[ 7493.238531] R13: ffffea00877a13c8 R14: ffffea00877a13c8 R15: ffffea00877a13c0
[ 7493.246496] FS:  00007f248398c700(0000) GS:ffff88979e880000(0000)
knlGS:0000000000000000
[ 7493.255527] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7493.261942] CR2: 00007f3fde110000 CR3: 00000011b2fcc003 CR4: 00000000001606a0
[ 7493.269900] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 7493.277864] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 7493.285830] Call Trace:
[ 7493.288555]  ? queued_spin_lock_slowpath+0x571/0x9e0
[ 7493.294097]  ? __filemap_set_wb_err+0x1f0/0x1f0
[ 7493.299154]  pagecache_get_page+0x4a/0xb70
[ 7493.303729]  __try_to_reclaim_swap+0xa3/0x400
[ 7493.308593]  scan_swap_map_slots+0xc05/0x1850
[ 7493.313447]  ? __try_to_reclaim_swap+0x400/0x400
[ 7493.318600]  ? do_raw_spin_lock+0x128/0x280
[ 7493.323269]  ? rwlock_bug.part.0+0x90/0x90
[ 7493.327840]  ? get_swap_pages+0x195/0x730
[ 7493.332316]  get_swap_pages+0x386/0x730
[ 7493.336590]  get_swap_page+0x2b2/0x643
[ 7493.340774]  ? rmap_walk+0x140/0x140
[ 7493.344765]  ? free_swap_slot+0x3c0/0x3c0
[ 7493.349232]  ? anon_vma_ctor+0xe0/0xe0
[ 7493.353407]  ? page_get_anon_vma+0x280/0x280
[ 7493.358173]  add_to_swap+0x10b/0x230
[ 7493.362164]  shrink_page_list+0x29d8/0x4960
[ 7493.366822]  ? page_evictable+0x11b/0x1d0
[ 7493.371296]  ? page_evictable+0x1d0/0x1d0
[ 7493.375769]  ? __isolate_lru_page+0x880/0x880
[ 7493.380631]  ? __lock_acquire.isra.14+0x7d7/0x2130
[ 7493.385977]  ? shrink_inactive_list+0x484/0x13b0
[ 7493.391130]  ? lock_downgrade+0x760/0x760
[ 7493.395608]  ? kasan_check_read+0x11/0x20
[ 7493.400082]  ? do_raw_spin_unlock+0x59/0x250
[ 7493.404848]  shrink_inactive_list+0x4bf/0x13b0
[ 7493.409823]  ? move_pages_to_lru+0x1c90/0x1c90
[ 7493.414795]  ? kasan_check_read+0x11/0x20
[ 7493.419261]  ? lruvec_lru_size+0xef/0x4c0
[ 7493.423738]  ? call_function_interrupt+0xa/0x20
[ 7493.428800]  ? rcu_all_qs+0x11/0xc0
[ 7493.432692]  shrink_node_memcg+0x66a/0x1ee0
[ 7493.437361]  ? shrink_active_list+0x1150/0x1150
[ 7493.442417]  ? lock_downgrade+0x760/0x760
[ 7493.446891]  ? lock_acquire+0x169/0x360
[ 7493.451177]  ? mem_cgroup_iter+0x210/0xca0
[ 7493.455747]  ? kasan_check_read+0x11/0x20
[ 7493.460221]  ? mem_cgroup_protected+0x94/0x450
[ 7493.465179]  shrink_node+0x266/0x13c0
[ 7493.469267]  ? shrink_node_memcg+0x1ee0/0x1ee0
[ 7493.474230]  ? ktime_get+0xab/0x140
[ 7493.478122]  ? zone_reclaimable_pages+0x553/0x8d0
[ 7493.483371]  do_try_to_free_pages+0x349/0x11e0
[ 7493.488333]  ? allow_direct_reclaim.part.6+0xc3/0x240
[ 7493.493971]  ? shrink_node+0x13c0/0x13c0
[ 7493.498352]  ? queue_delayed_work_on+0x30/0x30
[ 7493.503313]  try_to_free_pages+0x277/0x740
[ 7493.507884]  ? __lock_acquire.isra.14+0x7d7/0x2130
[ 7493.513232]  ? do_try_to_free_pages+0x11e0/0x11e0
[ 7493.518482]  __alloc_pages_nodemask+0xc37/0x2ab0
[ 7493.523635]  ? gfp_pfmemalloc_allowed+0x150/0x150
[ 7493.528886]  ? __lock_acquire.isra.14+0x7d7/0x2130
[ 7493.534226]  ? __lock_acquire.isra.14+0x7d7/0x2130
[ 7493.539566]  ? do_anonymous_page+0x450/0x1e00
[ 7493.544419]  ? lock_downgrade+0x760/0x760
[ 7493.548896]  ? __lru_cache_add+0xc2/0x240
[ 7493.553372]  alloc_pages_vma+0xb2/0x430
[ 7493.557652]  do_anonymous_page+0x50a/0x1e00
[ 7493.562324]  ? put_prev_task_fair+0x27c/0x720
[ 7493.567189]  ? finish_fault+0x290/0x290
[ 7493.571471]  __handle_mm_fault+0x1688/0x3bc0
[ 7493.576227]  ? __lock_acquire.isra.14+0x7d7/0x2130
[ 7493.581574]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[ 7493.586824]  handle_mm_fault+0x326/0x6cf
[ 7493.591203]  __do_page_fault+0x333/0x8d0
[ 7493.595571]  do_page_fault+0x75/0x48e
[ 7493.599660]  ? page_fault+0x5/0x20
[ 7493.603458]  page_fault+0x1b/0x20
[ 7493.607156] RIP: 0033:0x410930
[ 7493.610564] Code: 89 de e8 53 26 ff ff 48 83 f8 ff 0f 84 86 00 00 00 48 89 c5
41 83 fc 02 74 28 41 83 fc 03 74 62 e8 05 2c ff ff 31 d2 48 98 90 <c6> 44 15 00
07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
[ 7493.631521] RSP: 002b:00007f248398bec0 EFLAGS: 00010206
[ 7493.637352] RAX: 0000000000001000 RBX: 00000000c0000000 RCX: 00007f42982ad497
[ 7493.645316] RDX: 000000002a9a3000 RSI: 00000000c0000000 RDI: 0000000000000000
[ 7493.653281] RBP: 00007f230298b000 R08: 00000000ffffffff R09: 0000000000000000
[ 7493.661245] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000000001
[ 7493.669209] R13: 00007ffc5b8a54ef R14: 0000000000000000 R15: 00007f248398bfc0
[ 7493.677176] Modules linked in: brd ext4 crc16 mbcache jbd2 overlay loop
nls_iso8859_1 nls_cp437 vfat fat kvm_intel kvm irqbypass efivars ip_tables
x_tables xfs sd_mod i40e ahci libahci megaraid_sas libata dm_mirror
dm_region_hash dm_log dm_mod efivarfs

