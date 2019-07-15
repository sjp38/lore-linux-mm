Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB535C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 844972086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:22:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mkmBCeRa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 844972086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08BFB6B0003; Mon, 15 Jul 2019 18:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03D0D6B0006; Mon, 15 Jul 2019 18:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6E506B0007; Mon, 15 Jul 2019 18:22:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0B156B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:22:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so11291750pgc.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:22:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DRx4kk00eIMsyOHJO3CXzRkH1iQ625JpZFJYy0sZXZY=;
        b=hX1yPGG1FtfaokMdD8B76w2p9U2gvOXvgz3spueXdT1vy+rVPdv9Ewp9Dxoj1U8mX/
         K3ka6lOO67LnLveLfj61VbW5+MTVLrEmk6DxV3QwQp8rIxJpBxt+zPaC+cKG7t38wLfQ
         HoeglzYeZ4QGl4CkLR/rtFqwf+tWy2NVqd4jydWw3hTbEhMmLUERqEuegrRfJlsVBTfB
         ULvHhXDh3Cr9jTcjaZxFakrcNA54SgiW4A/dvnF5pC8XvCsBn/BVBc8mcf/YsoVU3O1s
         ngz7rs5ewf3oMZSjWu7I+VqH0ELELItZbrLhhxgF7SoyMPge1rvv8GiP1YqZRch3e3LM
         JUCw==
X-Gm-Message-State: APjAAAX+k1aw+EUv6IBy2MRCielFUKb98ZdOKFeqpR1QrrAihiW0+d/J
	j+XIDex/NXMCCXicOeUwLU9VCDOsrWw6wrt4dzK04AOfbG1/ULYG1DA20Bc4ax03nrBEK3U0cDY
	E926DdtfGIZayk+Ooczn6VzTREPYEATTv/NW6DAXAgqcAcYrOxntG2MtAfEVhr8Fs3g==
X-Received: by 2002:a65:6406:: with SMTP id a6mr15928072pgv.393.1563229377200;
        Mon, 15 Jul 2019 15:22:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpW/BlXfGKHnWR61paB1sNniK6GsZegx8zxUvstP7I1xt73gyUInDPCKIo4IqPlGhcKc8R
X-Received: by 2002:a65:6406:: with SMTP id a6mr15928026pgv.393.1563229376376;
        Mon, 15 Jul 2019 15:22:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563229376; cv=none;
        d=google.com; s=arc-20160816;
        b=LJWW3iskxIoE0kA6MNzmr+2H1FiiqjJdEJ0fOJjioX4KiVG1KlCRt9lxjcE7pq4Wu+
         4XcscbxBBeXm3bLQs2SChNPj4ysJLYIGBA/nyX68zb9DvsCwyY7gfbX0z099UCxRWt6n
         5DVmg4efikTJin/44FR9wtNxPcqCQa1KzoRJRpnXbQBVe+7dpDasHRSoVvZen8wRCTji
         3/VDAPLonvrIANNYkavTfvUzzTY+7WWo7zrD1OKWgLnYJyGS5aCidv2akCbKTd/9aNpI
         +4Bz8L1tQsmlp+LDeobOsdICgmp/aXBV3a4SdRfdAbYzVWi3Jo/edlWv/fke+hjs3ksM
         kYMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DRx4kk00eIMsyOHJO3CXzRkH1iQ625JpZFJYy0sZXZY=;
        b=bggBf6gRk9A5nyqz13tEIUhaw0Om6JGEVCml8cDMQiKc9nVSzPabIrS8fLBTFSkrvG
         hiE0X4JWN2l0f2Dcd4ukPDw6FS8q0Z4YEP3Rgr40bf20ywsG1MM2j1RBWul+rAJNWC6U
         4Nclpu6fPPqLJLb7UaecFGxkXkAhsJsI25kYunOSbHExfKCRzDhuo8W95kycaN0DDm7T
         YE90PJsqeg1VDUw738lj98Z50Yaq/TgXA1eV9w1xYyTUZ+/1nFQwyObNZe2TJOad1PbL
         KVrytCNfhqePLn9C38GKJ2UvEN3+QtHHrqV4+5lojVjlhzVWEqU9VbY3Q2/jRqSmHxAN
         SJZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mkmBCeRa;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j70si17582459pgd.500.2019.07.15.15.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 15:22:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mkmBCeRa;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B979F2086C;
	Mon, 15 Jul 2019 22:22:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563229376;
	bh=qowy83W6RFvg6VqaYACFtXRIkdAHGeDCXOAft24WRvw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=mkmBCeRaDfmgqQJm6EUYlFqqZGiYyyfY1mzj2gjr+jFh4CjW1oamupAM7hmpVT2BS
	 u5OIh16oPoioZcQnt8Aiexb4tNadEDeZZj4IEyb3rCxDONNLuwQPAnqX9I4xCh9bLh
	 eow7nebDEBLAoDIhhYoyvp2198l8D0/CoU3+MlOU=
Date: Mon, 15 Jul 2019 15:22:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent
 behavior for unmovable pages
Message-Id: <20190715152255.027e2e368e16eb0a862eb9df@linux-foundation.org>
In-Reply-To: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Jun 2019 08:20:07 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> 
> Changelog
> v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
>       immediately by a separate patch (patch 1/2), and this is also the
>       preparation for patch 2/2. For the details please see the commit
>       log.  Per Vlastimil.
>     * Not abort immediately if unmovable page is met. This should handle
>       non-LRU movable pages and temporary off-LRU pages more friendly.
>       Per Vlastimil and Michal Hocko.
> 
> Yang Shi (2):
>       mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
>       mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind
> 

I'm seeing no evidence of review on these two.  Could we please take a
look?  2/2 fixes a kernel crash so let's please also think about the
-stable situation.

I have a note here that Vlastimil had an issue with [1/2] but I seem to
hae misplaced that email :(

