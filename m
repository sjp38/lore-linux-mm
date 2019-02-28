Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80496C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 239A42183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 239A42183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 758558E0003; Thu, 28 Feb 2019 06:27:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 708E88E0001; Thu, 28 Feb 2019 06:27:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61E798E0003; Thu, 28 Feb 2019 06:27:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23C1C8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:27:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so4535444edd.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:27:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pv3BIGyaiNpY3fstVBDetyks/ciXihpveFEdLKJEvaA=;
        b=X7/Z6z6hgW5BcBuw8mO4Z5OP+iWh/HAhDbqnvinMYfec+rBp8UiGkw1VlGtxfDIokm
         OH9NaotqTsFSW9rlPPuTAnuKGDAR7aNeNtlcwiPi9jeYwI6QVjj8dLlSMhQ/ydURinfg
         RGBC+63bQmloVvpkYF3XLM1Jx6SwJC35SMt6jb1/Pr3zKUNB9RKH5pAf/Sz8aK3EgPHT
         kqgX/v/RxEqbCpBXPJqNsFSnciEgGISL8ebRQVXCknAsvkOLneTK9GdzFAiQiMK5IosK
         AKzPLDaX6X6suDAlpmSPbuci6qZRLNDWbomQsIs9xG1MdalwfARCKWOA6uY3g6BzbfjY
         oF1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAubiCgcBteQb8uzaYEfeSZH0VKoFrPgOhjNSYOJF+XJKxe4NaRuD
	MM5GtbTK49KPirWdnseO6nxuHhEgHEhP4odMHN8j/O318ZghVtw0p5t9vsuE/2ZAgEWy2Qs2E+u
	iB+gCe8K206nTC8MGvVGf4VfSQ49/Q4Miof+9M8yNFODEp7a76a53PqpHF+p1w03FYQ==
X-Received: by 2002:a17:906:6a43:: with SMTP id n3mr1738604ejs.0.1551353277706;
        Thu, 28 Feb 2019 03:27:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib7JhBkmpz/8FBIEAl/MEORQugfrHJk8VDKp1hAzWXO08OY54h5YcsiohjGgFoW7BCr9+Dg
X-Received: by 2002:a17:906:6a43:: with SMTP id n3mr1738541ejs.0.1551353276535;
        Thu, 28 Feb 2019 03:27:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353276; cv=none;
        d=google.com; s=arc-20160816;
        b=mswiBP09kmtH1VTFgfjm1XkSM9Na8EDY57eoG676f2avH+/IJFj26CCd9YqJV2g3LG
         IoYVJOyd5bhEns8fnPB9IAIpSRQUcBhuYFPvG5xOdzSqd682GUj1X36kisbJ5G6CF5qS
         veFzxCAcEMBKQu9xgMCgHpUqfDNnWBmh+cIzeUdhGITGbizQ9xNg/LmS3xg1VJuieKb7
         7dB1WjLqCU/h5Yh/z2jm/vXusmz2o1y2QlYlGyd2n82oqWcjtBohSD2blNrEgpcKTOar
         l47fN3S4/jhvOQ0YHLsfPfwopRqSYUE13NwzYwco+EJQqsMQzKu2tfFtfzp1rZrt9NT/
         8pQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pv3BIGyaiNpY3fstVBDetyks/ciXihpveFEdLKJEvaA=;
        b=VwGbpFU69Lg1fUSHEYSF4WAjgaWUjRq50ZXyNlc72Ytc8xsix8Bgbo+vA/tFlNPSXA
         bBstSVApMF8VcPY88BwfW0sbyxdv4S0j/5jNar9j+Akk8WYNqZI+dca6J+A6j8a+m52O
         /RtOrcfcrndwfpSxY8MxnVE3ONknNaTz4Jus8oW+AXsYIClJzJlf+wPksLlr4KAJhA1O
         YqXnDY25sB1CCejgNosd9KnJm9lrMaBmXkoSGQs9AZOJ+m6diByyjo7qfiz03haZStdN
         WChaMeu43fHScwKYDNEX7O0o/AxnszERfkDf+fcqazY8h4fD2BhkBa7BqIxfv7sAk+/U
         kjzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id gr21si3632571ejb.81.2019.02.28.03.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 03:27:56 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id F40C91C1FE9
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:27:55 +0000 (GMT)
Received: (qmail 30911 invoked from network); 28 Feb 2019 11:27:55 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 28 Feb 2019 11:27:55 -0000
Date: Thu, 28 Feb 2019 11:27:54 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/4] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
Message-ID: <20190228112754.GD9565@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190228083329.31892-1-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 11:33:26AM +0300, Andrey Ryabinin wrote:
> workingset_eviction() doesn't use and never did use the @mapping argument.
> Remove it.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Rik van Riel <riel@surriel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

