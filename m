Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB08FC46470
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2B2B208CB
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ML6xZxh0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2B2B208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 391466B026B; Wed, 29 May 2019 03:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 344256B026C; Wed, 29 May 2019 03:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20B8B6B026D; Wed, 29 May 2019 03:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC6736B026B
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:24:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e69so1115895pgc.7
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xpHPXBq8KvHvbVOvl8VVx4rTQEIBc+yRDEo5R/DXTDM=;
        b=O4S7pZdAwznu7d19IkZFMWieX2AUuhvHCDwrY72wsB8e//rCfFMY0YzfYgtHjoRzml
         5tzvkddAN501iinozX7JSzcOB7QLSzlI9TJkealtRvrXus6CwfgApwpab8WfKQ8NyvbD
         6bP4mdRQleEVrvxh0I2XO4Hp6QvVnypckZ1oqgJfrLhoZ7ABKVic7guqqasD6659EKJC
         n+wG9RZmPaaC2DQdCiswFo3yn5xLmKibmU7yCX6Jp6nS7m0tORRFmjdElyA4EJkNexR+
         1aFcBXHK0ODLvKd68c0sppt3134oaVAOWs9EPydwvQ52tKGD2XTUe1RU4j87nSOJmfiR
         trZg==
X-Gm-Message-State: APjAAAXdRKs1xiDz5/Mkyxjem/KCXK1HcxCKKuTkf2Z5O7Schfwuht/j
	MOUXXAFKiZIrfyXtta+ubiGINwki4Qcw0YlGMYVF3RYgHB2BGgIqyiQcpvRdT2gJ8tDWuf3yHJB
	T1eULqvJTmSGhSAY6jzNXI05TbXzDNGYh9RvzpnOvrrKAQiKJtNfuBcd/CVkFpzNm2A==
X-Received: by 2002:a63:1316:: with SMTP id i22mr138921785pgl.274.1559114670489;
        Wed, 29 May 2019 00:24:30 -0700 (PDT)
X-Received: by 2002:a63:1316:: with SMTP id i22mr138921758pgl.274.1559114669855;
        Wed, 29 May 2019 00:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559114669; cv=none;
        d=google.com; s=arc-20160816;
        b=cwlB7OFJUT7Yp3g/vDetgj/DmehgdFFHbUvlI+l/PArGWOBSdexKs3Nz55+dMnXFqw
         5oNDaFyfLJkhw4GF0LU6sMX+DmTCFJzTX5K8s64ujgzUbEv4hEJibXv/5LdJrklhVvta
         QQYcXqpxQ6s+EMbGIyEC+ZNX+ahsMqiyZXGHQjOXLx1GnbvkwpiRPYl77OoLMT+wOgDE
         7vbTkvDEvGVa41PRomHN0P5L0nlwubklQQgLLLgHbhn9xFzEVLCe2P8o1WUmPQCmm8WN
         PCuU/zz1LI3XSEf9HhkQMvpzo50Vc6lgq/69wDJjKTWGMB4bHpiGhhJQLPxIJ5vnmBBw
         6pxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xpHPXBq8KvHvbVOvl8VVx4rTQEIBc+yRDEo5R/DXTDM=;
        b=xytp7WhRWMI+KlKl6OhzfRWZgrRqM5eaRoxUlnzYexmUuJStpyBHxU/Aj1vG7OYTfh
         bESjosnQQmLeqHVEoMmZSHMFny/8Tlg/hwUpZNy0L4hGQvxby6qkwIzC0hkAdbIGTz0R
         RgqCoDoDMCKUmvOlcEmS6W49JmcK6JygdMurH98pecxCHPkoZVgy8cAnNiN4cTqZmdqy
         kETx+dYpcl9WEU+SkcU6H1XOlc4320CZGRWblVwMhzxrUKeGsAv1EUKX5RxudOTjOspg
         fzRSmIFau6hgpPtLHTy+TfkQlF+N+xRWYoTpLipY6CzZkl4ZWQNTna9vNriKvd+jI9CV
         BinA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ML6xZxh0;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor5841639pjb.19.2019.05.29.00.24.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 00:24:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ML6xZxh0;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xpHPXBq8KvHvbVOvl8VVx4rTQEIBc+yRDEo5R/DXTDM=;
        b=ML6xZxh0hJe90j/v3mWzzYkO2KOVBfDxOp7EOrttZpaxNgo4v+jkI3jRGxPjOxUYsz
         k4iwHnLNKvBlXesx1X/1jJY006WLsz3g+q47Fld6/v+0QSazSDC5D1/my1y5oxIy9UjG
         nCJ3dtpF+62FL6onG4KgZa/e+vQU8Bu1MZXxqUg6X2rLeKY5D8E8mDqKzjua+yFsVEi+
         ohpMrYnsqr5+HTSyR3+ESLIcZUgtcDqWRPTut2AFJmoO/x88CKkBBfGzldCg+zibW2Kw
         po7tc87f+I9Mp2oOBaTx8WyH7K91cz1Wk8vl4V9UdwTmdylc6FuvDYKfnWUWbPSmBkdU
         AI9A==
X-Google-Smtp-Source: APXvYqxuvCTK3y2JN1wKkhCPAxhMoMaWb9H7F3jZFEtwkZAkDx2qQHpZo7gG1LJtGH2wZ33pY/T12A==
X-Received: by 2002:a17:90a:9b8b:: with SMTP id g11mr10095555pjp.103.1559114669495;
        Wed, 29 May 2019 00:24:29 -0700 (PDT)
Received: from localhost ([110.70.55.225])
        by smtp.gmail.com with ESMTPSA id l8sm5093517pgb.76.2019.05.29.00.24.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 00:24:28 -0700 (PDT)
Date: Wed, 29 May 2019 16:24:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Hui Zhu <teawaterz@linux.alibaba.com>
Cc: minchan@kernel.org, ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [UPSTREAM KERNEL] mm/zsmalloc.c: Add module parameter
 malloc_force_movable
Message-ID: <20190529072424.GA29276@jagdpanzerIV>
References: <20190529012230.89042-1-teawaterz@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529012230.89042-1-teawaterz@linux.alibaba.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (05/29/19 09:22), Hui Zhu wrote:
> When it enabled:
> ~# echo 1 > /sys/module/zsmalloc/parameters/malloc_force_movable
> ~# echo lz4 > /sys/module/zswap/parameters/compressor
> ~# echo zsmalloc > /sys/module/zswap/parameters/zpool
> ~# echo 1 > /sys/module/zswap/parameters/enabled
> ~# swapon /swapfile

[..]

>   * We assign a page to ZS_ALMOST_EMPTY fullness group when:
>   *	n <= N / f, where
> @@ -1479,6 +1486,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t gfp)
>  	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
>  		return 0;
>  
> +	if (zs_malloc_force_movable)
> +		gfp |= __GFP_HIGHMEM | __GFP_MOVABLE;
> +
>  	handle = cache_alloc_handle(pool, gfp);
>  	if (!handle)
>  		return 0;

It's zsmalloc user's responsibility to pass appropriate GFP mask
to zs_malloc().

Take a loot at ZRAM, for instance,

	                handle = zs_malloc(zram->mem_pool, comp_len,
                                __GFP_KSWAPD_RECLAIM |
                                __GFP_NOWARN |
                                __GFP_HIGHMEM |
                                __GFP_MOVABLE);

zsmalloc should not change GFP. If zswap, for some reason,
doesn't pass __GFP_MOVABLE, then I'd suggest to patch zswap.

	-ss

