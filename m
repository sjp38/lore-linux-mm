Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9D8C282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D04F21738
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:31:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ZEOZkIB1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D04F21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D38288E0003; Mon, 28 Jan 2019 16:31:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE458E0001; Mon, 28 Jan 2019 16:31:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B608D8E0003; Mon, 28 Jan 2019 16:31:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80FCA8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:31:23 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id t205so10297315ywa.10
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:31:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YAmmgKNRrQc5gbyA9vCwhi1X0/D3dSvcMoWevldO61g=;
        b=CUN5yK5MBQWRx1aLYytaCFYxJba1HssA53NnINefBv9ZYIpSxUgylO0m7PyrA1ARof
         OGCdNe6gHCxeFXQqBDeKS9j7GJnHxTvvtaEYnP+x8nhz8l4edIGyqpfTMSiiU+RaRlB2
         LdojopfGhWJthYyEqT2AkxDC3Wih4wggFXBaeGe8QlX13Ab8JiQpW4QIJFXHb5OaVU/u
         1q7EPlU/4GVk0GCqjN9m+ZpSmfylTRkR35UzxUntxLX8El3wy2sqE9oDR7EQ3ahmgdiW
         8i2L9qsxun83LrIjeRtnpuHylBqytGj5LDwyExXkMUEg6lnByQhZGLHyJqiG3R1MWjhA
         nsvA==
X-Gm-Message-State: AJcUukflkst/b4DKfImMGgMni8lLKDN0+fvCZf9P81e601IQRB/vifhZ
	q9dHNdrLrLel2qJhcDihAT4TcXNi6BZKzJ/OdnIG8+0KLPMjkxKV0mHEyqhSziScCcfeXmVbMQ0
	EXdrrSRiSdqCFTHJnN4EtqtZCoExlmfCE/hAWY5KzkXr9zyswqTxtMaO2Ae/7aUHaf6nyP6I014
	JDTSC+hwbbu2dUa5cHGZu5nLvJIgsWz0jj47yqa+lBialgRexCqdfajkU2UAv/tOzNsB/WI8BGA
	E7eQRWzeWNtpgaR0A3n5Wj8DYaViKOzTvi6akryqwc51qJXnY9ZGcjMpYXkygaOmStF8cF4nAOJ
	Ydd2GqwME5hqOD+c8CY5akH0kCZfDX+ukz1snT3g0wES8oscZjGUtzsg9CSzUP9wDoydLhMMd34
	0
X-Received: by 2002:a81:6c90:: with SMTP id h138mr22196226ywc.379.1548711083242;
        Mon, 28 Jan 2019 13:31:23 -0800 (PST)
X-Received: by 2002:a81:6c90:: with SMTP id h138mr22196186ywc.379.1548711082550;
        Mon, 28 Jan 2019 13:31:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548711082; cv=none;
        d=google.com; s=arc-20160816;
        b=X2+teJHDKmYEzMYTNLILM17e8WTkkDzfvrBo6zmXrPeBdMrMdVZY+tQpv8fN8nDg7k
         eH7BmOGIAdXSIjsrmjgM+X0MyTNMrWGrUF22QFp37FFWhZpxSNAqLQ7ZU7V+OsmBTBbt
         N0+9k1EtFRuCTS0U1NHbWE8fZPJ0XMOdj1ObQn/pCWzmf9vyqwL1dAaTKFkggw3voK5f
         /UjxGg20B2YD9AJa7MwTZmIHTRjNb6EmzBNMZj86PP6ilSjgJCE/b50wWdVAsrALoBjc
         SiQSRh7mem3vjeGlGgff8US9K3jtSf1l8RqJfoF2vD2mJpgjkWzdMBJjxs8sRNYXYHbt
         2eKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YAmmgKNRrQc5gbyA9vCwhi1X0/D3dSvcMoWevldO61g=;
        b=vQL+xVBAZEB+JhVSwe8HpqPSgr4e3/guOaJpECC40AVo/PVI7CMgFtmfYicfxbntlx
         yhimFYYG3PuC+u0wFA3EZNA7jW1WH/7NdcbrFqMsehBU/OWRj+h1y0JyFXXOFMkCCbF9
         UCpeZE87qIyNz63fkMS7TwGkbD4PmR23ESUvRJqVkPiJt6012PDCoH8of7+dLhX6fBIF
         8kxFvnsgC690g460zSJ4uW4riqOGiwrtM29IjpL3/2VxrLMqA5JCldodVE5jJF3aO+/4
         eSUSBrJnvLTj+zTpixsuO0Ss1k6X8quaIHEDaTCBXZKcVr10ynDIe8PJMtWq+NR1T2rG
         IAZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZEOZkIB1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b75sor4479034ywa.115.2019.01.28.13.31.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:31:20 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZEOZkIB1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YAmmgKNRrQc5gbyA9vCwhi1X0/D3dSvcMoWevldO61g=;
        b=ZEOZkIB1dewlaD5Y88LebQn5HMgZEDeuALlgAC8pDnS/sfQZ8K6q8lkY836iFp/Kdw
         1It/VXY71UBzl1Bq7uh1IQfoJmSOqpgULvqmJE3ZspNPl8BPV5sjb83Xb/fC2Mzd/yhA
         Eu6LIMbmYraCkmEsuq7xjdLo/MM+VJPVxA/A9rZgYLOlqGTs+CVaHhBvXqOFUBWs2gES
         +xKhaDOu2ZiqRD85iIYTWm8h0IpSudZoXEA+qxmeXddUu0fljZFnNNJvAJjk2cFervnN
         dFRepVyf/R1qL4CFhy5JHnciEQw4kJrZvH+kb5VjmytlAglZ+q8KE0yqeQQh/uZ4s8Tv
         og1g==
X-Google-Smtp-Source: ALg8bN7r2Al7asGW6bKrsfih1TF2sfeDStiKF6KOaXlnpYSIXwhcAGaYJxIlng3sTi0ucBCqmjkmxQ==
X-Received: by 2002:a81:11d5:: with SMTP id 204mr22836937ywr.287.1548711079931;
        Mon, 28 Jan 2019 13:31:19 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:42c8])
        by smtp.gmail.com with ESMTPSA id p3sm12266647ywc.14.2019.01.28.13.31.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 13:31:19 -0800 (PST)
Date: Mon, 28 Jan 2019 16:31:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	Chris Mason <clm@fb.com>, Roman Gushchin <guro@fb.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
Message-ID: <20190128213118.GE1416@cmpxchg.org>
References: <20190128143535.7767c397@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128143535.7767c397@imladris.surriel.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 02:35:35PM -0500, Rik van Riel wrote:
> There are a few issues with the way the number of slab objects to
> scan is calculated in do_shrink_slab.  First, for zero-seek slabs,
> we could leave the last object around forever. That could result
> in pinning a dying cgroup into memory, instead of reclaiming it.
> The fix for that is trivial.
> 
> Secondly, small slabs receive much more pressure, relative to their
> size, than larger slabs, due to "rounding up" the minimum number of
> scanned objects to batch_size.
> 
> We can keep the pressure on all slabs equal relative to their size
> by accumulating the scan pressure on small slabs over time, resulting
> in sometimes scanning an object, instead of always scanning several.
> 
> This results in lower system CPU use, and a lower major fault rate,
> as actively used entries from smaller caches get reclaimed less
> aggressively, and need to be reloaded/recreated less often.
> 
> Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
> Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of objects")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Chris Mason <clm@fb.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: kernel-team@fb.com
> Tested-by: Chris Mason <clm@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

