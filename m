Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C899C43444
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 03:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1CA02146F
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 03:13:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DVEgu299"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1CA02146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52FDF8E009D; Tue,  8 Jan 2019 22:13:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DEA98E0038; Tue,  8 Jan 2019 22:13:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F3DF8E009D; Tue,  8 Jan 2019 22:13:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1850C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 22:13:22 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 135so5860811itk.5
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 19:13:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xPG3lfDwpQxOOMXTwldNhjlt9w/NmiiZfy1Iv6t7A6c=;
        b=CDfBvXmSboKmDUweP5h44XGbLca6jSJhFT9GzklVI74LLaIAy0P4PlcraOj1faHIge
         R2cmv7e+RVZGK7Kq/ckJ8WLTMUh8ctNCZUQf94Vaz5RI+Hgqd9Ji+tLzsAGVQw/JW8ou
         dJHQ+PtCVSnzsQ2d1w+/DcrEQbiVo/LxmYPH0ULu+gthHrFVQMvhMlr3DWl8GkwhH0va
         /0+LT/I9agh9QDWlHENnX0gYWNuCLIJfdli9kPf9LKY4dbndznaANZKj7Tiw2un3NnoN
         kJESdiuXclk1kG6CGq890jJWBHGuuTdSsAJADbFibLcjMWMvBFVX/dUO/G3duvrT6gXP
         cccw==
X-Gm-Message-State: AJcUukdJjXo2cfVoV8k0sNVMJMKjBi6YZV/gZIhvSb+e16OgWaIIt1g/
	bqT45dUepA1m9tUtEKcN5HCuSHlptOMk1y28w9dizBWFDdEjFFvotqazP2Jbqnuf46wrczILvDP
	j3QxEmy1ncAAwuw3SM2yWdjaZJ65S3cW+IYfBSHU7J7UAJS0MLepoYXBwYXVqsSzEx9hIrgg4Tz
	AtpUf22qTfR8JF4BRchD6tLYRN2Nnl+LR/qArrNaHL3/T6wLPQnRwc/QUPJ3P8KaMZt/MwmVZRQ
	xnl77+xvWRoTPs24ac1BiTkfw43Rd5+MLNLB+y4wM1WN28tZitRTsAdvRt8Klac1UoUQU5UWa/1
	1y6DcWVQwUx4UWu9T5THbB+JiPOCM5Li8ACifKfPHm3D2wmdegnQkW7pSNeJZCY8hoS565qctxF
	d
X-Received: by 2002:a02:8785:: with SMTP id t5mr3003974jai.73.1547003601842;
        Tue, 08 Jan 2019 19:13:21 -0800 (PST)
X-Received: by 2002:a02:8785:: with SMTP id t5mr3003950jai.73.1547003600749;
        Tue, 08 Jan 2019 19:13:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547003600; cv=none;
        d=google.com; s=arc-20160816;
        b=KAzsT4qSPsqTzam39MOnly1Ozuc+9amuptGrYtjpVt2cB0iADcDzNRdimZ8/9fyxVJ
         iIe6exTGjCMq6S/WxW1ZIfOTVggDDl6jm7s5VheH5xTtp0G0bV6Zs9dGcKXucp+59b9p
         B39GuFqMYL760Y0H9+yVRfztzjqC25zqYwPq4WFoop2aVajoD+uWgYRhwEBKJydbOVX+
         n4Nvp7/9fx4bPC4/CLPLTxwX+dJ5YLy/I6KHR7ge8HlY4clM6Qa2QwLudykYR0RsPRe1
         jXCeXfOGwc9Y7eFvBUnnQ8MsKky9+lL7rVThR3np470Y9WJZRmF1BVTuvHI33JAahBMQ
         2t+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xPG3lfDwpQxOOMXTwldNhjlt9w/NmiiZfy1Iv6t7A6c=;
        b=x2sTId0yHzT6frUht1oNV+Ken1TPLORQLzQx8Rh4HH1bNsEvVu+B0ptZ4wx/A1Yhzu
         OGUkkaX4uVtMeIPN5g8q2k9fFx6tuE6t2u95iQvG+a6olCKhEUcBabhMuhn2jbZ0K5hd
         mx+zG5yyoHrwzLEFoH56vBKZuCVMBuoa/BsusyljN0YreowPwYWwCu9fFCqOOKFVLaLQ
         1FGmodVWeq/QUiCGkBtqauJsVkQE/fowozRslf8537FMIcdxLDNDmfTYaWG6YSE+fAQR
         WyJTYwbwQmXxR2Sln5f8STpk21VeozaFZf+YvrdUT6fL5vulQt13PLJU7VqgepbD19R1
         i3Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DVEgu299;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v134sor21205088itb.19.2019.01.08.19.13.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 19:13:20 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DVEgu299;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xPG3lfDwpQxOOMXTwldNhjlt9w/NmiiZfy1Iv6t7A6c=;
        b=DVEgu299xSwIR7Hu5dG7aR9sExvaoNdXpR8RYsuDVW0zaiissKtWpIIvwsM5op57id
         daAk9MNOj4kBMLjEmw19iAjhzwuHqYM/Jooc6303Z0ZDH896brtqjleAnZZDwL2RzfqK
         CTxPZoUC19GZmzsHvPlXdW5rwldyMuXQY2DWynIxPr7EdSO/TOyFf7hKs0W1kxaIO8xO
         kILnmNJfropj7aU8+55H5jPXgMGwJytbA7hEDnuxLpZCFb9mWD9B0KJUNDasj2m18s4C
         CTLL8Y2oaQ1r4gSYs8a6ELh/tDAvHdkWDxAjJG9e6fuoOzBMDd0jDQ0WtKcFI6XakJ6Q
         WfLA==
X-Google-Smtp-Source: ALg8bN4ZZ66ZCb+ui8oZxTCNKwi5CkOpPqpR2cw/VKwJfWVcv6scdKi6WxKUN11meWaLcJ28TH37H7WJSNv7Z/AloXk=
X-Received: by 2002:a24:3282:: with SMTP id j124mr3030181ita.173.1547003600411;
 Tue, 08 Jan 2019 19:13:20 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz> <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz> <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
 <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
 <20181217132926.GM30879@dhcp22.suse.cz> <CAFgQCTubm9B1_zM+oc1GLfOChu+XY9N4OcjyeDgk6ggObRtMKg@mail.gmail.com>
 <20181220091934.GC14234@dhcp22.suse.cz> <20190108143440.GU31793@dhcp22.suse.cz>
In-Reply-To: <20190108143440.GU31793@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 9 Jan 2019 11:13:08 +0800
Message-ID:
 <CAFgQCTv1hfcL6+hAxcyd-u6kgAkBFBqbkKqC4E=KCJB+jmSruQ@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109031308.-IsAXDthC_Xzxm7v9SjC9wVVCKZfk8HUji0PmGEI-wA@z>

On Tue, Jan 8, 2019 at 10:34 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 20-12-18 10:19:34, Michal Hocko wrote:
> > On Thu 20-12-18 15:19:39, Pingfan Liu wrote:
> > > Hi Michal,
> > >
> > > WIth this patch applied on the old one, I got the following message.
> > > Please get it from attachment.
> > [...]
> > > [    0.409637] NUMA: Node 1 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x7fffffff] -> [mem 0x00000000-0x7fffffff]
> > > [    0.419858] NUMA: Node 1 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x47fffffff] -> [mem 0x00000000-0x47fffffff]
> > > [    0.430356] NODE_DATA(0) allocated [mem 0x87efd4000-0x87effefff]
> > > [    0.436325]     NODE_DATA(0) on node 5
> > > [    0.440092] Initmem setup node 0 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.447078] node[0] zonelist:
> > > [    0.450106] NODE_DATA(1) allocated [mem 0x47ffd5000-0x47fffffff]
> > > [    0.456114] NODE_DATA(2) allocated [mem 0x87efa9000-0x87efd3fff]
> > > [    0.462064]     NODE_DATA(2) on node 5
> > > [    0.465852] Initmem setup node 2 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.472813] node[2] zonelist:
> > > [    0.475846] NODE_DATA(3) allocated [mem 0x87ef7e000-0x87efa8fff]
> > > [    0.481827]     NODE_DATA(3) on node 5
> > > [    0.485590] Initmem setup node 3 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.492575] node[3] zonelist:
> > > [    0.495608] NODE_DATA(4) allocated [mem 0x87ef53000-0x87ef7dfff]
> > > [    0.501587]     NODE_DATA(4) on node 5
> > > [    0.505349] Initmem setup node 4 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.512334] node[4] zonelist:
> > > [    0.515370] NODE_DATA(5) allocated [mem 0x87ef28000-0x87ef52fff]
> > > [    0.521384] NODE_DATA(6) allocated [mem 0x87eefd000-0x87ef27fff]
> > > [    0.527329]     NODE_DATA(6) on node 5
> > > [    0.531091] Initmem setup node 6 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.538076] node[6] zonelist:
> > > [    0.541109] NODE_DATA(7) allocated [mem 0x87eed2000-0x87eefcfff]
> > > [    0.547090]     NODE_DATA(7) on node 5
> > > [    0.550851] Initmem setup node 7 [mem 0x0000000000000000-0x0000000000000000]
> > > [    0.557836] node[7] zonelist:
> >
> > OK, so it is clear that building zonelists this early is not going to
> > fly. We do not have the complete information yet. I am not sure when do
> > we get that at this moment but I suspect the we either need to move that
> > initialization to a sooner stage or we have to reconsider whether the
> > phase when we build zonelists really needs to consider only online numa
> > nodes.
> >
> > [...]
> > > [    1.067658] percpu: Embedded 46 pages/cpu @(____ptrval____) s151552 r8192 d28672 u262144
> > > [    1.075692] node[1] zonelist: 1:Normal 1:DMA32 1:DMA 5:Normal
> > > [    1.081376] node[5] zonelist: 5:Normal 1:Normal 1:DMA32 1:DMA
> >
> > I hope to get to this before I leave for christmas vacation, if not I
> > will stare into it after then.
>
> I am sorry but I didn't get to this sooner. But I've got another idea. I
> concluded that the whole dance is simply bogus and we should treat
> memory less nodes, well, as nodes with no memory ranges rather than
> special case them. Could you give the following a spin please?
>

Sure, I have queued a loan for the remote machine. It will take some time.

Regards,
Pingfan
> ---
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 1308f5408bf7..0e79445cfd85 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
>
>         node_data[nid] = nd;
>         memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
> -
> -       node_set_online(nid);
>  }
>
>  /**
> @@ -535,6 +533,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>         /* Account for nodes with cpus and no memory */
>         node_possible_map = numa_nodes_parsed;
>         numa_nodemask_from_meminfo(&node_possible_map, mi);
> +       pr_info("parsed=%*pbl, possible=%*pbl\n", nodemask_pr_args(&numa_nodes_parsed), nodemask_pr_args(&node_possible_map));
>         if (WARN_ON(nodes_empty(node_possible_map)))
>                 return -EINVAL;
>
> @@ -570,7 +569,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                 return -EINVAL;
>
>         /* Finally register nodes. */
> -       for_each_node_mask(nid, node_possible_map) {
> +       for_each_node_mask(nid, numa_nodes_parsed) {
>                 u64 start = PFN_PHYS(max_pfn);
>                 u64 end = 0;
>
> @@ -581,9 +580,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                         end = max(mi->blk[i].end, end);
>                 }
>
> -               if (start >= end)
> -                       continue;
> -
>                 /*
>                  * Don't confuse VM with a node that doesn't have the
>                  * minimum amount of memory:
> @@ -592,6 +588,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                         continue;
>
>                 alloc_node_data(nid);
> +               if (end)
> +                       node_set_online(nid);
>         }
>
>         /* Dump memblock with node info and return. */
> @@ -721,21 +719,6 @@ void __init x86_numa_init(void)
>         numa_init(dummy_numa_init);
>  }
>
> -static void __init init_memory_less_node(int nid)
> -{
> -       unsigned long zones_size[MAX_NR_ZONES] = {0};
> -       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> -
> -       /* Allocate and initialize node data. Memory-less node is now online.*/
> -       alloc_node_data(nid);
> -       free_area_init_node(nid, zones_size, 0, zholes_size);
> -
> -       /*
> -        * All zonelists will be built later in start_kernel() after per cpu
> -        * areas are initialized.
> -        */
> -}
> -
>  /*
>   * Setup early cpu_to_node.
>   *
> @@ -763,9 +746,6 @@ void __init init_cpu_to_node(void)
>                 if (node == NUMA_NO_NODE)
>                         continue;
>
> -               if (!node_online(node))
> -                       init_memory_less_node(node);
> -
>                 numa_set_node(cpu, node);
>         }
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2ec9cc407216..52e54d16662a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5234,6 +5234,8 @@ static void build_zonelists(pg_data_t *pgdat)
>         int node, load, nr_nodes = 0;
>         nodemask_t used_mask;
>         int local_node, prev_node;
> +       struct zone *zone;
> +       struct zoneref *z;
>
>         /* NUMA-aware ordering of nodes */
>         local_node = pgdat->node_id;
> @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
>
>         build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
>         build_thisnode_zonelists(pgdat);
> +
> +       pr_info("node[%d] zonelist: ", pgdat->node_id);
> +       for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> +               pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> +       pr_cont("\n");
>  }
>
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> @@ -5361,10 +5368,11 @@ static void __build_all_zonelists(void *data)
>         if (self && !node_online(self->node_id)) {
>                 build_zonelists(self);
>         } else {
> -               for_each_online_node(nid) {
> +               for_each_node(nid) {
>                         pg_data_t *pgdat = NODE_DATA(nid);
>
> -                       build_zonelists(pgdat);
> +                       if (pgdat)
> +                               build_zonelists(pgdat);
>                 }
>
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> @@ -6644,10 +6652,8 @@ static unsigned long __init find_min_pfn_for_node(int nid)
>         for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
>                 min_pfn = min(min_pfn, start_pfn);
>
> -       if (min_pfn == ULONG_MAX) {
> -               pr_warn("Could not find start_pfn for node %d\n", nid);
> +       if (min_pfn == ULONG_MAX)
>                 return 0;
> -       }
>
>         return min_pfn;
>  }
> @@ -6991,8 +6997,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>         mminit_verify_pageflags_layout();
>         setup_nr_node_ids();
>         zero_resv_unavail();
> -       for_each_online_node(nid) {
> +       for_each_node(nid) {
>                 pg_data_t *pgdat = NODE_DATA(nid);
> +
> +               if (!pgdat)
> +                       continue;
> +
>                 free_area_init_node(nid, NULL,
>                                 find_min_pfn_for_node(nid), NULL);
>
> --
> Michal Hocko
> SUSE Labs

