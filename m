Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 903EBC3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 05:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC812080C
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 05:13:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K1dR2BTg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC812080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97A7F6B0524; Mon, 26 Aug 2019 01:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92C506B0525; Mon, 26 Aug 2019 01:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 841436B0526; Mon, 26 Aug 2019 01:13:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id 641736B0524
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 01:13:47 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E064252AA
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 05:13:46 +0000 (UTC)
X-FDA: 75863411652.15.ghost97_3e0f214173b54
X-HE-Tag: ghost97_3e0f214173b54
X-Filterd-Recvd-Size: 4183
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 05:13:46 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id d1so9841095pgp.4
        for <linux-mm@kvack.org>; Sun, 25 Aug 2019 22:13:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RS54P8xWhN0WpqilfX3CeJTlw03oZ0bA+FF2sB+7VdE=;
        b=K1dR2BTgQvrbOF9jRsFWIkPFShaGlCPz35NWloS4Fv+m6/EhuR6r9hhY22ZCmXh9nw
         kMho4xHr1YYm9HYipqrdH03DaX8Y5T8ABJFwn/Bj5djDVplrze3YMP/rRJnYQBK3agjz
         j/2nMTQ1ibl/XU4niUZX34IsaSjsYMktRp+9VB+fmx/e741XRl+bh+v5TNaAg/uaYOyr
         rl+5noSQB64GhX2EutHURwwC1CTdpokKQLJ9YugJw0VkZNuI3DUpH0F3NQKM0T7eZvTA
         FT43OfyGLj7Ip10kVzPL9y+Mx6HJL+s1iQgTZy/qAX5MLtmk9pF2d3XkJyFBVEO4shaa
         PqJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=RS54P8xWhN0WpqilfX3CeJTlw03oZ0bA+FF2sB+7VdE=;
        b=pebLW56jCi7VjFqP9h+fFUJtdRnB0Y6W1USo0gofePFJk8Ps/je6R+djIYFXZskkxW
         jzF8LzcP6tPRE6Tr2n82Sxowy5EuP1x3FnBjUhZf44yFrSPnBBHyNnlrjxS7VIEZM7vZ
         sNlRJ54711d7WdXe31azyiUzezGqJ4M34eXxZ4zEhKDTtEjEDnM95DT/xCuCFH7WXCdZ
         gWWEujRgyzfSXtZYVhEJ2WKaNW+OErMWkYMamG+EsHAN5fOGbzi67JdQ62hiZHEKVIYQ
         p65pvuXnsFlySKQBbgKCoVRto/58vea3VMl/fZAROXyJpnpsllNpSZOnU2eHd8q8BkMF
         P78A==
X-Gm-Message-State: APjAAAVx4jI0w2YCh5/3nL1LcrAvEdv7nc6bJ/aR9W+tHOx8z70KJ8eK
	PlX0cd+cEA5mvO7KTe88w4Sqxta0
X-Google-Smtp-Source: APXvYqzsH1YZgcoQJAmfj/sq9jg7AkDH4XHU8wEYr6A3wUzKAcmf0uIlpnUP9bwKVzxF7h8VFXxPfA==
X-Received: by 2002:a62:8745:: with SMTP id i66mr17899570pfe.259.1566796425463;
        Sun, 25 Aug 2019 22:13:45 -0700 (PDT)
Received: from localhost ([110.70.50.154])
        by smtp.gmail.com with ESMTPSA id r4sm10753832pfl.127.2019.08.25.22.13.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Aug 2019 22:13:44 -0700 (PDT)
Date: Mon, 26 Aug 2019 14:13:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Henry Burns <henrywolfeburns@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Henry Burns <henryburns@google.com>,
	Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2 v2] mm/zsmalloc.c: Fix race condition in
 zs_destroy_pool
Message-ID: <20190826051340.GA26785@jagdpanzerIV>
References: <20190809181751.219326-1-henryburns@google.com>
 <20190809181751.219326-2-henryburns@google.com>
 <20190820025939.GD500@jagdpanzerIV>
 <20190822162302.6fdda379ada876e46a14a51e@linux-foundation.org>
 <CADJK47M=4kU9SabcDsFD5qTQm-0rQdmage8eiFrV=LDMp7OCyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADJK47M=4kU9SabcDsFD5qTQm-0rQdmage8eiFrV=LDMp7OCyQ@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/23/19 04:10), Henry Burns wrote:
> > Thanks.  So we have a couple of races which result in memory leaks?  Do
> > we feel this is serious enough to justify a -stable backport of the
> > fixes?
> 
> In this case a memory leak could lead to an eventual crash if
> compaction hits the leaked page. I don't know what a -stable
> backport entails, but this crash would only occur if people are
> changing their zswap backend at runtime
> (which eventually starts destruction).

Well, zram/zsmalloc is not only for swapping, but it's also a virtual
block device which can be created or destroyed dynamically. So it looks
like a potential -stable material.

Minchan?

	-ss

