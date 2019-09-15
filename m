Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA742C4CECD
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B65A20692
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AgydtWNm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B65A20692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 255A26B0006; Sun, 15 Sep 2019 17:38:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 206B26B0007; Sun, 15 Sep 2019 17:38:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A60F6B0008; Sun, 15 Sep 2019 17:38:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id DEF9F6B0006
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:31 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7742C52A3
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:31 +0000 (UTC)
X-FDA: 75938469222.08.can40_4a5e5de0fc04d
X-HE-Tag: can40_4a5e5de0fc04d
X-Filterd-Recvd-Size: 3495
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:30 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id c17so10691838pgg.4
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=cRhIay7rP7qO7uPvAr8A+Remo+kZoigIWCA9uWQOOak=;
        b=AgydtWNmsm41EGzhfgHuXUQ2ogbP+pCCgNfSFc8BIUGd0TaaRzK+OiSf/lwqT26raw
         Od+y6fdGIORn1N6Jdj5+Tx43HrRH/X2CpQXzgrc/KoLDyzcOMTjjFiTRsCS0KE3WvCrd
         EmBBQfWiYVfX0y0L7Xim5ZozYink7dijZYfoZTYFwXhWQKEIrxsVxIo9yN06ll/9ghsW
         yYGTSGxiDXN9WZ0Vj0zi9xIr7ZQSvz35GPofw+9HEtkasqEPP6hY6ryGYYDVAwqdn9p2
         yOwbcJRrH21to4y6vVPDln+dj4nS4yaXRyuSkRBJl8Mx+3350DVb9k5Nw0B8cZsrqh7y
         vBcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=cRhIay7rP7qO7uPvAr8A+Remo+kZoigIWCA9uWQOOak=;
        b=sz5NAhEA5GaejfN8iJJZBB9GBq1ii4BWAbAOz9NaArJzvsAUyBKCMnL+8zYB2nGoFN
         ZMMgW1yZqTHenYT9z0z1bQNLyX49y+rplZW2tT2ZcviocZe1Z6ke4bGh4ClxKmdfHQaH
         epx10ZQzjCwRy6ELUjuR3tQ6fBak2cn7ejlDfhpXF1UaTeBk5mxk6l1qO8qFdyI892S0
         BL+fz6zJBNdFmfyRDtmfwsZIg11m6cjnURtAYbw/hirmGvjMhtoRZAK/dXKqC45RLKtM
         sg+KCaWSMsWfCghtV2YmCq+t70VqRPciX0NMIo//uvJZNOC26idop4pVVsyeCDZMrP1l
         8jXg==
X-Gm-Message-State: APjAAAXx1ukL/ktBXZpvzj0csHE0BblVvGLUtf+FSCAxALeS5404pQkl
	rSX/iFhw8fBPktYfk74au/0WPw==
X-Google-Smtp-Source: APXvYqyhk4vV0f8Hg+AblRQKkdAxS/MnFT2usSrdn79SVyT7mHX1k295fod+5wbpEtY2yDvjcYu46Q==
X-Received: by 2002:a62:7710:: with SMTP id s16mr48666467pfc.139.1568583509899;
        Sun, 15 Sep 2019 14:38:29 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 7sm24804360pfi.91.2019.09.15.14.38.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:29 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 2/7] mm, slab: Remove unused kmalloc_size()
In-Reply-To: <20190915170809.10702-3-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151414050.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-3-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000216, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> The size of kmalloc can be obtained from kmalloc_info[],
> so remove kmalloc_size() that will not be used anymore.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Roman Gushchin <guro@fb.com>

Acked-by: David Rientjes <rientjes@google.com>

