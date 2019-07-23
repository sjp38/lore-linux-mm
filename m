Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AA86C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:17:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAC0F21BE6
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:17:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RcjKdLTG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAC0F21BE6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614D86B0003; Mon, 22 Jul 2019 20:17:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5876B0005; Mon, 22 Jul 2019 20:17:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48F448E0001; Mon, 22 Jul 2019 20:17:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 153EE6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:17:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so20862539pld.1
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:17:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tsC0A1CH1U9O8xNQgvl6L4AJAPrF2xKc99GA6nm0iPE=;
        b=FEq3DCGezPF1XN/yjQWvcDbIEXhkir0AJA+SIl7773H8ErxLIjCxZR4CV9JJmLTuSY
         YdyveosXQrCJbg7LwkZX9si8ALcypnCKOqQ7vaMCgwd/nlBZdYoSyCUAz0Gtd07jmrSb
         p9B74O0exz+vNd5NouDLoH16409GtDsA3bxUyK+4DhtR/moT8AGhiAQTapoBoSHl9nYG
         6v3eR+JezqiJQVHsT0op7yE90LI4/YiHHrjTHMxStIU0UjyosGBCyw/ZVKuzXSO7VGpk
         0hmyNdTl3UjxeJ5bnee1bSTLX0RgADi2x8uSF/ogcAJWZ0kL0bow7WjyTWvn/l6AvdWC
         SLfQ==
X-Gm-Message-State: APjAAAUTw5mNFPtFpEi/ixamATtlxVqG4MnNFCLyZD8GIWFM8RuoN8WI
	HA96D/HW5IWmIVZGcHaIckz4NvhnHpc8SbA7C7xAWSn4T9+bT6sO1SZVQcoe0f42uD4fXiSHulh
	PwJvSCjahc0Gi1nNHOMQyQcwIgII59pNF3zoMeUsm3HR+s93irPRnyqJKa/91aUWz1A==
X-Received: by 2002:a62:2784:: with SMTP id n126mr2911166pfn.61.1563841022633;
        Mon, 22 Jul 2019 17:17:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlqF5FtOy3bO7kC6aLIebS8DKv3UioRo1+LRVvhYVsYWltZhbsXT138jNRVxVmNbHn75uB
X-Received: by 2002:a62:2784:: with SMTP id n126mr2911127pfn.61.1563841022009;
        Mon, 22 Jul 2019 17:17:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563841022; cv=none;
        d=google.com; s=arc-20160816;
        b=WHTkrW8kzJ4gL3MUKDv4+5kdkm46+2n3koyuFCbvc3JrdD38P1kQ0bQ9HppCQX3tf5
         07zinLgoQQr360ELRess05git/1tZPtGQuzqmbL9urQ0TnXVMQ9CW+pFBba+OGFaxaLV
         86mLspXFKtO7hdLQnjIHMlAa6jfeLL0ss/OzOhJUIqYPhRiOVU+wjnBuWanT5FaaFVA8
         RkGQClSpOWHLWG+d/YSDWLR4I3Cv/tLBxcB1VXruOUa+TjIC7DTlcaeQf6+RmE6BMDDv
         RWuOmX7/4BPVuUzxs/K6fsi8wARh59wo9SeAvCaXzrQBiYHYq7Hvxh8jOdA4TA5Qlq+q
         bjmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tsC0A1CH1U9O8xNQgvl6L4AJAPrF2xKc99GA6nm0iPE=;
        b=sUDfjpYda7Idq6jspgM6rZx56ViiYLBhHgV51sLupodB1o8094WIm1YZH9fX2lkyIV
         b0U3uHhNUTPscR6C3JcxCOB8PfKK2RpuTJjyRFS5YmjsjaHjZoNypFJYlnCvsromGQGR
         iTNKvu/qnuXOtlc7oHRqf8GbJWZWJhzqH/uoQEK6N5ITx8/gEuIpB4Zd+mDrVHNJVWJV
         uhd/uvtlqAI6Gw1I93/gx3spU8U9Np7zeOj8/muM1Wu5vdun9iP/DtuXoQWbLb5Ym74L
         5uEmZ5OY8uYgxyblnfvjeNAO/awdMTni9jqQA0i74t01u3AMcrbIH+hRjA7p5c7dMjnz
         5kuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RcjKdLTG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a14si9988225pjo.40.2019.07.22.17.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:17:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RcjKdLTG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 63FC72199C;
	Tue, 23 Jul 2019 00:17:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563841021;
	bh=6sNYOmPiY7UCw0exdP/b63K7iFz93gz485PsRBuq5N4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=RcjKdLTGcrDx+vgVAg1mB93hVglku8cYcZmOEtJOpvP9q93LXrkwicwguFm8j4KAb
	 eKQaZShqEm2iXJvp4y9cuNM9z918HPN8OCIRrJ7+woPXdtzyUYg4sj9Qeko2YCSgSU
	 t1/OHQk/3doElaOra5SAYzHAVUaKH6NuGE4fHsyg=
Date: Mon, 22 Jul 2019 17:17:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Vlastimil
 Babka <vbabka@suse.cz>, Yafang Shao <shaoyafang@didiglobal.com>, Mel Gorman
 <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/compaction: clear total_{migrate,free}_scanned
 before scanning a new zone
Message-Id: <20190722171700.399bf6353fb06ee1a82ffaa5@linux-foundation.org>
In-Reply-To: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
References: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019 05:54:35 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:

> total_{migrate,free}_scanned will be added to COMPACTMIGRATE_SCANNED and
> COMPACTFREE_SCANNED in compact_zone(). We should clear them before scanning
> a new zone.
> In the proc triggered compaction, we forgot clearing them.

It isn't the worst bug we've ever had, but I'm thinking we should
backport the fix into -stable kernels?

> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2405,8 +2405,6 @@ static void compact_node(int nid)
>  	struct zone *zone;
>  	struct compact_control cc = {
>  		.order = -1,
> -		.total_migrate_scanned = 0,
> -		.total_free_scanned = 0,
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
>  		.whole_zone = true,
> @@ -2422,6 +2420,8 @@ static void compact_node(int nid)
>  
>  		cc.nr_freepages = 0;
>  		cc.nr_migratepages = 0;
> +		cc.total_migrate_scanned = 0;
> +		cc.total_free_scanned = 0;
>  		cc.zone = zone;
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);

