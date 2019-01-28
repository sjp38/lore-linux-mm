Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DE69C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34A8C214DA
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:10:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34A8C214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB0BB8E0007; Mon, 28 Jan 2019 15:10:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C61C48E0001; Mon, 28 Jan 2019 15:10:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B76DE8E0007; Mon, 28 Jan 2019 15:10:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 769F18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:10:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b24so12510781pls.11
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:10:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CecL8b+tKskywcifeIVmF8MMnmie8dzPPpaXoA75yJA=;
        b=qaaDzyjDS8/3oqxCJ0mTf+0lyqKssOCmASgLgeua7LCeFnOl+ZknXGcbVQudqme2Gn
         5DqZgxGM9CYOHjidQFs+9xsGx5olmV6/M/yLDzTTh2ieBZYKvT5xnpl7fJufbwq+SG0T
         SOv0y2VNbP/LShoeeVfWwBNBv6fCr/mdSTMtFtREVh3fhnGMLJhx5eYkpp6aNy1zeQ4H
         RmWw6IwY3OnzqAUkQVMjAmrBeinutR9wTyiyuTHVKWFlVbM/N0YFauNNOvSBzZLAFngU
         ZIm9g+1YOKnx/donp6P/RZg0yAKK/UN/ZvWXeGgjzyLCvNG+NNk2DuMImiOkp+t71PX6
         ZZ4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukedBFCViX1jHKYjEEpoWztlMvRCpH9ZhEK+aYb0XP7COQMryhzX
	e1OqTVb510geytRWJ2Q7tGZPA2dNzCh14eZfLWF7ZO976erF2WysOuZlIEr+A7MYOEPRvuGM9J9
	TOLwqY1yJcApbNZcyUvumY+aFsk1umm8CBs3GNT5nzK7McdnnS2cdPJCZpri9ScVmeg==
X-Received: by 2002:a62:9305:: with SMTP id b5mr2769717pfe.10.1548706231149;
        Mon, 28 Jan 2019 12:10:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2Pp66T4ZfYO0zYCFkruB2MakUP25ZATzeJ2ZZyByRfdD57TgQfWJ+wcd7NQzOKimVaG1o
X-Received: by 2002:a62:9305:: with SMTP id b5mr2769682pfe.10.1548706230496;
        Mon, 28 Jan 2019 12:10:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548706230; cv=none;
        d=google.com; s=arc-20160816;
        b=c/dyw+LdZoaQ+8bbn1hI5QTq+G2ybpYJe2lR2cfXObrLpFOxjWxHcB2zVPG8YWvvy3
         vH2x5h8zbWg2omdkhSPvLOv0KbsLjVa5MaqZxsBG5TAMjh5ZX/8FNZpLOmmdr5lHbYRB
         9HKXaWuklGHkaCxwASRzLANYkv8cF8EtLcGVbfdMtkXFqj5qVPrZE3Jm+vC9YCmxKhYT
         Vlh11atSSt+6mr1fuUg/BILkY2OVVoqfSCozAmRN0qMBObux+fPl5DtizrO70fJCthX8
         aNfMYt69Y3jTrb/eUGpqtJm64q+fRzNAP+2E8aqKagTf0XPBJWJZgicrMA+lJk46kBwn
         q1yQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=CecL8b+tKskywcifeIVmF8MMnmie8dzPPpaXoA75yJA=;
        b=SBIH7anIMTQq+TgwcMNpOTEy4VZNIqD84QVxFEwJdEPremNZyVPahwBcV3S+mpjf6A
         SXbErCvgi+bmueqZdwM5ZFh2f8BcxlQizpJg5V//GUV797Z1nASGuHOfTBwxoV+x0N3s
         gpwt2nu1/CWr8gp+C7NQjzRNbTvZ0qziIu6FzHdR42XjoaFKWJux56jSKYHNRWTGfLIP
         4s89ZdLHr52AW3aKueVhjcwTvak2zyvJ+n+jYIdprfEllZ/E/xgjOsvShJPJ5ncZ5Xki
         JyijXNzplHUUQDC99xwaZGn7Xca7cCpQVO28338+7OdE0oBpbUSPHCB3SkYNCnnIelmW
         LFnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u131si2633861pgb.594.2019.01.28.12.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:10:30 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E475623FA;
	Mon, 28 Jan 2019 20:10:29 +0000 (UTC)
Date: Mon, 28 Jan 2019 12:10:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <clm@fb.com>, Roman
 Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
Message-Id: <20190128121028.8ef4c19dd3fd1d60d2e3284c@linux-foundation.org>
In-Reply-To: <8ddf2ea674711f373062f4e056dd14fb81c5a2fe.camel@surriel.com>
References: <20190128143535.7767c397@imladris.surriel.com>
	<20190128115424.df3f4647023e9e43e75afe67@linux-foundation.org>
	<8ddf2ea674711f373062f4e056dd14fb81c5a2fe.camel@surriel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 15:03:28 -0500 Rik van Riel <riel@surriel.com> wrote:

> On Mon, 2019-01-28 at 11:54 -0800, Andrew Morton wrote:
> > On Mon, 28 Jan 2019 14:35:35 -0500 Rik van Riel <riel@surriel.com>
> > wrote:
> > 
> > >  	/*
> > >  	 * Make sure we apply some minimal pressure on default priority
> > > -	 * even on small cgroups. Stale objects are not only consuming
> > > memory
> > > +	 * even on small cgroups, by accumulating pressure across
> > > multiple
> > > +	 * slab shrinker runs. Stale objects are not only consuming
> > > memory
> > >  	 * by themselves, but can also hold a reference to a dying
> > > cgroup,
> > >  	 * preventing it from being reclaimed. A dying cgroup with all
> > >  	 * corresponding structures like per-cpu stats and kmem caches
> > >  	 * can be really big, so it may lead to a significant waste of
> > > memory.
> > >  	 */
> > > -	delta = max_t(unsigned long long, delta, min(freeable,
> > > batch_size));
> > > +	if (!delta) {
> > > +		shrinker->small_scan += freeable;
> > > +
> > > +		delta = shrinker->small_scan >> priority;
> > > +		shrinker->small_scan -= delta << priority;
> > > +
> > > +		delta *= 4;
> > > +		do_div(delta, shrinker->seeks);
> > 
> > What prevents shrinker->small_scan from over- or underflowing over
> > time?
> 
> We only go into this code path if
> delta >> DEF_PRIORITY is zero.
> 
> That is, freeable is smaller than 4096.
> 

I'm still not understanding.  If `freeable' always has a value of (say)
1, we'll eventually overflow shrinker->small_scan?  Or at least, it's
unobvious why this cannot happen.

