Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45407C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:10:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E032220840
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:10:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="E7C1anIb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E032220840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 806658E0003; Wed, 24 Jul 2019 14:10:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B6F36B000C; Wed, 24 Jul 2019 14:10:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4DB8E0003; Wed, 24 Jul 2019 14:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 481DC6B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:10:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s22so42085062qtb.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:10:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=AgQzBOtr/JltxPGhZk+AY96SUJ5Pcnx5e1/XHa6kQec=;
        b=sLsrOsUaTeKu+4v09qMOrI9difqMo4O9YaxkPnkoyYgKLkQhMrLkzCCyztsYAXtleG
         TeR2lTGomchbQpTZUBMGtDN4kemuc551UEuma2mQ2Jjj/GGgmBL7UibvYnsUUqExVOsN
         TC9Fm1BmOGVJGvmp021f71740xRdFerDEQKUKACzJU0ZvHXNimvsn0TutgFvfpJACnB1
         uahi8APIyDIIiP/JRZYPa3Ea9ZB79iQr5Wy2msT3bzDVkAIujDhBKugs/7D5DiyaSG2e
         OCBL9B+94xcMf9T0MFIvrhFvkcL3xR/afF/WEzTJ5keGfIqFGsUS1cl/RFRQTuwpUiqk
         tvMA==
X-Gm-Message-State: APjAAAX5S3A69t+okqiY1m9DJvCN83cJ6lTtykbs68uQxW/R1yk/pnvQ
	rLS9ZvzDGqK9mncpGoHh6ahvQBtbGFguQi+Zo1cLR2BTcC5f89/mIOki6730rMPOnDKfZeAgSgy
	sqv+yZvwwLioPVsa/H7Llp4F0HauGCINiiEF09yFi4mBvAK0BwAQ9zNZfdnZnqKuhPQ==
X-Received: by 2002:a37:9904:: with SMTP id b4mr52946890qke.159.1563991838021;
        Wed, 24 Jul 2019 11:10:38 -0700 (PDT)
X-Received: by 2002:a37:9904:: with SMTP id b4mr52946817qke.159.1563991836877;
        Wed, 24 Jul 2019 11:10:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563991836; cv=none;
        d=google.com; s=arc-20160816;
        b=FG6lNx1l+aCCse+PPxy+nPqrlABspy+N8BD2uJPGr1C17h/1elqoYD/QJNL/x4M2Pe
         UzI6i1wV8BSbre608w3+6tdOadoz1Z2XOX98hF1zlghmi9ldQXmbxpaWLagN/s7x9q1h
         VqvlHLEihCXnMLqzSyi6BrbxJDOGfblCs5BIANxvDVX7xxZR7nbC2f3iQTPzW6Wq16ww
         LerEpBr/yLFdZbaNGxLq42xJxoJDswzEfJ8Aw2KlgOiF4HQviJFMqrJrp/J3pT+YACax
         KtVxzhy/5cQJvX5AoMvRrzCDT2nmZhrLy4UzcYrbChJaklDe3XHVRin191AB1mwUJEr6
         Jy2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=AgQzBOtr/JltxPGhZk+AY96SUJ5Pcnx5e1/XHa6kQec=;
        b=G4oq94MgJlRbIKDPfs8a/BPrg8x5nQHpUx1ZFvZyH7MIlwn7SBcRnmKuw9sdXw6io3
         lGxoe36WeZEF7yoeQa7YWBaaJoWQSg6mYLwhYfSplDBemjSBvj4pmhJ8L+oyoj3bgXKM
         AH6Jl0it5Mgg6bvI8Fk5BvTl1o0JKsYkWWIa3jlWUhc0QpruApO9At5IdFzcX/xCz4wD
         pepKJsXJHYPDsy9Ygrd+Q1dVsxBTae0XA0Cq/gIBSaUx3IBocrzlUyohhSreLFfZUCyL
         GIEGeD/pMxArVtZR/Qj4HsAWt3TR7ivQhBs15kpv4MG5+Tfl5Z2C40OhJe1eTIlFQotf
         +K5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=E7C1anIb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c39sor62771854qtk.5.2019.07.24.11.10.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 11:10:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=E7C1anIb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AgQzBOtr/JltxPGhZk+AY96SUJ5Pcnx5e1/XHa6kQec=;
        b=E7C1anIbh2D5eFxSNCwrS3A3q2wjnylLIPRAOLxDzTUk7g5WeY1VwIwUicPunUsZav
         KURvM1QHIcL9XwRD8AVmuYLajHNaO4+851NJWFQbr5Fc4nK5JjW7en27a0UnmcZ9pMt1
         NBSbd+U/Xvfctp/OpgEl/KHCh5EI97JaEcdJESbf5g230hidlW51h/ebW3Annt2FcHMs
         94oM1u3p4R40n6fRcawQSiQNC3b65VolLJoT/4rXIVU1A7H2wpDTlcHe6EFIlI/riRcm
         7ByTDGObLiTMDXidvM9AQlU8aT5QSVtDR/URI4VP5jrpc/BmSIYGFI4G0X8U9cv98fPV
         58lw==
X-Google-Smtp-Source: APXvYqyHveJRhG4khKgd9sc+eZwBR0v18lWW5sPiVrZazsSvZMIHyOwwm+bV/IDRT62bRmJy6Qh+Rw==
X-Received: by 2002:aed:2a43:: with SMTP id k3mr59564766qtf.301.1563991836377;
        Wed, 24 Jul 2019 11:10:36 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k123sm19731462qkf.13.2019.07.24.11.10.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:10:35 -0700 (PDT)
Message-ID: <1563991833.11067.13.camel@lca.pw>
Subject: Re: list corruption in deferred_split_scan()
From: Qian Cai <cai@lca.pw>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
	 <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	linux-kernel@vger.kernel.org
Date: Wed, 24 Jul 2019 14:10:33 -0400
In-Reply-To: <7a0c0092-40d1-eede-14dd-3c4c052edf0c@linux.alibaba.com>
References: <1562795006.8510.19.camel@lca.pw>
	 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
	 <1562879229.8510.24.camel@lca.pw>
	 <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
	 <9F50D703-FF08-44FA-B1E5-4F8A2F8C7061@lca.pw>
	 <7a0c0092-40d1-eede-14dd-3c4c052edf0c@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-18 at 17:59 -0700, Yang Shi wrote:
> 
> On 7/18/19 5:54 PM, Qian Cai wrote:
> > 
> > > On Jul 12, 2019, at 3:12 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
> > > 
> > > 
> > > 
> > > On 7/11/19 2:07 PM, Qian Cai wrote:
> > > > On Wed, 2019-07-10 at 17:16 -0700, Yang Shi wrote:
> > > > > Hi Qian,
> > > > > 
> > > > > 
> > > > > Thanks for reporting the issue. But, I can't reproduce it on my
> > > > > machine.
> > > > > Could you please share more details about your test? How often did you
> > > > > run into this problem?
> > > > 
> > > > I can almost reproduce it every time on a HPE ProLiant DL385 Gen10
> > > > server. Here
> > > > is some more information.
> > > > 
> > > > # cat .config
> > > > 
> > > > https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config
> > > 
> > > I tried your kernel config, but I still can't reproduce it. My compiler
> > > doesn't have retpoline support, so CONFIG_RETPOLINE is disabled in my
> > > test, but I don't think this would make any difference for this case.
> > > 
> > > According to the bug call trace in the earlier email, it looks deferred
> > > _split_scan lost race with put_compound_page. The put_compound_page would
> > > call free_transhuge_page() which delete the page from the deferred split
> > > queue, but it may still appear on the deferred list due to some reason.
> > > 
> > > Would you please try the below patch?
> > > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index b7f709d..66bd9db 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -2765,7 +2765,7 @@ int split_huge_page_to_list(struct page *page,
> > > struct list_head *list)
> > >          if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
> > >                  if (!list_empty(page_deferred_list(head))) {
> > >                          ds_queue->split_queue_len--;
> > > -                       list_del(page_deferred_list(head));
> > > +                       list_del_init(page_deferred_list(head));
> > >                  }
> > >                  if (mapping)
> > >                          __dec_node_page_state(page, NR_SHMEM_THPS);
> > > @@ -2814,7 +2814,7 @@ void free_transhuge_page(struct page *page)
> > >          spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> > >          if (!list_empty(page_deferred_list(page))) {
> > >                  ds_queue->split_queue_len--;
> > > -               list_del(page_deferred_list(page));
> > > +               list_del_init(page_deferred_list(page));
> > >          }
> > >          spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
> > >          free_compound_page(page);
> > 
> > Unfortunately, I am no longer be able to reproduce the original list
> > corruption with today’s linux-next.
> 
> It is because the patches have been dropped from -mm tree by Andrew due 
> to this problem I guess. You have to use next-20190711, or apply the 
> patches on today's linux-next.
> 

The patch you have here does not help. Only applied the part for
free_transhuge_page() as you requested.

[  375.006307][ T3580] list_del corruption. next->prev should be
ffffea0030e10098, but was ffff888ea8d0cdb8
[  375.015928][ T3580] ------------[ cut here ]------------
[  375.021296][ T3580] kernel BUG at lib/list_debug.c:56!
[  375.026491][ T3580] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
[  375.033680][ T3580] CPU: 84 PID: 3580 Comm: oom01 Tainted:
G        W         5.2.0-next-20190711+ #2
[  375.042964][ T3580] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  375.052256][ T3580] RIP: 0010:__list_del_entry_valid+0xa8/0xb6
[  375.058135][ T3580] Code: de 48 c7 c7 c0 5a b3 b0 e8 b9 fa bc ff 0f 0b 48 c7
c7 60 a0 21 b1 e8 13 52 01 00 4c 89 e6 48 c7 c7 20 5b b3 b0 e8 9c fa bc ff <0f>
0b 48 c7 c7 20 a0 21 b1 e8 f6 51 01 00 4c 89 ea 48 89 de 48 c7
[  375.077722][ T3580] RSP: 0018:ffff888ebc4b73c0 EFLAGS: 00010082
[  375.083684][ T3580] RAX: 0000000000000054 RBX: ffffea0030e10098 RCX:
ffffffffb015d728
[  375.091566][ T3580] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
ffff88903263d380
[  375.099448][ T3580] RBP: ffff888ebc4b73d8 R08: ffffed12064c7a71 R09:
ffffed12064c7a70
[  375.107330][ T3580] R10: ffffed12064c7a70 R11: ffff88903263d387 R12:
ffffea0030e10098
[  375.115212][ T3580] R13: ffffea0031d40098 R14: ffffea0030e10034 R15:
ffffea0031d40098
[  375.123095][ T3580] FS:  00007fc3dc851700(0000) GS:ffff889032600000(0000)
knlGS:0000000000000000
[  375.131937][ T3580] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  375.138421][ T3580] CR2: 00007fc25fa39000 CR3: 0000000884762000 CR4:
00000000001406a0
[  375.146301][ T3580] Call Trace:
[  375.149472][ T3580]  deferred_split_scan+0x337/0x740
[  375.154475][ T3580]  ? split_huge_page_to_list+0xe30/0xe30
[  375.160002][ T3580]  ? __sched_text_start+0x8/0x8
[  375.164743][ T3580]  ? __radix_tree_lookup+0x12d/0x1e0
[  375.169923][ T3580]  do_shrink_slab+0x244/0x5a0
[  375.174490][ T3580]  shrink_slab+0x253/0x440
[  375.178794][ T3580]  ? unregister_shrinker+0x110/0x110
[  375.183972][ T3580]  ? kasan_check_read+0x11/0x20
[  375.188715][ T3580]  ? mem_cgroup_protected+0x20f/0x260
[  375.193976][ T3580]  ? shrink_node+0x1ad/0xa30
[  375.198453][ T3580]  shrink_node+0x31e/0xa30
[  375.202755][ T3580]  ? shrink_node_memcg+0x1560/0x1560
[  375.207934][ T3580]  ? ktime_get+0x93/0x110
[  375.212147][ T3580]  do_try_to_free_pages+0x22f/0x820
[  375.217236][ T3580]  ? shrink_node+0xa30/0xa30
[  375.221711][ T3580]  ? kasan_check_read+0x11/0x20
[  375.226450][ T3580]  ? check_chain_key+0x1df/0x2e0
[  375.231277][ T3580]  try_to_free_pages+0x242/0x4d0
[  375.236102][ T3580]  ? do_try_to_free_pages+0x820/0x820
[  375.241370][ T3580]  __alloc_pages_nodemask+0x9ce/0x1bc0
[  375.246721][ T3580]  ? kasan_check_read+0x11/0x20
[  375.251459][ T3580]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  375.256722][ T3580]  ? kasan_check_read+0x11/0x20
[  375.261458][ T3580]  ? check_chain_key+0x1df/0x2e0
[  375.266287][ T3580]  ? do_anonymous_page+0x343/0xe30
[  375.271289][ T3580]  ? lock_downgrade+0x390/0x390
[  375.276029][ T3580]  ? __count_memcg_events+0x8b/0x1c0
[  375.281204][ T3580]  ? kasan_check_read+0x11/0x20
[  375.285945][ T3580]  ? __lru_cache_add+0x122/0x160
[  375.290774][ T3580]  alloc_pages_vma+0x89/0x2c0
[  375.295339][ T3580]  do_anonymous_page+0x3e1/0xe30
[  375.300168][ T3580]  ? __update_load_avg_cfs_rq+0x2c/0x490
[  375.305692][ T3580]  ? finish_fault+0x120/0x120
[  375.310257][ T3580]  ? alloc_pages_vma+0x21e/0x2c0
[  375.315085][ T3580]  handle_pte_fault+0x457/0x12c0
[  375.319912][ T3580]  __handle_mm_fault+0x79a/0xa50
[  375.324738][ T3580]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[  375.330175][ T3580]  ? kasan_check_read+0x11/0x20
[  375.334913][ T3580]  ? __count_memcg_events+0x8b/0x1c0
[  375.340090][ T3580]  handle_mm_fault+0x17f/0x370
[  375.344745][ T3580]  __do_page_fault+0x25b/0x5d0
[  375.349398][ T3580]  do_page_fault+0x4c/0x2cf
[  375.353793][ T3580]  ? page_fault+0x5/0x20
[  375.357920][ T3580]  page_fault+0x1b/0x20
[  375.361959][ T3580] RIP: 0033:0x410be0
[  375.365737][ T3580] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00 00
48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90 <c6>
44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
[  375.385323][ T3580] RSP: 002b:00007fc3dc850ec0 EFLAGS: 00010206
[  375.391283][ T3580] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
00007fda6c168497
[  375.399164][ T3580] RDX: 00000000041e9000 RSI: 00000000c0000000 RDI:
0000000000000000
[  375.407047][ T3580] RBP: 00007fc25b850000 R08: 00000000ffffffff R09:
0000000000000000
[  375.414928][ T3580] R10: 0000000000000022 R11: 0000000000000246 R12:
0000000000000001
[  375.422812][ T3580] R13: 00007ffc4a58701f R14: 0000000000000000 R15:
00007fc3dc850fc0
[  375.430694][ T3580] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat
kvm_amd kvm ses enclosure irqbypass dax_pmem dax_pmem_core efivars ip_tables
x_tables xfs sd_mod smartpqi scsi_transport_sas mlx5_core tg3 firmware_class
libphy dm_mirror dm_region_hash dm_log dm_mod efivarfs
[  375.455820][ T3580] ---[ end trace 82d52f9627313e53 ]---
[  375.461172][ T3580] RIP: 0010:__list_del_entry_valid+0xa8/0xb6
[  375.467048][ T3580] Code: de 48 c7 c7 c0 5a b3 b0 e8 b9 fa bc ff 0f 0b 48 c7
c7 60 a0 21 b1 e8 13 52 01 00 4c 89 e6 48 c7 c7 20 5b b3 b0 e8 9c fa bc ff <0f>
0b 48 c7 c7 20 a0 21 b1 e8 f6 51 01 00 4c 89 ea 48 89 de 48 c7
[  375.486635][ T3580] RSP: 0018:ffff888ebc4b73c0 EFLAGS: 00010082
[  375.492597][ T3580] RAX: 0000000000000054 RBX: ffffea0030e10098 RCX:
ffffffffb015d728
[  375.500479][ T3580] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
ffff88903263d380
[  375.508361][ T3580] RBP: ffff888ebc4b73d8 R08: ffffed12064c7a71 R09:
ffffed12064c7a70
[  375.516244][ T3580] R10: ffffed12064c7a70 R11: ffff88903263d387 R12:
ffffea0030e10098
[  375.524124][ T3580] R13: ffffea0031d40098 R14: ffffea0030e10034 R15:
ffffea0031d40098
[  375.532007][ T3580] FS:  00007fc3dc851700(0000) GS:ffff889032600000(0000)
knlGS:0000000000000000
[  375.540851][ T3580] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  375.547335][ T3580] CR2: 00007fc25fa39000 CR3: 0000000884762000 CR4:
00000000001406a0
[  375.555217][ T3580] Kernel panic - not syncing: Fatal exception
[  376.868640][ T3580] Shutting down cpus with NMI
[  376.873223][ T3580] Kernel Offset: 0x2ec00000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  376.884878][ T3580] ---[ end Kernel panic - not syncing: Fatal exception ]---

