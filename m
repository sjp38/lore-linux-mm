Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0B93C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97A742063F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:38:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="uvoNHu+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97A742063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E1F68E0004; Mon, 11 Mar 2019 13:38:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 290DF8E0002; Mon, 11 Mar 2019 13:38:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1809D8E0004; Mon, 11 Mar 2019 13:38:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFE9D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:38:33 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b6so30486ywd.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:38:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4oG4uCayIgWYZNRmmqdLLn+2j4kMq1tiq/9bPpXuwD0=;
        b=M9Y7Qsa9/HCOyymy+qIm2CYlsmdwbHQmh+XTO9wzFUtGZmjOUu97n4PBK7rruvAC2S
         wnW1aKedQlazNbxYIVrVI58e9Yor8BhB34mpxE7IpUgN3jbpreH3DlOMHk9/ZpMo/E3X
         imuY7IigaQqob6yQvGg5nWiZgewua5JuScuRlQbNZjHsAQRMDVJ3k3P0LdG/S5Saus0U
         iVeUImJSZYM86hsxwn9Iljzikt27510mrC3wsKSdrt4e8F+PHi8y+dsqh2YRLE581+b6
         BLReuftvpfKV2Qj/gpvEOOnD4HOgKnoDGbTkg06FtBGYPujPzTzUcb/nOzsXZyeak2fD
         1VLw==
X-Gm-Message-State: APjAAAVdKg5BycPmxUv/zfiJ2QON7bqwk1meg9Qhu5yWgdq/WhFRT1OG
	yGBTAs2JVdKTqvL77B3Wgdud2+CK17mGnF5OXXjUfhi4PFkkhK/QWvCqHvSYFlPKnLgPA7oC+fS
	xjCkA/ustXtEB5UOoWNTk/09MOTJNt44rKwVIrNSVgAMS/Uf20I8h35N8KgZxs+dHw42uSuNT+D
	WJ3w+AnxfxHLz2xAINkqh0kDf2KRHr+nKM4P2iGLqbLkp54KD8HpUd5UQeLavWkt1Nt4nhqGBmm
	sgQWyLRenBpT5PjMsF4IE3mMMr2VbrnMFUDFtlODKdtfDZwFuuPYhdwJ/gGHgjBHpWpqKAIPppn
	pklx4vbAUK2b01TM/9Zo/iQZZJfM5TIvTo9YzuzvVtChD1iY8JUJ0I7/JcWP1jRegD8guoKzTZQ
	S
X-Received: by 2002:a5b:344:: with SMTP id q4mr2128787ybp.248.1552325913415;
        Mon, 11 Mar 2019 10:38:33 -0700 (PDT)
X-Received: by 2002:a5b:344:: with SMTP id q4mr2128750ybp.248.1552325912751;
        Mon, 11 Mar 2019 10:38:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552325912; cv=none;
        d=google.com; s=arc-20160816;
        b=xa/kGE9L0om8rTbNWTjBWOcX8ofYsa9W7bYJC6Vaja5WxUNzpbbNv/Z5sJzp7OtBv0
         TFShP7ncEhWNhHlJ72nZg+WdDl8SS2ytxBFRkhi7CbgduH2i0PrqGei4Oc7Y3CVDsvZ4
         Q9/NI+xeDjrOw/XVmEl3W2TWrANy6/Qi0+z3pjgN3yo5asd0tYT8cbmqvV95aFkAjAQ+
         EXiAlNqtgF4BCfLpM0fb4E3xJoRXrlOm3OnSEyoAOILUrjGev92GbXHxXed8VeNpesWY
         bWhu85puFeP1s0NbDpKaiyIlKqibboTUvaHvQMTP1g63nriyY/zp5o3OKTWe+Q6JTnLl
         Bx4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4oG4uCayIgWYZNRmmqdLLn+2j4kMq1tiq/9bPpXuwD0=;
        b=RtdcE0n0mDK+XAlb4X4djkfXJdD338LK5Rj2Xt0e5SG2yfz6gv474pYpLYKwee1nmP
         p6fj4DVm3jCVX4BRv8ETp9lNjFTGREK2EmtTVEwgOWbeiKekB4B8Bk0ti2g3U6rWiM0F
         hbfK6UsvupKowsdGyTbfIM+a9JgCIzXyScBdzcvjnyZHkYMDrd2PzXihigLW+f76JelS
         U/KD1UmMR/lAXqogo9ArUNnKnpn+zry1zS94B6Kzk11/Npe0SHftYXEBUsP9fLs2zxXo
         DHmCoQrDmD6zowKUecNJii0OdWVMiwzNGOvqOQ8f8x+y/xpK393OLaa0p4P4MIDP7BZn
         c+Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=uvoNHu+n;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5sor2988065ybo.108.2019.03.11.10.38.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:38:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=uvoNHu+n;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4oG4uCayIgWYZNRmmqdLLn+2j4kMq1tiq/9bPpXuwD0=;
        b=uvoNHu+n+ofsYax2n2VYcXwbPB9A3egn/1//CzPHBUXHOyp0Fl6HK5v2VS3cnzwEgO
         ToESLrILE6fVDPyQmGGifAsI6ccvNrXjwVg4yiMVMMIHJw/IZs/WepusApJFfRoHcVot
         0aNoXaMYYfJ4PQBOlZSQnwPorOF6USCzPC+FjKvrD6eo3dQBWHNn1Woik3/o9/akR/if
         FWfyJdUkRYgDWhmsRYzxKAL1/I80JNoGCj070il+ZR+U4yiy87BDNmWS+zTriFVEr/6u
         N198aqSSyWYTH2puIMOx9GY+KOpaqyDs2e8Omh5qkvCF89HTixb4o7LWqugfV17TiqNS
         +nKQ==
X-Google-Smtp-Source: APXvYqzIXaAlztXgyLzDw1doGyqIHYxIWXNOmebnA3qYLzj3f5vBWGOFMBwHZAiRBeiv2tR/lQ9LJw==
X-Received: by 2002:a25:57c4:: with SMTP id l187mr22693216ybb.435.1552325907846;
        Mon, 11 Mar 2019 10:38:27 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:3c60])
        by smtp.gmail.com with ESMTPSA id d9sm2385854ywd.82.2019.03.11.10.38.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:38:26 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:38:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 5/5] mm: spill memcg percpu stats and events before
 releasing
Message-ID: <20190311173825.GE10823@cmpxchg.org>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307230033.31975-6-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 03:00:33PM -0800, Roman Gushchin wrote:
> Spill percpu stats and events data to corresponding before releasing
> percpu memory.
> 
> Although per-cpu stats are never exactly precise, dropping them on
> floor regularly may lead to an accumulation of an error. So, it's
> safer to sync them before releasing.
> 
> To minimize the number of atomic updates, let's sum all stats/events
> on all cpus locally, and then make a single update per entry.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 52 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 18e863890392..b7eb6fac735e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4612,11 +4612,63 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	return 0;
>  }
>  
> +/*
> + * Spill all per-cpu stats and events into atomics.
> + * Try to minimize the number of atomic writes by gathering data from
> + * all cpus locally, and then make one atomic update.
> + * No locking is required, because no one has an access to
> + * the offlined percpu data.
> + */
> +static void mem_cgroup_spill_offlined_percpu(struct mem_cgroup *memcg)
> +{
> +	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
> +	struct lruvec_stat __percpu *lruvec_stat_cpu;
> +	struct mem_cgroup_per_node *pn;
> +	int cpu, i;
> +	long x;
> +
> +	vmstats_percpu = memcg->vmstats_percpu_offlined;
> +
> +	for (i = 0; i < MEMCG_NR_STAT; i++) {
> +		int nid;
> +
> +		x = 0;
> +		for_each_possible_cpu(cpu)
> +			x += per_cpu(vmstats_percpu->stat[i], cpu);
> +		if (x)
> +			atomic_long_add(x, &memcg->vmstats[i]);
> +
> +		if (i >= NR_VM_NODE_STAT_ITEMS)
> +			continue;
> +
> +		for_each_node(nid) {
> +			pn = mem_cgroup_nodeinfo(memcg, nid);
> +			lruvec_stat_cpu = pn->lruvec_stat_cpu_offlined;
> +
> +			x = 0;
> +			for_each_possible_cpu(cpu)
> +				x += per_cpu(lruvec_stat_cpu->count[i], cpu);
> +			if (x)
> +				atomic_long_add(x, &pn->lruvec_stat[i]);
> +		}
> +	}
> +
> +	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
> +		x = 0;
> +		for_each_possible_cpu(cpu)
> +			x += per_cpu(vmstats_percpu->events[i], cpu);
> +		if (x)
> +			atomic_long_add(x, &memcg->vmevents[i]);
> +	}

This looks good, but couldn't this be merged with the cpu offlining?
It seems to be exactly the same code, except for the nesting of the
for_each_possible_cpu() iteration here.

This could be a function that takes a CPU argument and then iterates
the cgroups and stat items to collect and spill the counters of that
specified CPU; offlining would call it once, and this spill code here
would call it for_each_possible_cpu().

We shouldn't need the atomicity of this_cpu_xchg() during hotunplug,
the scheduler isn't even active on that CPU anymore when it's called.

