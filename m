Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F865C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:21:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BD1E2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:21:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2ImeMMyb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BD1E2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97F326B0007; Thu,  8 Aug 2019 17:21:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92F0C6B0008; Thu,  8 Aug 2019 17:21:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F6806B000A; Thu,  8 Aug 2019 17:21:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48BEB6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:21:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h5so58439365pgq.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:21:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2PSExnZL6PgmjPi41kVQwf4nCMqPmqKLyo2wb4+uXfU=;
        b=ThdNh/ZG7J2xXXw2y613QJEw4c3xlmPmdad5bi5wYAs2zzx9m2FX95X3LQHWAH2dhj
         x4EcyGIcwvvYKzPU1u31bRpn0Vg4PLqnOJqgE6vnlroBCv/MHJfjsajgy32VDObtZ7F2
         32d2lhYEAOi41JJNLpC2Nx0d9/ntE5TIpz6+HCwPD2a/X7C/1XPyEe4pSXmK9XrUWQPc
         LDOx1RcAzHKGG7U4E2VqcA1wxvzKABg+FzwrypCenuvAI8+vhwQJ/DyyAWsnDjtarnVt
         iiMi1S+CxNXD5/JHB4cWRa+DGQmU0p/8XWGaZvM7foKQXbVS3N9CCZ2daRkFfAth8OA9
         rPlQ==
X-Gm-Message-State: APjAAAU0yY0zsKT8ZTXdhlc4Ixf4vevssLJDMB/ypan8k29DhNdiXOdc
	ew8E58xJJVenEDwu+hwtrsKrTQzyEmUOBS+P5sllLYGshmeoouv08dWirGPkgg3JZl9d8FPSZI6
	YIYcRDeKD23PtMql+TGeRo/YX5/dhiNK2uv/t94SGq7wcCLuEfdUEM+4L/2opfO4Xzw==
X-Received: by 2002:a63:550e:: with SMTP id j14mr12989602pgb.302.1565299308883;
        Thu, 08 Aug 2019 14:21:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMJOeap6FNukw2Y9XLDyajBEHdAjvGYqGlwS0NgCQvHl2HfvUV/M5BeIwG0nr3spDCw6I4
X-Received: by 2002:a63:550e:: with SMTP id j14mr12989571pgb.302.1565299308121;
        Thu, 08 Aug 2019 14:21:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565299308; cv=none;
        d=google.com; s=arc-20160816;
        b=TafxsYwB0Tr1kxlE0zrZfmTd12Grgl1CPNbiYeOI1O5xru3S1Y0ee0HVlB17m7vMgt
         c4vZkhyHvk9L7kSDWbi5qYKcTmVskcv7zER45bDPv/Bk2wmdpbvSWcblSqlVJ+fgiEZ4
         iMZXEx08HD5nyjPpdTy43qPIxAEVSU6e/2nSuieWcPBebleIFFDwsZns57IDZsO+/9TJ
         c+sVodHEKrD5GjZ65ROScYuJyObWQ1tf6r5Ajn9kPIv3O6FhoFEgSTa4AV3BUMgnZRd4
         fpH4cGupqqDJbr0xYEq2zwBRql12Gv8ChCBG5FTGehXCW9OKlo1etXunuDcEyR0JtISH
         bfgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2PSExnZL6PgmjPi41kVQwf4nCMqPmqKLyo2wb4+uXfU=;
        b=Oei3v7zjp+lhyKkhk2DScetLGg/wuhljWxjqKuMUYEtXHMpOuARajSRNXoczGF432H
         BbLPrm8tZe8W8JjQUD+HvkeLnM9cS2mXBdtk1fW01izNAqA+M+R8KSEllbnfP8Deaodv
         8Gqkkog7cxF1pRkUTal1ZN6XzuovSeR+IvuTtNoBBlXfYVX36Z/S8m2N2sPbD3R8KCzX
         bYoRVsL+yhGF5cvzjcEQIfH/IR5peG1iAF/lY/sT+xu2wmh2cBbBELDto6x7i7Wp1/zO
         OgzHsKVWswM4qZ1lZFbHQ9lNMmsQ/66Dpi2eSEilY7dUH3jLZGRLzjFQRGurpOW0hx5z
         mt7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2ImeMMyb;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p12si75224997plq.331.2019.08.08.14.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:21:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2ImeMMyb;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6BB582166E;
	Thu,  8 Aug 2019 21:21:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565299307;
	bh=LgjCrDBOFNjZIGmWfH/ct2Mm4aiB1Es4buMJn30aQvY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=2ImeMMybV064Z0DxdUeprm+KuyhJO20DaFsupoAvVIlLSqheXfGcf1uuRXh14Sd2p
	 ga56EsJLL90V5ZbfzYXSkTVMRDVOsVZzV0sYKuee53I+nxBGGQiS+dMEWj0I6g58kM
	 FTn+JRSENWS2+lhaf+crG46ih3HBKYmNxyVr3cVg=
Date: Thu, 8 Aug 2019 14:21:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: flush slab vmstats on kmem offlining
Message-Id: <20190808142146.a328cd673c66d5fdbca26f79@linux-foundation.org>
In-Reply-To: <20190808203604.3413318-1-guro@fb.com>
References: <20190808203604.3413318-1-guro@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Aug 2019 13:36:04 -0700 Roman Gushchin <guro@fb.com> wrote:

> I've noticed that the "slab" value in memory.stat is sometimes 0,
> even if some children memory cgroups have a non-zero "slab" value.
> The following investigation showed that this is the result
> of the kmem_cache reparenting in combination with the per-cpu
> batching of slab vmstats.
> 
> At the offlining some vmstat value may leave in the percpu cache,
> not being propagated upwards by the cgroup hierarchy. It means
> that stats on ancestor levels are lower than actual. Later when
> slab pages are released, the precise number of pages is substracted
> on the parent level, making the value negative. We don't show negative
> values, 0 is printed instead.
> 
> To fix this issue, let's flush percpu slab memcg and lruvec stats
> on memcg offlining. This guarantees that numbers on all ancestor
> levels are accurate and match the actual number of outstanding
> slab pages.
> 

Looks expensive.  How frequently can these functions be called?

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3412,6 +3412,50 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
>  	return 0;
>  }
>  
> +static void memcg_flush_slab_node_stats(struct mem_cgroup *memcg, int node)
> +{
> +	struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
> +	struct mem_cgroup_per_node *pi;
> +	unsigned long recl = 0, unrecl = 0;
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		recl += raw_cpu_read(
> +			pn->lruvec_stat_cpu->count[NR_SLAB_RECLAIMABLE]);
> +		unrecl += raw_cpu_read(
> +			pn->lruvec_stat_cpu->count[NR_SLAB_UNRECLAIMABLE]);
> +	}
> +
> +	for (pi = pn; pi; pi = parent_nodeinfo(pi, node)) {
> +		atomic_long_add(recl,
> +				&pi->lruvec_stat[NR_SLAB_RECLAIMABLE]);
> +		atomic_long_add(unrecl,
> +				&pi->lruvec_stat[NR_SLAB_UNRECLAIMABLE]);
> +	}
> +}
> +
> +static void memcg_flush_slab_vmstats(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *mi;
> +	unsigned long recl = 0, unrecl = 0;
> +	int node, cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		recl += raw_cpu_read(
> +			memcg->vmstats_percpu->stat[NR_SLAB_RECLAIMABLE]);
> +		unrecl += raw_cpu_read(
> +			memcg->vmstats_percpu->stat[NR_SLAB_UNRECLAIMABLE]);
> +	}
> +
> +	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
> +		atomic_long_add(recl, &mi->vmstats[NR_SLAB_RECLAIMABLE]);
> +		atomic_long_add(unrecl, &mi->vmstats[NR_SLAB_UNRECLAIMABLE]);
> +	}
> +
> +	for_each_node(node)
> +		memcg_flush_slab_node_stats(memcg, node);

This loops across all possible CPUs once for each possible node.  Ouch.

Implementing hotplug handlers in here (which is surprisingly simple)
brings this down to num_online_nodes * num_online_cpus which is, I
think, potentially vastly better.

