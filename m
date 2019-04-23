Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEA3CC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A72020685
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:44:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WJp4EToc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A72020685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07BEA6B0003; Tue, 23 Apr 2019 04:44:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 004E76B0006; Tue, 23 Apr 2019 04:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E806B0007; Tue, 23 Apr 2019 04:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF0606B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:44:52 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id b16so12538249iot.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uAxn3VVyRKikiswAJvxQH1wVrtz0xNI5a8VqqF5heXY=;
        b=FU7g5QJGsLLh2YR0VzaycrGMe4cELQnVPefr67WYfmTEqmEEAccE8yfvwfeifDhyB4
         M2b8V+yig77WRz6LFRRKvy1rxpzoTv6uyn68L2V9R1M/wD22lkbIoqAK2TRlZvcTPD0n
         Klj7qbhUbcIxTe03/ZZdMm8ID3hjjmb15VID1wCCqZX+7614GLaAoTgO1cszYV0udeFq
         NVcymTgZpSFsu++BqNphW6Hp0x2439veYZTzZg46plZZ7UlGeXNHfy1R9USgaOg2EzMz
         YBzbTI3TzkbJ2Vwz717uNUNryQlInPHRuD37bSYNaWQYpxLUze42XzQ9+lhLJHiAA/0O
         rIlg==
X-Gm-Message-State: APjAAAVaPabr/RnTGMqnJpG/9ntzBHUL1D1BxTMojaqkLVCItX9CY4kW
	50+qJdbN+M5R7nFHYeetiof+Qq0B2HNPdM8mQerBwGU0eOVnPHssxBttQ+wrw5nHDZS6iB9TVQP
	8bj1nLj15B4YeKo8fuRu7xHI1ercW3DTTQrTqvfuAhd1fZ5GQ4ot+mbFVIAs4D93szQ==
X-Received: by 2002:a5d:8597:: with SMTP id f23mr15498832ioj.148.1556009092558;
        Tue, 23 Apr 2019 01:44:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3nnczFO5Eyz54JQZhEPZaBgyGmbxlzT4dVzEQ6JnEFDvjjyPKCB6EwHZy655ekcd4m0Cl
X-Received: by 2002:a5d:8597:: with SMTP id f23mr15498812ioj.148.1556009091895;
        Tue, 23 Apr 2019 01:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556009091; cv=none;
        d=google.com; s=arc-20160816;
        b=nNGtl11juGSzBtP38YSyQ3snibQVB31pL6sI9cmqMmLG7a9kDSVueHw7ZuIP+2G8yp
         eQrrcsUViOfhqrIy8raglOmQnYAFAMzCKHu6UW40+nq9DAotn4kIaSNbOmUpO5UgVXeW
         cRjkee1H5ebJhwkGeuvO51cB8E17zPb3HUMquHeUObnDNnSlmkHN26BcnQ/QVQ8wjKWI
         Q8oPOMkDGFSwjf7hpxbLyM3X2af95ifZ/V5adXjiy+qCB+fxFtSqc5/fkPowj8NCo1+L
         95S8jXuCdD90j3pHYnLPZUWZb2iUPR1+xKK7DvLW0il0P+RCF9G+BFIzd9UrAFk6riQP
         yOeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=uAxn3VVyRKikiswAJvxQH1wVrtz0xNI5a8VqqF5heXY=;
        b=dqGsG3sxuuINf5rxZi9ENm8IxDc2dvqLiLFsfrbYuPz8/6fnZwawaM2VUoh6po96Zs
         woL008jO4Ax1Ljyjjek04CDwPOQvvHXZ6CVMKA5h6i9JWLkNmXANEbV6fjhlvlpw6N8z
         PUO0oZZ/J5ZcgKQeTdJsLgKxJwDtHGLqlrW9QpAbp67TLFlikYWQbF5EHd3zJCu3QPfy
         otC2GnHcOYbMDNkGOQL6MBlBFhvKKIGTXn7uojgg5rSz5YwisqVtyRysWng3c/UjbxRH
         /Qab6trpozsNSDEvg8S2ru7wpJpv7epsONOcol445jc5dPcBG/hkGu/wA7YhoVDLIni8
         j2lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=WJp4EToc;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 15si9829133ity.77.2019.04.23.01.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:44:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=WJp4EToc;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uAxn3VVyRKikiswAJvxQH1wVrtz0xNI5a8VqqF5heXY=; b=WJp4ETocMlz7U+l2fuVy1dHNLi
	Cghs8JjIVAP8D5vrS+XN00r39FmEx1x3GS1b2zvbTdQQmdrV5ud4qB/sYhZ6HatUcX4vkXjPGvEiV
	QpmVrX3hYNGl9Ju/XGiuCAsKNgcMpJWKrwmn1KZacXdT2NDopgd7sYr81DvoYOYr1alN9tRW7eeUP
	Yrpf6CCsW+jHicS+42VLlwE7jltSE30bPNSqa0fPDgwUQV+PWRgVWlUyAbcqurGzMIU5TLRUUId8S
	/p5IfpLm0hoW+3LQr700/cxtpJgLqhflkyXFUDnZQ2Tkh9d4IzuMIx7GLKVAykSMjDerCL5Ugfc4h
	oIvAsw7w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIr2k-0001DH-2O; Tue, 23 Apr 2019 08:44:46 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id CE85329B47DC7; Tue, 23 Apr 2019 10:44:44 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:44:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
Message-ID: <20190423084444.GB11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
> +#ifdef CONFIG_NUMA_BALANCING
> +
> +enum memcg_numa_locality_interval {
> +	PERCENT_0_9,
> +	PERCENT_10_19,
> +	PERCENT_20_29,
> +	PERCENT_30_39,
> +	PERCENT_40_49,
> +	PERCENT_50_59,
> +	PERCENT_60_69,
> +	PERCENT_70_79,
> +	PERCENT_80_89,
> +	PERCENT_90_100,
> +	NR_NL_INTERVAL,
> +};
> +
> +struct memcg_stat_numa {
> +	u64 locality[NR_NL_INTERVAL];
> +};

If you make that 8 it fits a single cacheline. Do you really need the
additional resolution? If so, then 16 would be the next logical amount
of buckets. 10 otoh makes no sense what so ever.

