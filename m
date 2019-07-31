Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95136C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E71D206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:18:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Qkkh4TXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E71D206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 976538E0003; Wed, 31 Jul 2019 14:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 925928E0001; Wed, 31 Jul 2019 14:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 814E28E0003; Wed, 31 Jul 2019 14:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAA28E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:18:05 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id r11so7190709uao.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=xq7asWV9enZYyP/JFrfdHu/SisztJs8JYG8FHXUKQkA=;
        b=ZreNrz8BOMsXzwx6fsSg+l5mex2epFTHDPz6/7ToLvCWLRN3AtSxF1y6q6EDwgucXz
         Meu48Gy4sCqO/TEbVQguq90esgOPOHKKWtIdPfcugIeXGEm6wIO2Retn/1M3szEeQMb3
         mQuTFQSgLf64uKEnVfoc6k+gOqqHeZ3vsbhXnfImnpBpYG6Z/pTy6AdN91wBNQ2zYh+z
         hidV6nu0TO0fUC2f1u1x/6Ah8zf+Q2vaEcyNKVBgu+pRFM1PZvQBKZhvw49gH92zfJDK
         k1+UBFtt+9FGicG0fIRrVPPmY74vrw33RtsP9Pza/i0qbfMW5f5MmaqexNQDCLvUNO/T
         ZHNw==
X-Gm-Message-State: APjAAAXTHMr1NDqinx04UQl8KZ/Csthgfygu9Fc3WgA6ifs7BjDQ5DXI
	s/3AEBBr3G3fyMr07zz27xIxSIV5Ygisv5wqRkVHLnO3eHviLzx2K4yLGoOrgt1p9CGoNbxwKd0
	VAupy+WVmtwmLCfh7ONYORxrs7WA2wWD4QWhSMWq2SSLajU5VIcU34U9Wscd4j5BgCA==
X-Received: by 2002:a67:f75a:: with SMTP id w26mr19940686vso.148.1564597085078;
        Wed, 31 Jul 2019 11:18:05 -0700 (PDT)
X-Received: by 2002:a67:f75a:: with SMTP id w26mr19940557vso.148.1564597084016;
        Wed, 31 Jul 2019 11:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564597084; cv=none;
        d=google.com; s=arc-20160816;
        b=jI+khXtPRFyuMCd0hRmBi+cpDlwVVKI/cACvvQ1KQ9gxX0Mvo8HP5+My8N2Kw+MQlZ
         fq57SMJSMPQorHw98Nth3jn413cz0Kf3aPimKwggU3j9rqRQdCjNwDmwfxFnF7QT0bla
         6843y0FL5ZafUUJrgtHn245lbTbgUNADzrDFq257Zg3WJ6TCeG3TSyBzmv1ZZ9hKRnkz
         MKRbonCDfqaFwYy88RAtxNUiuuFq3WvcFmQmuKnbJkd8p8ktEJ8ZwZm2uxtlpypQjfTw
         NPpaJoL8Vz+IGRdUPFknLfu7I5VTK7Ce2Js8udaftu+4r816GR4IRFDQcw7e39X06XEw
         6p/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=xq7asWV9enZYyP/JFrfdHu/SisztJs8JYG8FHXUKQkA=;
        b=PFmunBbJCS/MC4nDG+PGMaIe2nhPKLswIOFQv+9Ba62ypQSY6lfla6pYAMm7l+0ptV
         chs8uc1G97BUDkH41A1BEbyETwoAiSviB8klw9iOK86agFTZiFemA5JvAVZjXKHxBDou
         mQdKiBM+u4yqeFEPog2XQBcUaq8qT8h49VNarCCkc1AOhNcySsmV8cO5DvnfPhptI2Uu
         U60MLeDpNXKaKSh3qgdihATMQ9fdMxB1L9XZMpJmy797//EnwhyFBb6CyVbP/f0zVxvr
         ZgmjFpeAd0rJ2z1IvZNHWhc2oMLPcK54+CpdLVecCg3jr4IOrTc2eC5oBMT5qQ49p1A2
         tcog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Qkkh4TXG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z24sor33907471vsi.90.2019.07.31.11.18.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 11:18:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Qkkh4TXG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xq7asWV9enZYyP/JFrfdHu/SisztJs8JYG8FHXUKQkA=;
        b=Qkkh4TXGHzfBtf7FqHuQlOAynXRwYeZv0+8dSUorDXYIv780ZV8+oQJmzUkuJjdEmd
         4KjnaawL6OfiOq4FwPg+4iCxjwMQ3Zh31cdUkbQB3h5ByUdy5sWV+pLM/JckQo+FCgZR
         hllZ9MNtRZzfGczBp+D3SEoy2AFC79z3twAB0hxuY8Wa9x6A11bdWpGIYWcMfSQ76K5f
         WK+BkNE+ADdBUuPhxNrrKzHs+7EBLQ89YazbtFrHXExKHphO+jcY5/IilYa9+YccQs3l
         GyOF6bQGtgvxc+WQul4J4Vj8Dtd/KJiwQBFs+5xr9Np4PLtwT1GIvfZ63aF4Zznp3uBG
         Hb6g==
X-Google-Smtp-Source: APXvYqxp0+gSxtQwZIg+q52kd8Ws3epzfVnOJ4HD7nQQMO76nyBiwXdLT7+uxAJrvbSRX/G3lmZ3wA==
X-Received: by 2002:a67:e9d9:: with SMTP id q25mr15661344vso.74.1564597083359;
        Wed, 31 Jul 2019 11:18:03 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g66sm18115319vkh.7.2019.07.31.11.18.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 11:18:02 -0700 (PDT)
Message-ID: <1564597080.11067.40.camel@lca.pw>
Subject: Re: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
 breaks OOM with swap
From: Qian Cai <cai@lca.pw>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 31 Jul 2019 14:18:00 -0400
In-Reply-To: <1564589346.11067.38.camel@lca.pw>
References: <1564503928.11067.32.camel@lca.pw>
	 <20190731053444.GA155569@google.com> <1564589346.11067.38.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-31 at 12:09 -0400, Qian Cai wrote:
> On Wed, 2019-07-31 at 14:34 +0900, Minchan Kim wrote:
> > On Tue, Jul 30, 2019 at 12:25:28PM -0400, Qian Cai wrote:
> > > OOM workloads with swapping is unable to recover with linux-next since
> > > next-
> > > 20190729 due to the commit "mm: account nr_isolated_xxx in
> > > [isolate|putback]_lru_page" breaks OOM with swap" [1]
> > > 
> > > [1] https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kerne
> > > l.
> > > org/
> > > T/#mdcd03bcb4746f2f23e6f508c205943726aee8355
> > > 
> > > For example, LTP oom01 test case is stuck for hours, while it finishes in
> > > a
> > > few
> > > minutes here after reverted the above commit. Sometimes, it prints those
> > > message
> > > while hanging.
> > > 
> > > [  509.983393][  T711] INFO: task oom01:5331 blocked for more than 122
> > > seconds.
> > > [  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
> > > [  509.983447][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > > disables this message.
> > > [  509.983477][  T711] oom01           D24656  5331   5157 0x00040000
> > > [  509.983513][  T711] Call Trace:
> > > [  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8
> > > (unreliable)
> > > [  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
> > > __switch_to+0x3a4/0x520
> > > [  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
> > > __schedule+0x2fc/0x950
> > > [  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68]
> > > schedule+0x58/0x150
> > > [  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
> > > rwsem_down_read_slowpath+0x4b4/0x630
> > > [  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
> > > down_read+0x12c/0x240
> > > [  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
> > > __do_page_fault+0x6f8/0xee0
> > > [  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
> > > handle_page_fault+0x18/0x38
> > 
> > Thanks for the testing! No surprise the patch make some bugs because
> > it's rather tricky.
> > 
> > Could you test this patch?
> 
> It does help the situation a bit, but the recover speed is still way slower
> than
> just reverting the commit "mm: account nr_isolated_xxx in
> [isolate|putback]_lru_page". For example, on this powerpc system, it used to
> take 4-min to finish oom01 while now still take 13-min.
> 
> The oom02 (testing NUMA mempolicy) takes even longer and I gave up after 26-
> min
> with several hang tasks below.

Also, oom02 is stuck on an x86 machine.

[10327.974285][  T197] INFO: task oom02:29546 can't die for more than 122
seconds.
[10327.981654][  T197] oom02           D22576 29546  29536 0x00004006
[10327.987928][  T197] Call Trace:
[10327.991237][  T197]  __schedule+0x495/0xb50
[10327.995481][  T197]  ? __sched_text_start+0x8/0x8
[10328.000230][  T197]  ? __debug_check_no_obj_freed+0x250/0x250
[10328.006036][  T197]  schedule+0x5d/0x140
[10328.009994][  T197]  schedule_timeout+0x23f/0x380
[10328.014752][  T197]  ? mem_cgroup_uncharge+0x110/0x110
[10328.020103][  T197]  ? usleep_range+0x100/0x100
[10328.024691][  T197]  ? del_timer_sync+0xa0/0xa0
[10328.029257][  T197]  ? shrink_active_list+0x825/0x9d0
[10328.034362][  T197]  ? msleep+0x23/0x70
[10328.038228][  T197]  msleep+0x58/0x70
[10328.042090][  T197]  shrink_inactive_list+0x5cf/0x730
[10328.047197][  T197]  ? move_pages_to_lru+0xc70/0xc70
[10328.052205][  T197]  ? cpumask_next+0x35/0x40
[10328.056611][  T197]  ? lruvec_lru_size+0x12d/0x3a0
[10328.061445][  T197]  ? __kasan_check_read+0x11/0x20
[10328.066530][  T197]  ? inactive_list_is_low+0x2b9/0x410
[10328.071796][  T197]  shrink_node_memcg+0x4ff/0x1560
[10328.076740][  T197]  ? shrink_active_list+0x9d0/0x9d0
[10328.081834][  T197]  ? f_getown+0x70/0x70
[10328.085900][  T197]  ? mem_cgroup_iter+0x135/0x840
[10328.090874][  T197]  ? mem_cgroup_iter+0x18e/0x840
[10328.095726][  T197]  ? __kasan_check_read+0x11/0x20
[10328.100641][  T197]  ? mem_cgroup_protected+0x215/0x260
[10328.105929][  T197]  shrink_node+0x1d3/0xa30
[10328.110233][  T197]  ? shrink_node_memcg+0x1560/0x1560
[10328.115671][  T197]  ? __kasan_check_read+0x11/0x20
[10328.120586][  T197]  do_try_to_free_pages+0x22f/0x820
[10328.125693][  T197]  ? shrink_node+0xa30/0xa30
[10328.130173][  T197]  ? __kasan_check_read+0x11/0x20
[10328.135113][  T197]  ? check_chain_key+0x1df/0x2e0
[10328.139942][  T197]  try_to_free_pages+0x242/0x4d0
[10328.144938][  T197]  ? do_try_to_free_pages+0x820/0x820
[10328.150209][  T197]  __alloc_pages_nodemask+0x9ce/0x1bc0
[10328.155589][  T197]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[10328.160853][  T197]  ? __kasan_check_read+0x11/0x20
[10328.166007][  T197]  ? check_chain_key+0x1df/0x2e0
[10328.170839][  T197]  ? do_anonymous_page+0x33c/0xde0
[10328.175869][  T197]  alloc_pages_vma+0x89/0x2c0
[10328.180439][  T197]  do_anonymous_page+0x3d8/0xde0
[10328.185288][  T197]  ? finish_fault+0x120/0x120
[10328.189857][  T197]  ? alloc_pages_vma+0x9a/0x2c0
[10328.194746][  T197]  handle_pte_fault+0x457/0x12c0
[10328.199577][  T197]  __handle_mm_fault+0x79a/0xa50
[10328.204431][  T197]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[10328.209876][  T197]  ? __kasan_check_read+0x11/0x20
[10328.214816][  T197]  ? __count_memcg_events+0x56/0x1d0
[10328.220201][  T197]  handle_mm_fault+0x17f/0x370
[10328.224881][  T197]  __do_page_fault+0x25b/0x5d0
[10328.229538][  T197]  do_page_fault+0x50/0x2d3
[10328.233957][  T197]  page_fault+0x2c/0x40
[10328.238004][  T197] RIP: 0033:0x410c50
[10328.241951][  T197] Code: Bad RIP value.
[10328.245927][  T197] RSP: 002b:00007f27f0afcec0 EFLAGS: 00010206
[10328.251892][  T197] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
00007f2d34bfd497
[10328.259792][  T197] RDX: 00000000224ed000 RSI: 00000000c0000000 RDI:
0000000000000000
[10328.267845][  T197] RBP: 00007f266fafc000 R08: 00000000ffffffff R09:
0000000000000000
[10328.275752][  T197] R10: 0000000000000022 R11: 0000000000000246 R12:
0000000000000001
[10328.283635][  T197] R13: 00007fff5d124f9f R14: 0000000000000000 R15:
00007f27f0afcfc0
[10328.291696][  T197] INFO: task oom02:29554 can't die for more than 123
seconds.
[10328.299088][  T197] oom02           D22576 29554  29536 0x00004006
[10328.305348][  T197] Call Trace:
[10328.308519][  T197]  __schedule+0x495/0xb50
[10328.312737][  T197]  ? __sched_text_start+0x8/0x8
[10328.317706][  T197]  ? __debug_check_no_obj_freed+0x250/0x250
[10328.323497][  T197]  schedule+0x5d/0x140
[10328.327475][  T197]  schedule_timeout+0x23f/0x380
[10328.332217][  T197]  ? mem_cgroup_uncharge+0x110/0x110
[10328.337421][  T197]  ? usleep_range+0x100/0x100
[10328.342184][  T197]  ? del_timer_sync+0xa0/0xa0
[10328.346778][  T197]  ? shrink_active_list+0x825/0x9d0
[10328.351874][  T197]  ? msleep+0x23/0x70
[10328.355766][  T197]  msleep+0x58/0x70
[10328.359460][  T197]  shrink_inactive_list+0x5cf/0x730
[10328.364576][  T197]  ? move_pages_to_lru+0xc70/0xc70
[10328.369748][  T197]  ? cpumask_next+0x35/0x40
[10328.374158][  T197]  ? lruvec_lru_size+0x12d/0x3a0
[10328.378986][  T197]  ? __kasan_check_read+0x11/0x20
[10328.383927][  T197]  ? inactive_list_is_low+0x2b9/0x410
[10328.389195][  T197]  shrink_node_memcg+0x4ff/0x1560
[10328.394309][  T197]  ? shrink_active_list+0x9d0/0x9d0
[10328.399400][  T197]  ? f_getown+0x70/0x70
[10328.403445][  T197]  ? mem_cgroup_iter+0x135/0x840
[10328.408298][  T197]  ? mem_cgroup_iter+0x18e/0x840
[10328.413127][  T197]  ? __kasan_check_read+0x11/0x20
[10328.418306][  T197]  ? mem_cgroup_protected+0x215/0x260
[10328.423572][  T197]  shrink_node+0x1d3/0xa30
[10328.427899][  T197]  ? shrink_node_memcg+0x1560/0x1560
[10328.433080][  T197]  ? __kasan_check_read+0x11/0x20
[10328.438019][  T197]  do_try_to_free_pages+0x22f/0x820
[10328.443233][  T197]  ? shrink_node+0xa30/0xa30
[10328.447739][  T197]  ? __kasan_check_read+0x11/0x20
[10328.452655][  T197]  ? check_chain_key+0x1df/0x2e0
[10328.457507][  T197]  try_to_free_pages+0x242/0x4d0
[10328.462334][  T197]  ? do_try_to_free_pages+0x820/0x820
[10328.467848][  T197]  __alloc_pages_nodemask+0x9ce/0x1bc0
[10328.473205][  T197]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[10328.478494][  T197]  ? __kasan_check_read+0x11/0x20
[10328.483410][  T197]  ? check_chain_key+0x1df/0x2e0
[10328.488266][  T197]  ? do_anonymous_page+0x33c/0xde0
[10328.493409][  T197]  alloc_pages_vma+0x89/0x2c0
[10328.498004][  T197]  do_anonymous_page+0x3d8/0xde0
[10328.502834][  T197]  ? finish_fault+0x120/0x120
[10328.507424][  T197]  ? alloc_pages_vma+0x9a/0x2c0
[10328.512167][  T197]  handle_pte_fault+0x457/0x12c0
[10328.517261][  T197]  __handle_mm_fault+0x79a/0xa50
[10328.522093][  T197]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[10328.527556][  T197]  ? __kasan_check_read+0x11/0x20
[10328.532473][  T197]  ? __count_memcg_events+0x56/0x1d0
[10328.537678][  T197]  handle_mm_fault+0x17f/0x370
[10328.542484][  T197]  __do_page_fault+0x25b/0x5d0
[10328.547164][  T197]  do_page_fault+0x50/0x2d3
[10328.551557][  T197]  page_fault+0x2c/0x40
[10328.555624][  T197] RIP: 0033:0x410c50
[10328.559405][  T197] Code: Bad RIP value.
[10328.563358][  T197] RSP: 002b:00007f21ecaf4ec0 EFLAGS: 00010206
[10328.569438][  T197] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
00007f2d34bfd497
[10328.577349][  T197] RDX: 000000001aeb4000 RSI: 00000000c0000000 RDI:
0000000000000000
[10328.585253][  T197] RBP: 00007f206baf4000 R08: 00000000ffffffff R09:
0000000000000000
[10328.593292][  T197] R10: 0000000000000022 R11: 0000000000000246 R12:
0000000000000001
[10328.601201][  T197] R13: 00007fff5d124f9f R14: 0000000000000000 R15:
00007f21ecaf4fc0
[10328.609120][  T197] 
[10328.609120][  T197] Showing all locks held in the system:
[10328.617052][  T197] 1 lock held by khungtaskd/197:
[10328.621878][  T197]  #0: 000000002d9f974d (rcu_read_lock){....}, at:
debug_show_all_locks+0x33/0x165
[10328.631211][  T197] 2 locks held by oom02/29546:
[10328.635888][  T197]  #0: 0000000031e5d1a8 (&mm->mmap_sem#2){....}, at:
__do_page_fault+0x166/0x5d0
[10328.645093][  T197]  #1: 00000000e060a0f6 (fs_reclaim){....}, at:
fs_reclaim_acquire.part.15+0x5/0x30
[10328.654418][  T197] 2 locks held by oom02/29554:
[10328.659070][  T197]  #0: 0000000031e5d1a8 (&mm->mmap_sem#2){....}, at:
__do_page_fault+0x166/0x5d0
[10328.668286][  T197]  #1: 00000000e060a0f6 (fs_reclaim){....}, at:
fs_reclaim_acquire.part.15+0x5/0x30
[10328.677608][  T197] 
[10328.679812][  T197] =============================================
[10328.679812][  T197] 
[10450.864064][  T197] INFO: task oom02:29546 can't die for more than 245
seconds.
[10450.871642][  T197] oom02           D22576 29546  29536 0x00004006
[10450.877912][  T197] Call Trace:
[10450.881087][  T197]  __schedule+0x495/0xb50
[10450.885330][  T197]  ? __sched_text_start+0x8/0x8
[10450.890072][  T197]  ? __debug_check_no_obj_freed+0x250/0x250
[10450.896031][  T197]  schedule+0x5d/0x140
[10450.899989][  T197]  schedule_timeout+0x23f/0x380
[10450.904753][  T197]  ? mem_cgroup_uncharge+0x110/0x110
[10450.909936][  T197]  ? usleep_range+0x100/0x100
[10450.914526][  T197]  ? del_timer_sync+0xa0/0xa0
[10450.919314][  T197]  ? shrink_active_list+0x825/0x9d0
[10450.924428][  T197]  ? msleep+0x23/0x70
[10450.928296][  T197]  msleep+0x58/0x70
[10450.931991][  T197]  shrink_inactive_list+0x5cf/0x730
[10450.937103][  T197]  ? move_pages_to_lru+0xc70/0xc70
[10450.942254][  T197]  ? cpumask_next+0x35/0x40
[10450.946678][  T197]  ? lruvec_lru_size+0x12d/0x3a0
[10450.951512][  T197]  ? __kasan_check_read+0x11/0x20
[10450.956444][  T197]  ? inactive_list_is_low+0x2b9/0x410
[10450.961711][  T197]  shrink_node_memcg+0x4ff/0x1560
[10450.966650][  T197]  ? shrink_active_list+0x9d0/0x9d0
[10450.971929][  T197]  ? f_getown+0x70/0x70
[10450.975988][  T197]  ? mem_cgroup_iter+0x135/0x840
[10450.980821][  T197]  ? mem_cgroup_iter+0x18e/0x840
[10450.985672][  T197]  ? __kasan_check_read+0x11/0x20
[10450.990591][  T197]  ? mem_cgroup_protected+0x215/0x260
[10450.996050][  T197]  shrink_node+0x1d3/0xa30
[10451.000361][  T197]  ? shrink_node_memcg+0x1560/0x1560
[10451.005561][  T197]  ? __kasan_check_read+0x11/0x20
[10451.010477][  T197]  do_try_to_free_pages+0x22f/0x820
[10451.015589][  T197]  ? shrink_node+0xa30/0xa30
[10451.020293][  T197]  ? __kasan_check_read+0x11/0x20
[10451.025232][  T197]  ? check_chain_key+0x1df/0x2e0
[10451.030059][  T197]  try_to_free_pages+0x242/0x4d0
[10451.034910][  T197]  ? do_try_to_free_pages+0x820/0x820
[10451.040180][  T197]  __alloc_pages_nodemask+0x9ce/0x1bc0
[10451.045732][  T197]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[10451.050999][  T197]  ? __kasan_check_read+0x11/0x20
[10451.055936][  T197]  ? check_chain_key+0x1df/0x2e0
[10451.060767][  T197]  ? do_anonymous_page+0x33c/0xde0
[10451.065796][  T197]  alloc_pages_vma+0x89/0x2c0
[10451.070521][  T197]  do_anonymous_page+0x3d8/0xde0
[10451.075372][  T197]  ? finish_fault+0x120/0x120
[10451.079941][  T197]  ? alloc_pages_vma+0x9a/0x2c0
[10451.084703][  T197]  handle_pte_fault+0x457/0x12c0
[10451.089536][  T197]  __handle_mm_fault+0x79a/0xa50
[10451.094557][  T197]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[10451.100001][  T197]  ? __kasan_check_read+0x11/0x20
[10451.104938][  T197]  ? __count_memcg_events+0x56/0x1d0
[10451.110118][  T197]  handle_mm_fault+0x17f/0x370
[10451.114789][  T197]  __do_page_fault+0x25b/0x5d0
[10451.119661][  T197]  do_page_fault+0x50/0x2d3
[10451.124077][  T197]  page_fault+0x2c/0x40
[10451.128118][  T197] RIP: 0033:0x410c50
[10451.131901][  T197] Code: Bad RIP value.
[10451.135871][  T197] RSP: 002b:00007f27f0afcec0 EFLAGS: 00010206
[10451.141979][  T197] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
00007f2d34bfd497
[10451.149881][  T197] RDX: 00000000224ed000 RSI: 00000000c0000000 RDI:
0000000000000000
[10451.157786][  T197] RBP: 00007f266fafc000 R08: 00000000ffffffff R09:
0000000000000000
[10451.165694][  T197] R10: 0000000000000022 R11: 0000000000000246 R12:
0000000000000001
[10451.173741][  T197] R13: 00007fff5d124f9f R14: 0000000000000000 R15:
00007f27f0afcfc0
[10451.181656][  T197] 
[10451.181656][  T197] Showing all locks held in the system:
[10451.189350][  T197] 1 lock held by khungtaskd/197:
[10451.194369][  T197]  #0: 000000002d9f974d (rcu_read_lock){....}, at:
debug_show_all_locks+0x33/0x165
[10451.203670][  T197] 2 locks held by oom02/29546:
[10451.208344][  T197]  #0: 0000000031e5d1a8 (&mm->mmap_sem#2){....}, at:
__do_page_fault+0x166/0x5d0
[10451.217583][  T197]  #1: 00000000e060a0f6 (fs_reclaim){....}, at:
fs_reclaim_acquire.part.15+0x5/0x30
[10451.226908][  T197] 
[10451.229112][  T197] =============================================
[10451.229112][  T197] 
[10758.054022][T29393] kworker/dying (29393) used greatest stack depth: 16928
bytes left

