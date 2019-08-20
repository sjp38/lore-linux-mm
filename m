Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 038DCC3A5A1
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:53:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B655422CEC
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:53:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lr29nm3u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B655422CEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 352E26B000A; Mon, 19 Aug 2019 22:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 302676B000C; Mon, 19 Aug 2019 22:53:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0EE6B000D; Mon, 19 Aug 2019 22:53:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id ECCBA6B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:53:12 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 95086181AC9B4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:53:12 +0000 (UTC)
X-FDA: 75841284624.06.sense95_56305552bd927
X-HE-Tag: sense95_56305552bd927
X-Filterd-Recvd-Size: 4124
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:53:12 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id g2so2410624pfq.0
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:53:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bqlUN1RbXA27ROpphRzaYTA2mgCbmo3KU3uDDJtbs+c=;
        b=lr29nm3uGUjC4tDgF6auRf/OYsKefNJqZ7MSVyRTDeoGlrPjplxyn9dfl4B7QryWg7
         x2iMe30DUCe/+bRalNLIvdcqkkqA2y40Q4+Laqlxhe+Kpp/RuD7zB47Uik52cxzBuSrE
         +tGNU/BuG4845FxkLzP/MWpzfsG2SJShUa32NcjCz3HeBMpt16Uk6CMxj+wgsK81GPbD
         PCanrgFnXL+W5O10eya769ZA/qhWDd6mvxm/HX1PwGbOGYxPdUs86okmrqEud1qD9gne
         R5809FKmHRSZMLZ0ByVG2nNAQ6QpgIUO6NsyV4zu08Sz751NPR31SPBKgAOtpwpdgKdm
         G/qA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=bqlUN1RbXA27ROpphRzaYTA2mgCbmo3KU3uDDJtbs+c=;
        b=T1bl6eaVviWMijq2JTMzT6Ua9cXsUoOcFPe9EsMhLCMgv1PDu+b2CMdJLJ3cbatKXH
         Wk0CwVn4JUHRQMBSNfA+jtnYQTHa9m8VrrTMxc7aRYXMeZoaD14ieXfV5a1jmFicrL5Z
         ATx3OEKJJjdvAiw+e1gB8kB3JTlFiS9Aw3ztXkGVsOb4cXFc2xjVokqXmnMsp0+ybMaD
         wDqAWsVvED9VuISsPrIvVZ7tgAPuGxEv2R73cIK1wdeKDfp76T9yEYpYLjOrpXf0SzgW
         DFhSMvV3uL5q23OT7zvtlTqeXDj2UeZuTcSV5tIUoBCRs6WZXJ6gjsjBmWPMTjgNNLe6
         +SMA==
X-Gm-Message-State: APjAAAXVEl0DcSh5UTjEgr9NtjHbxAK68q8gbApoxujPavpDsllLxly5
	TIZSZHXjYYVA8Vz4KpfyIeA=
X-Google-Smtp-Source: APXvYqwJs1ADMhrxxHHKzA1gs2MWDS3cqhoQTiMn5DXjUNOd0nP1apznaWbmYbQNSscGREpSp2eJPQ==
X-Received: by 2002:aa7:8e10:: with SMTP id c16mr26972942pfr.124.1566269591111;
        Mon, 19 Aug 2019 19:53:11 -0700 (PDT)
Received: from localhost ([175.223.16.125])
        by smtp.gmail.com with ESMTPSA id k5sm20942706pfg.167.2019.08.19.19.53.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Aug 2019 19:53:10 -0700 (PDT)
Date: Tue, 20 Aug 2019 11:53:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Henry Burns <henryburns@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>,
	HenryBurns <henrywolfeburns@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2 v2] mm/zsmalloc.c: Migration can leave pages in
 ZS_EMPTY indefinitely
Message-ID: <20190820025307.GC500@jagdpanzerIV>
References: <20190809181751.219326-1-henryburns@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809181751.219326-1-henryburns@google.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/09/19 11:17), Henry Burns wrote:
> In zs_page_migrate() we call putback_zspage() after we have finished
> migrating all pages in this zspage. However, the return value is ignored.
> If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
> freeing the last object in the zspage, putback_zspage() will leave the page
> in ZS_EMPTY for potentially an unbounded amount of time.
> 
> To fix this, we need to do the same thing as zs_page_putback() does:
> schedule free_work to occur.  To avoid duplicated code, move the
> sequence to a new putback_zspage_deferred() function which both
> zs_page_migrate() and zs_page_putback() call.
> 
> Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

+ Andrew

	-ss

