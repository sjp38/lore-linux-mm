Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6315C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B7FF20B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E8B37Qvg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B7FF20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BDA36B0007; Mon,  5 Aug 2019 11:35:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96D706B0008; Mon,  5 Aug 2019 11:35:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85C176B000A; Mon,  5 Aug 2019 11:35:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6966B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 11:35:04 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id s145so36448311vke.18
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 08:35:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=tfr8EjYCxOIIZOQysJzS/EatqQ+1LB60cCfTX56PgNc=;
        b=stUgzDg2ez2o+B+VEgPeVKD1uBPUQwnKmclYReVqQIxAOK99Km4/gPFcT34kAaLFoV
         ray1dc+DUgiO5tAQq+dSomNDKNP7wt2SQlG51SmbVCsx5vbeO9PuxM3Sp8G5TtIvLpBH
         VdnGWrUUqdQt7Q3VC8EoTxoSn24AqJUT1uUMqc5OsP9MiImHyVaPHtjsFdFz6ERsvhUP
         +Ux3Yan0QiasVBeppXyfBFE0/R9cb8gpnWQAtZIVojg0+8n001mVkqY1HltYhZLD6ohk
         NjB0FNKg7lz75bfZ0NBOgQim3JqjXUBYD/zK9XN8FFQsCryDtCYRG2xyej+gvzf9BhfZ
         F2YQ==
X-Gm-Message-State: APjAAAXPgjRcsMINQRwa1JJz7MAM48Soh6N7UMfX1odKMOT9djgnBEED
	Lj82OQB2kYJWaFA9w5qKAEFpURT9tOReqMTYCSe0HwWsjWh7ZpWz9uIyrar8HSLP0/THI3BPdpS
	vxgJPiKt2UVfP5EW3b3Sci9b6CYMHjMBiBcL3Eh6G6J406gmqBigJp7oPrZSgb1jhyA==
X-Received: by 2002:ab0:208f:: with SMTP id r15mr66457480uak.38.1565019303966;
        Mon, 05 Aug 2019 08:35:03 -0700 (PDT)
X-Received: by 2002:ab0:208f:: with SMTP id r15mr66457434uak.38.1565019302930;
        Mon, 05 Aug 2019 08:35:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565019302; cv=none;
        d=google.com; s=arc-20160816;
        b=qD0ntQdtjZ4ClnISF+ReRBCKo0sA4lzF6j2c49m1bxUvSKRsAqpfvn3/axKcOwyaP0
         N+RTZZdx6wF7mb7bG3yj9vt267SJX36nu04yWQE5NNTQwbmpwWQhEBTQFRl+xn9bdwHH
         N4M268QBtM/aUL7zaqwlcO4KABgsOnxusFXY4A3+d9FzMltruMAs8hEbqcgvN0WBp58U
         oGSaKSmlf1j39DT9jeYdpo/kxQuORmTKVyQJac8OpwcN2gH5S7Zdt1ZCrP5n4MjUC24J
         GyXZnrjh5NHy9kl9tqAlVUGV7UqgqJ9odOjCwjixr2TdXq9NbrM/QBxxeW86DsjL3m+L
         yhgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=tfr8EjYCxOIIZOQysJzS/EatqQ+1LB60cCfTX56PgNc=;
        b=fECvyEFWGEzLohFMzBJCI1XXZRCKRkUkulU6RJs0wqplVmf2rGvIEFmkJfhYw+ZK8P
         ux41iwj/Rf5fbYiCil0bGxFdOVp4LkhFm5+IB6PeYVADnFo50Fn97jDjx/3EdsWcwZMV
         T6hrMIkqNWsbCFvY8vlSPpAU7GqobCTeQDN4FXFZ+ZKEcuXkdxe/xuVUNJyb/1zM13Gt
         z+IVEAhn5QpngpBwzCgHE0awsREAwdeO82SO/AJwyTDR6597THhhecup4zGZTxNUki7d
         WeUm2tBcCPdreCBwQ0kv7Lf0yCU1C5afMkcu0nRRUzBj7L6FcY+A41ryRVyZMLit5ne3
         SXzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E8B37Qvg;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m12sor40826716uao.68.2019.08.05.08.35.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 08:35:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E8B37Qvg;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=tfr8EjYCxOIIZOQysJzS/EatqQ+1LB60cCfTX56PgNc=;
        b=E8B37QvgggUr7EFciA2UwYaO+h8o5jsDqrdxydVsM0ZlEGGF0ZfKDP8ONQq60YdE4F
         mJYmAnRaFg1ct5f408FCDtdzV9XenbMniDtuxu3sRlsrBJYzFmAIa85yU0qi6l6kjfEB
         F4rphvSyaVYxqtFGJkEgFHRloCXIMVW98FDtoBG9rCDIFCNI2Kod++UMBX7zM2rYWYKO
         cHq0gdPczHtYcRBThy4nog13E7WUzY4WgC1D/QjHyBVrZU5vsuLUATalchPaC51FVU6s
         QDq0rOUotPi3OzftovKF6sFanhBZrBIn/2HlCPu8Cz3QDnOo1oNGhNkVqqQuWXQbO1mr
         Luqg==
X-Google-Smtp-Source: APXvYqxVMAhY3Za1YEA1tml6rOEDx6dn6yYrPVckBRbXmbs8EyS2UIrB60n8zwMFWzyK1dNu8c4wU4sLQ1wEz35p+u0=
X-Received: by 2002:ab0:7848:: with SMTP id y8mr1424452uaq.58.1565019302331;
 Mon, 05 Aug 2019 08:35:02 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz> <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
In-Reply-To: <20190805120525.GL7597@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 5 Aug 2019 21:04:53 +0530
Message-ID: <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
Subject: Re: oom-killer
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	pankaj.suryawanshi@einfochips.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P         =
  O  4.14.65 #606
> > > [...]
> > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (ou=
t_of_memory+0x140/0x368)
> > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:=
c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__al=
loc_pages_nodemask+0x1178/0x124c)
> > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4=
>] (copy_process.part.5+0x114/0x1a28)
> > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:=
c1216588 r5:00808111
> > >> [  728.079587]  r4:d1063c00
> > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] =
(_do_fork+0xd0/0x464)
> > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:=
c1216588 r5:d2d58ac0
> > >> [  728.097857]  r4:00808111
> > >
> > > The call trace tells that this is a fork (of a usermodhlper but that =
is
> > > not all that important.
> > > [...]
> > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB=
 active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB =
unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:=
0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_p=
cp:0kB free_cma:0kB
> > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > >
> > > So this is the only usable zone and you are close to the min watermar=
k
> > > which means that your system is under a serious memory pressure but n=
ot
> > > yet under OOM for order-0 request. The situation is not great though
> >
> > Looking at lowmem_reserve above, wonder if 579 applies here? What does
> > /proc/zoneinfo say?


What is  lowmem_reserve[]: 0 0 579 579 ?

$cat /proc/sys/vm/lowmem_reserve_ratio
256     32      32

$cat /proc/sys/vm/min_free_kbytes
16384

here is cat /proc/zoneinfo (in normal situation not when oom)

$cat /proc/zoneinfo
Node 0, zone      DMA
  per-node stats
      nr_inactive_anon 120
      nr_active_anon 94870
      nr_inactive_file 101188
      nr_active_file 74656
      nr_unevictable 614
      nr_slab_reclaimable 12489
      nr_slab_unreclaimable 8519
      nr_isolated_anon 0
      nr_isolated_file 0
      workingset_refault 7163
      workingset_activate 7163
      workingset_nodereclaim 0
      nr_anon_pages 94953
      nr_mapped    109148
      nr_file_pages 176502
      nr_dirty     0
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     166
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 0
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   7701
      nr_written   6978
  pages free     49492
        min      4096
        low      6416
        high     7440
        spanned  131072
        present  114688
        managed  105724
        protection: (0, 0, 1491, 1491)
      nr_free_pages 49492
      nr_zone_inactive_anon 0
      nr_zone_active_anon 0
      nr_zone_inactive_file 65
      nr_zone_active_file 4859
      nr_zone_unevictable 0
      nr_zone_write_pending 0
      nr_mlock     0
      nr_page_table_pages 4352
      nr_kernel_stack 9056
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  0
  pagesets
    cpu: 0
              count: 16
              high:  186
              batch: 31
  vm stats threshold: 18
    cpu: 1
              count: 138
              high:  186
              batch: 31
  vm stats threshold: 18
    cpu: 2
              count: 156
              high:  186
              batch: 31
  vm stats threshold: 18
    cpu: 3
              count: 170
              high:  186
              batch: 31
  vm stats threshold: 18
  node_unreclaimable:  0
  start_pfn:           131072
  node_inactive_ratio: 0
Node 0, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 11928, 11928)
Node 0, zone  HighMem
  pages free     63096
        min      128
        low      8506
        high     12202
        spanned  393216
        present  381696
        managed  381696
        protection: (0, 0, 0, 0)
      nr_free_pages 63096
      nr_zone_inactive_anon 120
      nr_zone_active_anon 94863
      nr_zone_inactive_file 101123
      nr_zone_active_file 69797
      nr_zone_unevictable 614
      nr_zone_write_pending 0
      nr_mlock     614
      nr_page_table_pages 1478
      nr_kernel_stack 0
      nr_bounce    0
      nr_zspages   0
      nr_free_cma  62429
  pagesets
    cpu: 0
              count: 30
              high:  186
              batch: 31
  vm stats threshold: 30
    cpu: 1
              count: 13
              high:  186
              batch: 31
  vm stats threshold: 30
    cpu: 2
              count: 9
              high:  186
              batch: 31
  vm stats threshold: 30
    cpu: 3
              count: 46
              high:  186
              batch: 31
  vm stats threshold: 30
  node_unreclaimable:  0
  start_pfn:           262144
  node_inactive_ratio: 0
Node 0, zone  Movable
  pages free     0
        min      32
        low      32
        high     32
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0)
>
>
> This is GFP_KERNEL request essentially so there shouldn't be any lowmem
> reserve here, no?


Why only low 1G is accessible by kernel in 32-bit system ?


My system configuration is :-
3G/1G - vmsplit
vmalloc =3D 480M (I think vmalloc size will set your highmem ?)

here is my memory layout :-
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
[    0.000000]     vmalloc : 0xe0800000 - 0xff800000   ( 496 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0c00000   (12256 kB)
[    0.000000]       .init : 0xc1000000 - 0xc1200000   (2048 kB)
[    0.000000]       .data : 0xc1200000 - 0xc143c760   (2290 kB)
[    0.000000]        .bss : 0xc1447840 - 0xc14c3ad4   ( 497 kB)
>
> --
> Michal Hocko
> SUSE Labs

