Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14E6AC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:44:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA31620811
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:44:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA31620811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78B238E0004; Wed, 13 Feb 2019 13:44:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73AAF8E0001; Wed, 13 Feb 2019 13:44:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 605BC8E0004; Wed, 13 Feb 2019 13:44:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 083F68E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:44:50 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id l5so1213270wrv.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:44:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rNJvm99bDTtptQ+RLOs54td7gJbvzcjda8zpmKU84oo=;
        b=sorK7peKNT7c9/82B3pLJyvUarhSCtMoE0OgPiwj/5ZUFhaRTtfh+ldLznuP6JStZm
         vXH/Fn1rbKLKBsfTlDQvVzi1pqoDf1wE0uEtjOIkoQeWHBJfHVr0hJK8Sc4iD/d6wM/l
         NV0S9+adYhxqZIk9+8d2F/RVORAzBrpZSSWcHxvP6WZfi63Dyxdj1sBueJyQvzipCEuT
         k4+4n7ooPFtUU4/1gxAeWiIqO2bRP3BW/broWAEvHPrmsAVKSrypQFyWzc//NMBX7en0
         40ZSbs0YA/cnfJLlkhI+BcTSkQK1yqRkUkVdVqMXHU7ng2r7F9GbIw00T+Qv3a3qZ4Ym
         22XA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuaafRt3zLM4PbNqd8Rzkr97WP4HnCSILDM8fbg/Xh5n+bvW/spi
	OAhe5MXN1Pk98aEzzaUOpNlbUvbNmLN4ZgdG7jkT7QWz1DMasaBzFsnAWZVQMEeUMzGJ47FRkA8
	+QuNloKk4mvK2OamPhD1dU1owikjT5zbt0NZ/kco0moN9GONkqPXmkikYfgASN3xEvA==
X-Received: by 2002:a1c:f916:: with SMTP id x22mr1477619wmh.87.1550083489575;
        Wed, 13 Feb 2019 10:44:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZH1+RyaBTgaOw/GekG1YjqOtoBX9XZz1TqsLc3m/HOUW36uIGrPyp3skO7je6kNmvV1ftp
X-Received: by 2002:a1c:f916:: with SMTP id x22mr1477588wmh.87.1550083488787;
        Wed, 13 Feb 2019 10:44:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550083488; cv=none;
        d=google.com; s=arc-20160816;
        b=j2go05DXFdPRutSGVWW0IGfMuD/wa7kF8B13M3FOLihVa71tsc3Iw0yTln3Sq5m7Xq
         Q71KjSWIhtq5Itr4lFcQGmKpyrm1g2rlPry6SKosgPSUH05qZjJcN4+Y7DqaZrb9BUdj
         +zNtK5qqFpXCUIfAE057aB2U8977fgmHoHtP8biNC4lj0bVLoSQD58J6EaFNoIygsdTP
         qgBESbq8n4+Dg5F9MeqMIJTrG+SK3on0gQjqxoZbKzd64wsWnVeGptPH6jafevj7rP1U
         jZM2BintA6pKBYUz+O4s5JiHWfGa3drTqij/jYvsvLSUCCDBM80frDcT69ePiwXYnPHJ
         hLwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rNJvm99bDTtptQ+RLOs54td7gJbvzcjda8zpmKU84oo=;
        b=zuq+otb8u3vqzMKFy5cMEcKr/SM/ITq7RZaaekeaVZ1Ma2qqRGZwV6oQLMfYBmFMIU
         hyuTOEJ8JRH4h2rtMNd0s5F/zu+pLTrCAfJ9SyTkK7DHxMEy+hLQy3silwGp+K6t4Vrx
         2dPgYGwvaI2iUxAu1xbVEuJ+tNFjzI0XdnCbBcO2xtpbiknMUm1sJFNhh9W54N0tzvmE
         GALkTl2qupNFhinD8TLD8uwo6zdQkUFnPs0h/7gtodKS2JI8bQC1WHVUWvAAw6Fg4+Jd
         aNtTrYQU+2FOiAiJF+yTY5NXmI0kZ2F2c9i2f3mSVqB19Hkc8uJAbuP4YOWFojksEpeh
         jbVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z16si19395wrw.184.2019.02.13.10.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 10:44:48 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 238DF68C8E; Wed, 13 Feb 2019 19:44:48 +0100 (CET)
Date: Wed, 13 Feb 2019 19:44:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 7/8] initramfs: proide a generic free_initrd_mem
 implementation
Message-ID: <20190213184448.GB20399@lst.de>
References: <20190213174621.29297-1-hch@lst.de> <20190213174621.29297-8-hch@lst.de> <20190213184139.GC15270@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213184139.GC15270@rapoport-lnx>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 08:41:40PM +0200, Mike Rapoport wrote:
> csky seems to open-code free_reserved_page with the only
> difference that it's also increments totalram_pages for the freed pages,
> which doesn't seem correct anyway...
> 
> That said, I suppose arch/csky can be also added to the party.

Yes, I noticed that.  But I'd rather move it over manually in
another patch post rc1 or for the next merge window.

> > +void __weak free_initrd_mem(unsigned long start, unsigned long end)
> > +{
> > +	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> 
> Some architectures have pr_info("Freeing initrd memory..."), I'd add it for
> the generic version as well.

Well, if we think such a printk is useful it should probably be
moved to the caller in init/initramfs.c instead.  I can include a
patch for that in the next iteration of the series.

> Another thing that I was thinking of is that x86 has all those memory
> protection calls in its free_initrd_mem, maybe it'd make sense to have them
> in the generic version as well?

Maybe.  But I'd rather keep it out of the initial series as it looks
a little more complicated.  Having a single implementation
of free_initrd_mem would be great, though.

