Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9C2BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:01:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A41C20868
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:01:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="zrmfr+7X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A41C20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B6FB8E0003; Fri,  8 Mar 2019 11:01:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 040A78E0002; Fri,  8 Mar 2019 11:01:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6FEA8E0003; Fri,  8 Mar 2019 11:01:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9B708E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 11:01:55 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id c9so18859984qte.11
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 08:01:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7Mrnt0v5aTwQKX4K+a22sLlI7mhOrdlmXcat3QdWb0c=;
        b=FxTTYKzeb/prSA3xGbDT2BO+YWxBjoY6oOTDyN5CywdyT71oPvu7Q9PTyCNRCAdlVc
         OPDGKFdf1eQDahfD7odVyj4ftsR7oJF3nOvAgJEw+7BipP3JNEOkp9S0HKrpCzWwLITW
         XNru2aK1p5xmVeegI72YmLyc4JfWcfLR7Ei6HAtTTI/3tyiNz3SsQ37t/soiBE+UGkDF
         MGtdsxA0V05uE5dxEpVmMMri1W4MfZQ8yTHgA8UFcxnqW8+6ZS6q4g6JUAcjLq6N8Wqw
         M/INzHof4EbgRjpzMZQGMozu1YpNRtoTeU7MbaEE8GJLJBn42H1MQaueRvm/VopKa1lw
         0UQg==
X-Gm-Message-State: APjAAAWTdg7IAtKPiE6UnQ87/5+G+VjpNSEIrPIVdCraZ80nkFQgNfNv
	+y4ctXjMgsQJFp0WB0qQtTTl7SV89j9AN8lDmJL25020fZovhtYcIPr1ig5btAMZp3hWKrDTrMi
	R0W9Rc9T+mXZOfqcP5wDwhZMtgxPecdV/mKZ6iD1paV4wAQqb4Fan+Tv5mWl3tiHs7TNw1ekGrr
	Nu2o3u4he9LkAhkPOVlOzxKVttzYdg/kXXzOcass3yK4n6ZtxYOiz/ZIvU8XLlRfxiBvdkJo5La
	9Y8QLdDBYpljU0+XlOPIWcCrFs6KfpksyaciJKnUVld1TU0jqRcyySRcG/HN7LUNSWvyOB9zO83
	U0C0d8sobn1il4hvHEgQmJflm8dwvBaYfhEAjOrmoytGy7nA4ED1ocUglc9EIqlKkglzEN6K93S
	Q
X-Received: by 2002:a0c:8b63:: with SMTP id d35mr15489872qvc.148.1552060915388;
        Fri, 08 Mar 2019 08:01:55 -0800 (PST)
X-Received: by 2002:a0c:8b63:: with SMTP id d35mr15489787qvc.148.1552060914449;
        Fri, 08 Mar 2019 08:01:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552060914; cv=none;
        d=google.com; s=arc-20160816;
        b=Cc15gMgwQjZAnaRW1ykU0rooCdhABDU2wgyO5oSFrP+J5+IKx3sfnSXuldu4xfPFbc
         P5aXYXg674FoX8kG3LTRK8TqKBwYPx6r6mKkdJP6DfSC8GAVLIA4JSOMTj6bB697lQSj
         /M+kiiwzCdWzZb9V8JFf2wC0G/B2ZAqvHubUDZiCcvH4MMouLCRoR25PN627TQgx9gjz
         Hqaqo2xSONQqC6zRTkieVdYtSzoAhLA3QlB12qyvg8HESmsGDv2bX+28HsS5PuNL+h2R
         qwhxh/+rKR7wEgHQ2EI5ZRTVU4phA+Oz9sUUluumsnHjr9DfRuhmXvLJcDUOPqalLMwl
         ksdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7Mrnt0v5aTwQKX4K+a22sLlI7mhOrdlmXcat3QdWb0c=;
        b=zOJwvzc2QpuuteYENFfscsjJFuSYmWCdLXbmieWQi5ShEEmsKCUQTAiA7YbwjzmGF2
         aUGPU+5hM50TlflJVdq1EdBuYJttszpVWR2opUyPERCiYHUuct2aBgXdbsrE4QwmPzQT
         CSk2Py9fxP7zTmGsifd5et8coFBH8rUew/0pRLAjphM5UWKQDUsZPz4ns1abc13YR6d3
         V0bgzv7GTTNeX4XRS2dCdXLxhAxG6S4hovFCImFV6Phf2qb9Ez2uhQcSDLqG5qtnDHGl
         Ue+0XLh86sPPg6b5P6K8m//qlMSpaCGUDdsFUcd8hgez/NKiPBIHd2FFvm2dmixgboVx
         XYFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=zrmfr+7X;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor1584098ywm.49.2019.03.08.08.01.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 08:01:54 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=zrmfr+7X;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7Mrnt0v5aTwQKX4K+a22sLlI7mhOrdlmXcat3QdWb0c=;
        b=zrmfr+7XYf//JgH/JmL+nDOiY0Sn4Cn0/tQ6vGXOCsbi5D0ocV11dHDDQm4Brp4j48
         S9A5J6ijrUgsJdPMKZKFojQr2KUKKskPD7i3+dLAiGc54OcWWxcYLzEbdwletNluQOHL
         o3pAGw2BAogHLKZxBl0vS2CQr9jm/IJ9pw6p/UUN1pqx0Q80oo3qCnSmslx0o+dXFL61
         ENnC3P/EsdxY30F8N1PzTIZRyWNg3ReytprClO2X02QbqbRU3AEZFI3EXsTPxXF0GtuY
         lZQ9qZ2qjexeS1iLkhfHNPx2BMTq8qwcUc3PqDe3l5evwK4WKd8WFyX5xJmnxhTQKMly
         GTUg==
X-Google-Smtp-Source: APXvYqzbRZ5z4rBPAYJpioypz0Qfq6hwxf1QV1sbef612TXie7Xx3GmmEU8nebWZS5r6iWB0vXbNmA==
X-Received: by 2002:a0d:e612:: with SMTP id p18mr14576212ywe.445.1552060913522;
        Fri, 08 Mar 2019 08:01:53 -0800 (PST)
Received: from cisco ([2601:282:901:dd7b:316c:2a55:1ab5:9f1c])
        by smtp.gmail.com with ESMTPSA id g82sm3210342ywg.60.2019.03.08.08.01.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 08:01:52 -0800 (PST)
Date: Fri, 8 Mar 2019 09:01:51 -0700
From: Tycho Andersen <tycho@tycho.ws>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 07/15] slub: Add defrag_used_ratio field and sysfs support
Message-ID: <20190308160151.GC373@cisco>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-8-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308041426.16654-8-tobin@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:14:18PM +1100, Tobin C. Harding wrote:
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3642,6 +3642,7 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
>  
>  	set_cpu_partial(s);
>  
> +	s->defrag_used_ratio = 30;
>  #ifdef CONFIG_NUMA
>  	s->remote_node_defrag_ratio = 1000;
>  #endif
> @@ -5261,6 +5262,28 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
>  }
>  SLAB_ATTR_RO(destroy_by_rcu);
>  
> +static ssize_t defrag_used_ratio_show(struct kmem_cache *s, char *buf)
> +{
> +	return sprintf(buf, "%d\n", s->defrag_used_ratio);
> +}
> +
> +static ssize_t defrag_used_ratio_store(struct kmem_cache *s,
> +				       const char *buf, size_t length)
> +{
> +	unsigned long ratio;
> +	int err;
> +
> +	err = kstrtoul(buf, 10, &ratio);
> +	if (err)
> +		return err;
> +
> +	if (ratio <= 100)
> +		s->defrag_used_ratio = ratio;
    else
        return -EINVAL;

maybe?

Tycho

