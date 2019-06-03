Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B97FC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 20:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDB5C2418C
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 20:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uD1qljtA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDB5C2418C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73FD86B026B; Mon,  3 Jun 2019 16:53:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C9526B026C; Mon,  3 Jun 2019 16:53:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592346B0270; Mon,  3 Jun 2019 16:53:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id E87036B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 16:53:46 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id w18so2860439ljw.8
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 13:53:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8lB/8S5uEZwnuoEheX1shx+zIgeiLGbwWG54GYZPyLA=;
        b=udQEXqrO0V9PYH/p37T1C8uRtL4x3NJZnbqtb8p1tYd20XAcZnaj623IVD1Z2D7p4B
         r6q4jPmuPCrMjVb1iNVV/3bDqv4rJRGrkC+X7YpCL2fTTz0XXZYhD8F8/e1naPFt09vW
         XL79QBJdCAQI0fik8qOJLmX+LVLaS/ArQXI2FodA/OAddmkETWGzz7PSndbFWRG2si4l
         3CD3wQsUabDvT3sebqMBufVVPmGMxkIbJYP5pVJZkbVr8MQsSm8gyRlQzvS1A6xi5FSH
         NPasSAKyWR1J5q/ZuT0Ao/N9Btcfvyzdy7w6ivpjFlGV77RmyB0/k6xhGH9wGkFLm4LV
         dchg==
X-Gm-Message-State: APjAAAWwVuJqLOl1ZaVe46JnP7mzF1xDWdCEjgH+AsGYw8BlKf9ZQsHV
	qFxZAz3MF00fgxy4hxT4o8bMMImpH5QIF24iuDoDFS9i7L6yTfwQ1vPIEqs+6aAwoXQxHdQUhln
	KIGUdTYNMAOy96OEelLPp0B4PBzXhQFB6/vSRxzaXTBbxbViwNwIJUW4gRwAi90fYXg==
X-Received: by 2002:a2e:9ed6:: with SMTP id h22mr778296ljk.29.1559595226247;
        Mon, 03 Jun 2019 13:53:46 -0700 (PDT)
X-Received: by 2002:a2e:9ed6:: with SMTP id h22mr778265ljk.29.1559595225097;
        Mon, 03 Jun 2019 13:53:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559595225; cv=none;
        d=google.com; s=arc-20160816;
        b=e3MKkFuqC+u+R5LhvyX+PUxYrLN4Q92Nzaywsgw5C8R5pdleBYchohauMly5QHWBZ3
         jmCYOzHpLxdaHyhYca/9/4cBMcRGgOSrfLep//Tmp+02zW4w4NtL7L1a3TSvR856w7xs
         Let1FK6gqrvR+8+0Hp1+bglsD7MlGa6EzF189118/O2Jdpp0aPtNb24SZklH/j2rx6E3
         6TRsDWGpD7Iz3lTV/4KmM07BsUCWlhkWjCsph6E1J/LGcUAuywrJ0NODRXMZKSzNHXw+
         khhAZa+QAExrashFd7XaABM5PeA8uDnNYzsrkU3XN3prekMf9JOShSq231A1AxliKIX6
         6pXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=8lB/8S5uEZwnuoEheX1shx+zIgeiLGbwWG54GYZPyLA=;
        b=OhTZ6cP4TFd/KLwF6W6RjmUjRDZG2U/jBfqYytuYFLR+2vH1QutdpgZiCZiNvH90Rv
         lVlQSeyDfEsodhbPlfUQRvkPGuXf50V6OXkzJXa++rT5an74VatB9VE5ZD7mfcvg0JKx
         qopN7Hk0N4cH2s+ZjnhN7w++jt3LCPfymN+afPWNa3u8uLuwiFD2JoRTei8q6A04xOGh
         l5kVXPnTZl6iNnXS8Bz0qRUmzUKM+Rkfe+2y9utPrC+8cBsHQKA2V4GWpRoQDni86icw
         3BT7M7uiRYtmjXbj3/FG3jD9IRO4lBYb4L8mdF96Dk+OTwV9lVmg99LTfvwzDQ8VvhaQ
         TM6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uD1qljtA;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3sor1482041lfq.36.2019.06.03.13.53.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 13:53:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uD1qljtA;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8lB/8S5uEZwnuoEheX1shx+zIgeiLGbwWG54GYZPyLA=;
        b=uD1qljtA87Vl5yJl+sBoM7yEMjSq2od75H3PmJCczRFXs544FYzfh6fwBdGpoKQbP+
         0FPcvY2ZbNMpL3ZHiWqTy3hNNdnuU8VDNWJVu/5zDeUDcWejyYiBcu5UiC1nGJtxA4Rw
         SiSO14U+vUweW5VPnmBsxGjA7w3LnV7scHjdhvYGP9pUdkFLb453Eh1Ao5M4BhMiByWD
         Sw6VqOailQJc2JUq0THlam9xwlNwRCjCAuOv1A3J2Iy6UrnBiwtUrCDtGw0vBQ6t8kl0
         jaDKDVF0UFzbC5nx9RQmPf0jxzSzKGr1BPXyY/RjeW79NknlUOCTQ4x1G5RYJC2Y7xSx
         W9AQ==
X-Google-Smtp-Source: APXvYqz9BlzfMoFOUGYLjCu47L6lBI93J1o7UGfxrrc+WlT7fPQgTmcpyNLPF86nuZdl26kvpMhIrQ==
X-Received: by 2002:a05:6512:64:: with SMTP id i4mr15818598lfo.32.1559595224575;
        Mon, 03 Jun 2019 13:53:44 -0700 (PDT)
Received: from pc636 (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id d16sm1979175lfl.26.2019.06.03.13.53.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 13:53:43 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 3 Jun 2019 22:53:34 +0200
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Message-ID: <20190603205334.qfxm6qiv45p4a326@pc636>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-3-urezki@gmail.com>
 <20190528224217.GG27847@tower.DHCP.thefacebook.com>
 <20190529142715.pxzrjthsthqudgh2@pc636>
 <20190529163435.GC3228@tower.DHCP.thefacebook.com>
 <20190603175312.72td46uahgchfgma@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603175312.72td46uahgchfgma@pc636>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 07:53:12PM +0200, Uladzislau Rezki wrote:
> Hello, Roman!
> 
> On Wed, May 29, 2019 at 04:34:40PM +0000, Roman Gushchin wrote:
> > On Wed, May 29, 2019 at 04:27:15PM +0200, Uladzislau Rezki wrote:
> > > Hello, Roman!
> > > 
> > > > On Mon, May 27, 2019 at 11:38:40AM +0200, Uladzislau Rezki (Sony) wrote:
> > > > > Refactor the NE_FIT_TYPE split case when it comes to an
> > > > > allocation of one extra object. We need it in order to
> > > > > build a remaining space.
> > > > > 
> > > > > Introduce ne_fit_preload()/ne_fit_preload_end() functions
> > > > > for preloading one extra vmap_area object to ensure that
> > > > > we have it available when fit type is NE_FIT_TYPE.
> > > > > 
> > > > > The preload is done per CPU in non-atomic context thus with
> > > > > GFP_KERNEL allocation masks. More permissive parameters can
> > > > > be beneficial for systems which are suffer from high memory
> > > > > pressure or low memory condition.
> > > > > 
> > > > > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > > > > ---
> > > > >  mm/vmalloc.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
> > > > >  1 file changed, 76 insertions(+), 3 deletions(-)
> > > > 
> > > > Hi Uladzislau!
> > > > 
> > > > This patch generally looks good to me (see some nits below),
> > > > but it would be really great to add some motivation, e.g. numbers.
> > > > 
> > > The main goal of this patch to get rid of using GFP_NOWAIT since it is
> > > more restricted due to allocation from atomic context. IMHO, if we can
> > > avoid of using it that is a right way to go.
> > > 
> > > From the other hand, as i mentioned before i have not seen any issues
> > > with that on all my test systems during big rework. But it could be
> > > beneficial for tiny systems where we do not have any swap and are
> > > limited in memory size.
> > 
> > Ok, that makes sense to me. Is it possible to emulate such a tiny system
> > on kvm and measure the benefits? Again, not a strong opinion here,
> > but it will be easier to justify adding a good chunk of code.
> > 
> It seems it is not so straightforward as it looks like. I tried it before,
> but usually the systems gets panic due to out of memory or just invokes
> the OOM killer.
> 
> I will upload a new version of it, where i embed "preloading" logic directly
> into alloc_vmap_area() function.
> 
just managed to simulate the faulty behavior of GFP_NOWAIT restriction,
resulting to failure of vmalloc allocation. Under heavy load and low
memory condition and without swap, i can trigger below warning on my
KVM machine:

<snip>
[  366.910037] Out of memory: Killed process 470 (bash) total-vm:21012kB, anon-rss:1700kB, file-rss:264kB, shmem-rss:0kB
[  366.910692] oom_reaper: reaped process 470 (bash), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  367.913199] stress-ng-fork: page allocation failure: order:0, mode:0x40800(GFP_NOWAIT|__GFP_COMP), nodemask=(null),cpuset=/,mems_allowed=0
[  367.913206] CPU: 3 PID: 19951 Comm: stress-ng-fork Not tainted 5.2.0-rc3+ #999
[  367.913207] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[  367.913208] Call Trace:
[  367.913215]  dump_stack+0x5c/0x7b
[  367.913219]  warn_alloc+0x108/0x190
[  367.913222]  __alloc_pages_slowpath+0xdc7/0xdf0
[  367.913226]  __alloc_pages_nodemask+0x2de/0x330
[  367.913230]  cache_grow_begin+0x77/0x420
[  367.913232]  fallback_alloc+0x161/0x200
[  367.913235]  kmem_cache_alloc+0x1c9/0x570
[  367.913237]  alloc_vmap_area+0x98b/0xa20
[  367.913240]  __get_vm_area_node+0xb0/0x170
[  367.913243]  __vmalloc_node_range+0x6d/0x230
[  367.913246]  ? _do_fork+0xce/0x3d0
[  367.913248]  copy_process.part.46+0x850/0x1b90
[  367.913250]  ? _do_fork+0xce/0x3d0
[  367.913254]  _do_fork+0xce/0x3d0
[  367.913257]  ? __do_page_fault+0x2bf/0x4e0
[  367.913260]  do_syscall_64+0x55/0x130
[  367.913263]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  367.913265] RIP: 0033:0x7f2a8248d38b
[  367.913268] Code: db 45 85 f6 0f 85 95 01 00 00 64 4c 8b 04 25 10 00 00 00 31 d2 4d 8d 90 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff ff 0f 87 de 00 00 00 85 c0 41 89 c5 0f 85 e5 00 00
[  367.913269] RSP: 002b:00007fff1b058c30 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[  367.913271] RAX: ffffffffffffffda RBX: 00007fff1b058c30 RCX: 00007f2a8248d38b
[  367.913272] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[  367.913273] RBP: 00007fff1b058c80 R08: 00007f2a83d34300 R09: 00007fff1b1890a0
[  367.913274] R10: 00007f2a83d345d0 R11: 0000000000000246 R12: 0000000000000000
[  367.913275] R13: 0000000000000020 R14: 0000000000000000 R15: 0000000000000000
[  367.913278] Mem-Info:
[  367.913282] active_anon:45795 inactive_anon:80706 isolated_anon:0
                active_file:394 inactive_file:359 isolated_file:210
                unevictable:2 dirty:0 writeback:0 unstable:0
                slab_reclaimable:2691 slab_unreclaimable:21864
                mapped:80835 shmem:80740 pagetables:50422 bounce:0
                free:12185 free_pcp:776 free_cma:0
[  367.913286] Node 0 active_anon:183180kB inactive_anon:322824kB active_file:1576kB inactive_file:1436kB unevictable:8kB isolated(anon):0kB isolated(file):840kB mapped:323340kB dirty:0kB writeback:0kB shmem:322960kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  367.913287] Node 0 DMA free:4516kB min:724kB low:904kB high:1084kB active_anon:2384kB inactive_anon:0kB active_file:48kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:1256kB pagetables:4516kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  367.913292] lowmem_reserve[]: 0 948 948 948
[  367.913294] Node 0 DMA32 free:44224kB min:44328kB low:55408kB high:66488kB active_anon:180252kB inactive_anon:322824kB active_file:992kB inactive_file:1332kB unevictable:8kB writepending:252kB present:1032064kB managed:995428kB mlocked:8kB kernel_stack:43260kB pagetables:197172kB bounce:0kB free_pcp:3252kB local_pcp:480kB free_cma:0kB
[  367.913299] lowmem_reserve[]: 0 0 0 0
[  367.913301] Node 0 DMA: 46*4kB (UM) 45*8kB (UM) 12*16kB (UM) 9*32kB (UM) 2*64kB (M) 2*128kB (UM) 2*256kB (M) 3*512kB (M) 1*1024kB (M) 0*2048kB 0*4096kB = 4480kB
[  367.913310] Node 0 DMA32: 966*4kB (UE) 552*8kB (UME) 648*16kB (UME) 265*32kB (UME) 75*64kB (UME) 12*128kB (ME) 1*256kB (U) 1*512kB (E) 1*1024kB (U) 2*2048kB (UM) 1*4096kB (M) = 43448kB
[  367.913322] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  367.913323] 81750 total pagecache pages
[  367.913324] 0 pages in swap cache
[  367.913325] Swap cache stats: add 0, delete 0, find 0/0
[  367.913325] Free swap  = 0kB
[  367.913326] Total swap = 0kB
[  367.913327] 262014 pages RAM
[  367.913327] 0 pages HighMem/MovableOnly
[  367.913328] 9180 pages reserved
[  367.913329] 0 pages hwpoisoned
[  372.338733] systemd-journald[195]: /dev/kmsg buffer overrun, some messages lost.
<snip>

Whereas with "preload" logic i see only OOM killer related messages:

<snip>
[  136.787266] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,global_oom,task_memcg=/,task=systemd-journal,pid=196,uid=0
[  136.787276] Out of memory: Killed process 196 (systemd-journal) total-vm:56832kB, anon-rss:512kB, file-rss:336kB, shmem-rss:820kB
[  136.790481] oom_reaper: reaped process 196 (systemd-journal), now anon-rss:0kB, file-rss:0kB, shmem-rss:820kB
<snip>

i.e. vmalloc still able to allocate.

Probably i need to update the commit message by this simulation and finding.

--
Vlad Rezki

