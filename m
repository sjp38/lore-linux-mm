Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9167FC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B172063F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="A0QAa7xg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B172063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0F1B8E0003; Mon, 11 Mar 2019 13:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBEFC8E0002; Mon, 11 Mar 2019 13:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD3968E0003; Mon, 11 Mar 2019 13:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAB128E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:25:31 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l203so3197972ywb.11
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=f/08Cea8rl1auJ0ztvMCqTFjGtaWSYM7AUW8AvuH/RU=;
        b=pl8G1BmTAST2anedRnru7ywFVUBGT79QKWjD7wUQjcGMBO0gnrCObGcdNB+XkCVPPX
         THwVy8TkGrgcAqYkcvMhQgYutE7wL/ZggYVqCGZPpQQiGPueNQNbrk/61rND4UONCIAZ
         M4IGTLTHLibbpDCoiOjgfW/D9wABUafQYtjciY2c0Dopgr0TehtxX/hgwnKHDne7fsYf
         Ysqg9kD43Fn9eUXKxT2nHoSBR1HS03hbXtxQK6iimIlXt0LxZTwGE0j0jVzy8Wz5vs7q
         N4B8Dg3mirrvO62wKk0clgEtql7nDZjZDSlFrdTukx1rFgnfZvTTSJ1Pd7m7koQgXi13
         WCsg==
X-Gm-Message-State: APjAAAVYogIUsZUdKaico5+U4iVB4Vz2edNET2C6Y9CtScOkGMHfUwEi
	8lOQIGNl1j/O1ofZ5OvMVhU3MzZx1kXQ9pQsiT8Yn0uOv50wqNS12rzxzQVmHgf+wBjNQgF8OFL
	vV9SQTWM1PCd0YDmwSeFZBBzy1Y1FSO7ExMxek/Qy1pMqoaOAtGFNQuLC1o+dbtrUUDPapKtMTn
	eO6wo+wBqfMibdjIOGsSs427sn0lBFXm9cDNkN+uso6k1vRjbRaXU1/CvTynYEqJFlMm+f9Rws1
	85ogx/1y/n/O9v6Q82NJ56b8BUs5ZzSV0cjRh4dopKX20DijrpYFNW+xmA53ZsMi98VyBxA0GPg
	rclmiCo7RZcjn3YNONMM/s+Db6l9BW9mSYng7sbHTNnYSieRob7Ctw+4sJo2cAYNeBJLJMObHTO
	6
X-Received: by 2002:a81:2cd7:: with SMTP id s206mr26879266yws.22.1552325131453;
        Mon, 11 Mar 2019 10:25:31 -0700 (PDT)
X-Received: by 2002:a81:2cd7:: with SMTP id s206mr26879208yws.22.1552325130554;
        Mon, 11 Mar 2019 10:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552325130; cv=none;
        d=google.com; s=arc-20160816;
        b=KbPukNd752vR2hRQdM94Gtuga3Mv8DaxwNhKMiB3zAZMGoZkCO5g32CdH/PlOvqugG
         iwCzFmk1FYTJIS+j29KTJODq5j4ZGDRlKMd7PFb5y1IiV2hXneiF7za0WaFmx0Z/eY68
         9W359aDFtSnCCOkrcC4iyrsQhFjCDKD0wamKrA+eknxn9PILpHwNbM6Sl/mQOphIpCsZ
         84nOYGgBA/s0b/U6VvWUZyk1P6V748brlonsDqx6Q8dgY4Yd4rECCQnGJ/KLgHOsUXnu
         XRod8rZs3YzDshDB57CPb8I7N+Dcj10Lypterf1lv67KB+9vo306SKqyyyqANN01jgi6
         Oh4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=f/08Cea8rl1auJ0ztvMCqTFjGtaWSYM7AUW8AvuH/RU=;
        b=uuAWD8HSRZt4Pi+riK/4cRawI0Fihe42lhD6nrwMn5qktPjUSurEFBFyRzJLlnC1OY
         udiSOrorFzFuBdxKQok4PrLgxK/wZw7D/AXtUV7nson2UQOhS2jLGBbblY0pax97hteH
         H7SHlf3JudtR+YJMc+qGqw8mH/R/Xwufxno9jgjLHzZTZAa082s4mmBqsMuaZLxuWUej
         jOXhQSbfZ4CYJn444rEUJaWu8SVHCbvwV462HKJYK65sT8BMEqEWCiPoX7Tlp5NeXhLg
         OuiOF1az6yND2QNx0Psp/Bl+xk6CCtRKK3NR4FW0ioewPMcU/dBXAHqAHxdZv3nQ+/on
         QwmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=A0QAa7xg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor2584999ybl.80.2019.03.11.10.25.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=A0QAa7xg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=f/08Cea8rl1auJ0ztvMCqTFjGtaWSYM7AUW8AvuH/RU=;
        b=A0QAa7xgCQYBpQuFa1awMJf38b2jg+etnRfvYDr66i3IXqdjSawonGGo2ICZM74Asr
         o6S9TIyGUWOIBts5qq8xc1Z+kfHH66CYpNPsnj0aD/swB3Mg/4e2FlUeZRc3AgJpmtN0
         EFs2KR9cIITJLbNZ+C9dIONuJuEtvYFmjYFOLLHLytrhz+mNIcKz8MgkzLxc2P77eagQ
         n5MyurlbC5t4Y4MYhS+bn1v7sDxmqHD1IboTDMXPedkG/tkwapmjtNAxtQ5v4Qh1pP7z
         jRivnC6dNZuA7NqLiNGo8mjZzjGgRp4THrZqVPPP0JFC02BcFhJKRmygRZOZ4MqAMfr/
         svog==
X-Google-Smtp-Source: APXvYqwZgrQea8FmLekPNMPenwnIlyxxrt87gJ6eaPSRwYTYSYUXxhPpQFzlD+GmKLLIR7+mqlCnqA==
X-Received: by 2002:a25:61c8:: with SMTP id v191mr27629102ybb.489.1552325127865;
        Mon, 11 Mar 2019 10:25:27 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:3c60])
        by smtp.gmail.com with ESMTPSA id b7sm2994000ywa.86.2019.03.11.10.25.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:25:27 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:25:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 3/5] mm: release memcg percpu data prematurely
Message-ID: <20190311172526.GC10823@cmpxchg.org>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307230033.31975-4-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 03:00:31PM -0800, Roman Gushchin wrote:
> To reduce the memory footprint of a dying memory cgroup, let's
> release massive percpu data (vmstats_percpu) as early as possible,
> and use atomic counterparts instead.
> 
> A dying cgroup can remain in the dying state for quite a long
> time, being pinned in memory by any reference. For example,
> if a page mlocked by some other cgroup, is charged to the dying
> cgroup, it won't go away until the page will be released.
> 
> A dying memory cgroup can have some memory activity (e.g. dirty
> pages can be flushed after cgroup removal), but in general it's
> not expected to be very active in comparison to living cgroups.
> 
> So reducing the memory footprint by releasing percpu data
> and switching over to atomics seems to be a good trade off.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

One nitpick below:

> @@ -4612,6 +4612,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	return 0;
>  }
>  
> +static void mem_cgroup_free_percpu(struct rcu_head *rcu)
> +{
> +	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
> +
> +	free_percpu(memcg->vmstats_percpu_offlined);
> +	WARN_ON_ONCE(memcg->vmstats_percpu);
> +
> +	css_put(&memcg->css);

Nitpick: I had to double take seeing a "mem_cgroup_free_*" function
that does css_put(). We use "free" terminology (mem_cgroup_css_free,
memcg_free_kmem, memcg_free_shrinker_maps, mem_cgroup_free) from the
.css_free callback, which only happens when the last reference is put.

Can we go with something less ambigous? We can add "rcu" and drop the
mem_cgroup prefix since it's narrowly scoped. "percpu_rcu_free"?

> +static void mem_cgroup_offline_percpu(struct mem_cgroup *memcg)
> +{
> +	memcg->vmstats_percpu_offlined = (struct memcg_vmstats_percpu __percpu*)
> +		rcu_dereference(memcg->vmstats_percpu);
> +	rcu_assign_pointer(memcg->vmstats_percpu, NULL);
> +
> +	css_get(&memcg->css);
> +	call_rcu(&memcg->rcu, mem_cgroup_free_percpu);
> +}
> +
>  static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);

