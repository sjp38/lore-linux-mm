Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 469ECC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:03:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E61C52089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:03:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nYhQksXM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E61C52089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93D946B0003; Tue,  6 Aug 2019 19:03:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EE126B0006; Tue,  6 Aug 2019 19:03:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 804C56B0007; Tue,  6 Aug 2019 19:03:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB6F6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:03:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g18so49200819plj.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:03:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=leLWRkUUazZUO67Ed7EkKlsGBQxYR5WXDYntdJf9IoY=;
        b=kdSRkbFzXMaODCcaihoTrrCCyUkafQvWg486HMSI/4Ej6uLVujUyzmaF+P2rFwVvzx
         dJMwrCbyssyPX8N4PwvLYwOwF9dwKQ6BrslMu9X+H3nSZGCMNyZb0hiar/cM+l6iIP+8
         Kk3Jj+WoIVs8Cks3wu4vnIygIFn4ztq7YngjGQokdtJ/ZH2bItK/NNTBIX0f2jz1rb6F
         IGTXBUdkU86fJDqnFSPaBQJ38NlJRBEe82OlkuD1aoO0UC9DqhF0Ou9Y2QJLxYyoBCBS
         rZjape6Xw4Ccfsddp7QxUH6FlyzeD08M9ulJpRQZZqEtLA+6AWkLyOzUthZZ4ALiX0Sg
         Fm4g==
X-Gm-Message-State: APjAAAVNjuiF3uXVoqFElpXcD7vAlNYwbPXqlC5fZkyClCFpx2Fe146n
	ZaNs2hO4iynl7b9qgkNCTre/D4oTPwTJUgaJuLDE7Gq2GRyrt6iAx25oFxnZALDdmQKBWiWkx95
	wibxdb5Lx9m8hWg6wLkqRjg1CU9ts2yqlmY4jMpqBUj9YXS7D4V3tOeuINQr8Ttd5Zw==
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr5679853pjw.28.1565132588978;
        Tue, 06 Aug 2019 16:03:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFftU5U9Ocrril4CVAZFn2u+bbzc/tPDRGB00CFXWFza7sSGWnoVRPQMqc+dKxw64yHOh4
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr5679792pjw.28.1565132588186;
        Tue, 06 Aug 2019 16:03:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565132588; cv=none;
        d=google.com; s=arc-20160816;
        b=KS7TfAdlSrJwv49uENxTWXvbtwi1MWo3JLAhjqmGAoYVVI3ivkRKBb/eMjLsa1ht8V
         G2cx2AYPFY9Sxvkd6uehOYj1LA8Zimi0sGNEVuF0F7GwH28SZPvvc+LsywhK2qM9OE3o
         kD25qaS5wDxjMmWv9DCrfYA1GmwvukrvCTy2PiXEjIcrElNkUXqXtvL6JzTjfsG+CCLv
         vJeRl1DiTTrpVCrsK04v5aEqPKnaYNs7SRA9R+AWr4+/5YtJwPeeDCCe+BFRJ6iDJlzd
         Sk1eHEMCYJADZpAAymXTjyYQ/vj3VOWkE4r85wfA4p8CIzoi4QmlnHq7G387wp4OZUa1
         c3EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=leLWRkUUazZUO67Ed7EkKlsGBQxYR5WXDYntdJf9IoY=;
        b=j6UAas755/pIF8s4DcSefN0+o04Fc2j+2rUQCSVZXtzed8uQgoAB6lqMpes0SkflrY
         riOERVhc4xOYMi/kmpgl366xDpp0KuoONCi6xajKsKYLqnpw+qKBGB0y1zOXrCilu+6S
         7uevvaFtfNVHMeo5PhKhfGQsJCRvY7iCJEpbG1vX5aPzkUbDKUojgBwVQj0/MaOxcQSE
         +8DpX1f2g29cXPpJYItLqH4YgkwJxfM+wM3T8C7Km3TVVqoh/kA1+Ust5BXfd2SOracL
         foIgKRbeKPKLHeTHLpFEnWNvOEnjPMyeNGtnqraw+wRqNlGHtjaKUwiUWSHsuQiOsggi
         dfLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nYhQksXM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k43si16047591pje.59.2019.08.06.16.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 16:03:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nYhQksXM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3A33320717;
	Tue,  6 Aug 2019 23:03:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565132587;
	bh=qT4gAKs+8ApcJTe9M2dRBF2NOvklKVKeDkSelB5PNpE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=nYhQksXMjFdjn7qsubpevTF4BxP7xsit/IdT2SfJ3mrS0Rx7B0zEjLoFZc8NJZXxT
	 jiawPejTfcVjvKx3FcMC6k2JIomNwGOL5/r2KBhYy/ve+cJBFcRC62rjV6qGuOk6dC
	 UUV7Z7MUl5e1flsun/zvccyVkG5K2bYpuLV3Qae0=
Date: Tue, 6 Aug 2019 16:03:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
 vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 4/4] writeback, memcg: Implement foreign dirty flushing
Message-Id: <20190806160306.5330bd4fdddf357db4b7086c@linux-foundation.org>
In-Reply-To: <20190803140155.181190-5-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
	<20190803140155.181190-5-tj@kernel.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat,  3 Aug 2019 07:01:55 -0700 Tejun Heo <tj@kernel.org> wrote:

> There's an inherent mismatch between memcg and writeback.  The former
> trackes ownership per-page while the latter per-inode.  This was a
> deliberate design decision because honoring per-page ownership in the
> writeback path is complicated, may lead to higher CPU and IO overheads
> and deemed unnecessary given that write-sharing an inode across
> different cgroups isn't a common use-case.
> 
> Combined with inode majority-writer ownership switching, this works
> well enough in most cases but there are some pathological cases.  For
> example, let's say there are two cgroups A and B which keep writing to
> different but confined parts of the same inode.  B owns the inode and
> A's memory is limited far below B's.  A's dirty ratio can rise enough
> to trigger balance_dirty_pages() sleeps but B's can be low enough to
> avoid triggering background writeback.  A will be slowed down without
> a way to make writeback of the dirty pages happen.
> 
> This patch implements foreign dirty recording and foreign mechanism so
> that when a memcg encounters a condition as above it can trigger
> flushes on bdi_writebacks which can clean its pages.  Please see the
> comment on top of mem_cgroup_track_foreign_dirty_slowpath() for
> details.
> 
> ...
>
> +void mem_cgroup_track_foreign_dirty_slowpath(struct page *page,
> +					     struct bdi_writeback *wb)
> +{
> +	struct mem_cgroup *memcg = page->mem_cgroup;
> +	struct memcg_cgwb_frn *frn;
> +	u64 now = jiffies_64;
> +	u64 oldest_at = now;
> +	int oldest = -1;
> +	int i;
> +
> +	/*
> +	 * Pick the slot to use.  If there is already a slot for @wb, keep
> +	 * using it.  If not replace the oldest one which isn't being
> +	 * written out.
> +	 */
> +	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++) {
> +		frn = &memcg->cgwb_frn[i];
> +		if (frn->bdi_id == wb->bdi->id &&
> +		    frn->memcg_id == wb->memcg_css->id)
> +			break;
> +		if (frn->at < oldest_at && atomic_read(&frn->done.cnt) == 1) {
> +			oldest = i;
> +			oldest_at = frn->at;
> +		}
> +	}
> +
> +	if (i < MEMCG_CGWB_FRN_CNT) {
> +		unsigned long update_intv =
> +			min_t(unsigned long, HZ,
> +			      msecs_to_jiffies(dirty_expire_interval * 10) / 8);

An explanation of what's going on here would be helpful.

Why "* 1.25" and not, umm "* 1.24"?

> +		/*
> +		 * Re-using an existing one.  Let's update timestamp lazily
> +		 * to avoid making the cacheline hot.
> +		 */
> +		if (frn->at < now - update_intv)
> +			frn->at = now;
> +	} else if (oldest >= 0) {
> +		/* replace the oldest free one */
> +		frn = &memcg->cgwb_frn[oldest];
> +		frn->bdi_id = wb->bdi->id;
> +		frn->memcg_id = wb->memcg_css->id;
> +		frn->at = now;
> +	}
> +}
> +
> +/*
> + * Issue foreign writeback flushes for recorded foreign dirtying events
> + * which haven't expired yet and aren't already being written out.
> + */
> +void mem_cgroup_flush_foreign(struct bdi_writeback *wb)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> +	unsigned long intv = msecs_to_jiffies(dirty_expire_interval * 10);

Ditto.

> +	u64 now = jiffies_64;
> +	int i;
> +
> +	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++) {
> +		struct memcg_cgwb_frn *frn = &memcg->cgwb_frn[i];
> +
> +		if (frn->at > now - intv && atomic_read(&frn->done.cnt) == 1) {
> +			frn->at = 0;
> +			cgroup_writeback_by_id(frn->bdi_id, frn->memcg_id,
> +					       LONG_MAX, WB_REASON_FOREIGN_FLUSH,
> +					       &frn->done);
> +		}
> +	}
> +}
> +

