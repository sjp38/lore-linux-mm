Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C862CC4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C73214C6
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kM7G97jx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C73214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDE5A6B000A; Sun, 15 Sep 2019 17:38:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C68E86B000C; Sun, 15 Sep 2019 17:38:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B549A6B000D; Sun, 15 Sep 2019 17:38:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 9548B6B000A
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:38 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 30282180AD7C3
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:38 +0000 (UTC)
X-FDA: 75938469516.26.queen94_4b5c9e3f34505
X-HE-Tag: queen94_4b5c9e3f34505
X-Filterd-Recvd-Size: 5063
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:37 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id b128so2667914pfa.1
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=iqcLBM+n789oO9D4B4n7QIy38Iivlg6PKsWpya+em6A=;
        b=kM7G97jxdHw8YVzdyyaHeQYLaPoKqJFxCB3Og1jctbDSOqF/U5eyF/dDAAEnz3Qvko
         GsFj7yyGpriBpbxWDbnJRo74hVLWMnOl18nGYE23szfaWTnL3kxNgQck36BxjJGV014/
         lymowmIpR9a+tv/A3e4AUZTWHedab6fgqulHsbFrbgIp9qGqYLguBeMVuhTA55O2WOOp
         zEnqGaFwxCsorhzjcpzSYvhnhz8D7mjWFLWRcbHS4Yp60gT3HarRlTQsOtS0nGThnlrO
         cU0EM7d8QVy5dMVZ4sxegL9kl5iY3Wi/ZiGaU9dFDgofJuGG9W9+5WUQalziTFX183+Q
         9kfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=iqcLBM+n789oO9D4B4n7QIy38Iivlg6PKsWpya+em6A=;
        b=uA9gnXeSXaGI/1Pntbhe0GoLuRDTYNZ4WhR6ySCfwGtdv7m6YS+bdoM7LAI4e2u9TI
         GBw0N5T55x0rbMwTWjYm01THnVLknHJaM1eraX81bM/BQ4EUDndB1CFXOwMJv+MVJmsz
         ee/HsJvx7b8RSvrHT6cO5Y7yK/x50eVHQxdkd6DSzOXDbq1+HWD2eVW4dvnMdejCTqmh
         HM6+wrO1OjSkcwUgd2vUsUnJLngWQhX4RrGnMOsRfmUfi4Jm0ro0PxQR/Z+m8zuq8/Go
         o4sd3fQU6C3bqrOhDqfeOcKY/9Jpr3G69cqgtjTgCIIXEvUhHLljBzBDbt+cLT05ABR5
         teaQ==
X-Gm-Message-State: APjAAAXOu8RJ8w0PT+njLa6O+XfV9wqaMYxKVJ+PfaelbLvo7Lp8BfmN
	lgDpHAjINI4a3i18vwU1toWROchYKEE=
X-Google-Smtp-Source: APXvYqxF3+647bKDGiEPA1W8sdT5qORaNLeswIi1yi2+um9DvosoquGyl+pjwddqV3Y3L0Ncl0v+6Q==
X-Received: by 2002:a17:90a:8006:: with SMTP id b6mr17107382pjn.4.1568583516601;
        Sun, 15 Sep 2019 14:38:36 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id c128sm25937293pfc.166.2019.09.15.14.38.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:36 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 5/7] mm, slab_common: Make kmalloc_caches[] start at
 size KMALLOC_MIN_SIZE
In-Reply-To: <20190915170809.10702-6-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151425490.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-6-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> Currently, kmalloc_cache[] is not sorted by size, kmalloc_cache[0]
> is kmalloc-96, kmalloc_cache[1] is kmalloc-192 (when ARCH_DMA_MINALIGN
> is not defined).
> 
> As suggested by Vlastimil Babka,
> 
> "Since you're doing these cleanups, have you considered reordering
> kmalloc_info, size_index, kmalloc_index() etc so that sizes 96 and 192
> are ordered naturally between 64, 128 and 256? That should remove
> various special casing such as in create_kmalloc_caches(). I can't
> guarantee it will be possible without breaking e.g. constant folding
> optimizations etc., but seems to me it should be feasible. (There are
> definitely more places to change than those I listed.)"
> 
> So this patch reordered kmalloc_info[], kmalloc_caches[], and modified
> kmalloc_index() and kmalloc_slab() accordingly.
> 
> As a result, there is no subtle judgment about size in
> create_kmalloc_caches(). And initialize kmalloc_cache[] from 0 instead
> of KMALLOC_SHIFT_LOW.
> 
> I used ./scripts/bloat-o-meter to measure the impact of this patch on
> performance. The results show that it brings some benefits.
> 
> Considering the size change of kmalloc_info[], the size of the code is
> actually about 641 bytes less.
> 

bloat-o-meter is reporting a net benefit of -241 bytes for this, so not 
sure about relevancy of the difference for only kmalloc_info.

This, to me, looks like increased complexity for the statically allocated 
arrays vs the runtime complexity when initializing the caches themselves.  
Not sure that this is an improvement given that you still need to do 
things like

+#if KMALLOC_SIZE_96_EXIST == 1
+	if (size > 64 && size <= 96) return (7 - KMALLOC_IDX_ADJ_0);
+#endif
+
+#if KMALLOC_SIZE_192_EXIST == 1
+	if (size > 128 && size <= 192) return (8 - KMALLOC_IDX_ADJ_1);
+#endif

