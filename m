Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4004FC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 10:32:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFDDC2190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 10:32:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c23Q5Ecp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFDDC2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A3428E0003; Wed, 13 Feb 2019 05:32:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 751B38E0001; Wed, 13 Feb 2019 05:32:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6690E8E0003; Wed, 13 Feb 2019 05:32:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28DCB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:32:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b1so1393378plr.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:32:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GdwIZ75A3b6/46RR+VJh6VgKTuumQfgVmxslX6VcVTE=;
        b=WYDoeoHMwgpHt/mzzk6TEz32zKPNd7t1iUdxTlUVcUEu/P3knaz2pY7lqZ6gr6aJUq
         ebFhRkhJCBAyBo6rMhdzcjCbxbUf5rOdxn/IgWXczioKneBs/WELQJj69Tc/vpoKL58L
         Ew90jlMnrZGpSSqcu4vrBPrIso5LyjGhSUnt3vtZ61Cu61SAVCjmTy8xStSKl029oj9w
         bPxi+EmkVhWntOtti72fpkr1Z0RktyVXYgDVHMYzMlrv9lX1AzNOeAkabj/gm79UKc/D
         misJSb1WaXneE6UaOzeSuR4FkfYzYx2G/KCqKbyok7Y4z+I/pTBDlJH8XQUkv6boakdI
         jeFg==
X-Gm-Message-State: AHQUAua/RMuAjSstZOuNVsQuH9kY0x5O6hylnHoujmSOLK5D8mXVDmU9
	yig1dHz89Lvo8smVQ10PQktYZDc+AgXOkl7Vh/Vm97K0m6yC+/tse5IfolS01zWWe+nE4fsWowO
	AlKyqvub+LuzB2PmgjwHd5Gb+4YuwTym4dtcywCR9S2IZmnZTl6/HDus+cabtBFtjeA==
X-Received: by 2002:aa7:8199:: with SMTP id g25mr9040574pfi.46.1550053965869;
        Wed, 13 Feb 2019 02:32:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhfWjRIBCRYBxNU0+4FgobC3UPlUmudpiEiyCfhGqCi8VGrKOCreJOqcM2R8wOWvg7pTpS
X-Received: by 2002:aa7:8199:: with SMTP id g25mr9040516pfi.46.1550053965207;
        Wed, 13 Feb 2019 02:32:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550053965; cv=none;
        d=google.com; s=arc-20160816;
        b=Zb+7fjOuYD7g2p00yhrrZ55jnnrtCiVuXWAlfdqZ2QKLqzUERBP7l4K0BthuimpaYA
         cSCUsIuN4+F7uEftt2/+76JxA55OtTyc/KhRkkgi7PCQ3B/4EajXdK008FRAtK5tS3VN
         CtSNHiE6sDORdt5cIB6y/eABS+quyCEpEqAVhDiuHOGySjXohh7MuWFwBihSEdvrm4Wj
         ofK0+GIyR8P5RD7R/aNLSKHQt8CoUnYVkv2XMgWu+EvGt+y6Hvp9t+6TkxQc2V4NjbYQ
         fc/Qnhnz1TSZe0vQ42IjNFH+DzTVTgYA5Q7E8P78qVDK3p18TxPo3JIq2AhO8w17Gp+v
         8AHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GdwIZ75A3b6/46RR+VJh6VgKTuumQfgVmxslX6VcVTE=;
        b=V9uU36bw8uPBB/8KNeCJ1DVoBH5fGJ4RFeOO088ioMxuOYu0YIhnx8fTbQNrJot1hW
         YMGkoc1MA9fj95K1nS/8BZXu7H7tfVxaBInd5NEeYP2GJjy6bX8oQyzVNjOzfkNvC2uq
         1GnlI+ql38BdMqffjNoeoRmdkirv6B5ZSpLsuW3clVb9u52diFbPbC/beIIku11uIqUE
         ZNl+RMU4Q5KC5dRdMkC6OU6AXiFAmLABzP3Y4MUUc/TyyknnOviLTC94TEo8awvs9k3R
         DkQtVEILj0xBNoxl2fNqih9EgShnbBYLSPA66tijN3py7kDg+hkYsEzrTi7eKmLThonV
         G7bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c23Q5Ecp;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a63si8463390pfb.61.2019.02.13.02.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 02:32:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c23Q5Ecp;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GdwIZ75A3b6/46RR+VJh6VgKTuumQfgVmxslX6VcVTE=; b=c23Q5EcpRVyBBdSUtk3FUPPsN
	2vulLg55mfkyKpYAubwYA53+JnAZ0pLFuQ9PfGchMBDd7pqTjLuMOav/br0DpMmo8gF5G+elcn8Us
	LFxFGZ5ENk+c07rMcHVa7uSsghjSD6FviO//iI0n1utVtGTSZlmTGd13l2R3JjFA2k3rJSJmTi5hp
	Pym2LoAmTPFYtR5ulo3a6i/JQjxE0g31mu8BHsb9853zBz5igkiJOwt61Eewp1gppTsE8Vchp9Ssl
	tXxARSAQCeh98pf1FAvR0biIxXEU6T8eupdPN4NCwczUi2AkquknB9MiyeJqtzUxQ1CyGFuMay9z9
	1t4j8xy1w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtrqD-000809-Lp; Wed, 13 Feb 2019 10:32:33 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0D06720D0C1E6; Wed, 13 Feb 2019 11:32:31 +0100 (CET)
Date: Wed, 13 Feb 2019 11:32:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-ID: <20190213103231.GN32494@hirez.programming.kicks-ass.net>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213094315.3504-1-mhocko@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
>  
>  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
>  	build_thisnode_zonelists(pgdat);
> +
> +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> +	pr_cont("\n");
>  }

Have you ran this by the SGI and other stupid large machine vendors?
Traditionally they tend to want to remove such things instead of adding
them.


