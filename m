Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6DD9C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 12:06:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA1552067B
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 12:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="f0GiGBSi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA1552067B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6E36B0003; Tue, 17 Sep 2019 08:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5DD6B0005; Tue, 17 Sep 2019 08:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC036B0006; Tue, 17 Sep 2019 08:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6E96B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 08:06:55 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9CA74181AC9B4
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 12:06:54 +0000 (UTC)
X-FDA: 75944286348.17.shake81_21117153325b
X-HE-Tag: shake81_21117153325b
X-Filterd-Recvd-Size: 4257
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 12:06:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WtFpIzP9ddukNyTBh2VDuhFoeOJpHrS1zm1sINk/rN0=; b=f0GiGBSiNPWx+gnLoXYpg4d91
	E6bAGBemjUa7DY7GiGB0/Y8Q5UCFAAMb4yKW7PIgA/Wyvz90H3bpu3IMekvAaqBjc4rbG/LZRUbTK
	i6kQ2gn3mE/zC5KNpEWv9jTJpS7wbjd0qjR2ixSgFY2ul9REv2SacUYUL0KrNAifu+iJ1JkVRYjje
	gDL3d+IO6L2E2RcgKvgcs1ajNYaaS25iB6JhPIVPXAWecAZF4GE+yL6DfGuU4yTrbOoxueCdC1VRM
	gvITAFSxp6E3Vi1ZlhGOWQ8v5VZBI5L01SPc0RqXpkGCbFf8M3tV0TtQrKJQA3TxzzdmR5hWEGXi9
	9+Qit4r1w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iACFq-0007sA-IY; Tue, 17 Sep 2019 12:06:46 +0000
Date: Tue, 17 Sep 2019 05:06:46 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Lin Feng <linf@wangsu.com>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	keescook@chromium.org, mchehab+samsung@kernel.org,
	mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com,
	ktkhai@virtuozzo.com, hannes@cmpxchg.org
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling
 memory reclaim IO congestion_wait length
Message-ID: <20190917120646.GT29434@bombadil.infradead.org>
References: <20190917115824.16990-1-linf@wangsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917115824.16990-1-linf@wangsu.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 07:58:24PM +0800, Lin Feng wrote:
> In direct and background(kswapd) pages reclaim paths both may fall into
> calling msleep(100) or congestion_wait(HZ/10) or wait_iff_congested(HZ/10)
> while under IO pressure, and the sleep length is hard-coded and the later
> two will introduce 100ms iowait length per time.
> 
> So if pages reclaim is relatively active in some circumstances such as high
> order pages reappings, it's possible to see a lot of iowait introduced by
> congestion_wait(HZ/10) and wait_iff_congested(HZ/10).
> 
> The 100ms sleep length is proper if the backing drivers are slow like
> traditionnal rotation disks. While if the backing drivers are high-end
> storages such as high iops ssds or even faster drivers, the high iowait
> inroduced by pages reclaim is really misleading, because the storage IO
> utils seen by iostat is quite low, in this case the congestion_wait time
> modified to 1ms is likely enough for high-end ssds.
> 
> Another benifit is that it's potentially shorter the direct reclaim blocked
> time when kernel falls into sync reclaim path, which may improve user
> applications response time.

This is a great description of the problem.

> +mm_reclaim_congestion_wait_jiffies
> +==========
> +
> +This control is used to define how long kernel will wait/sleep while
> +system memory is under pressure and memroy reclaim is relatively active.
> +Lower values will decrease the kernel wait/sleep time.
> +
> +It's suggested to lower this value on high-end box that system is under memory
> +pressure but with low storage IO utils and high CPU iowait, which could also
> +potentially decrease user application response time in this case.
> +
> +Keep this control as it were if your box are not above case.
> +
> +The default value is HZ/10, which is of equal value to 100ms independ of how
> +many HZ is defined.

Adding a new tunable is not the right solution.  The right way is
to make Linux auto-tune itself to avoid the problem.  For example,
bdi_writeback contains an estimated write bandwidth (calculated by the
memory management layer).  Given that, we should be able to make an
estimate for how long to wait for the queues to drain.


