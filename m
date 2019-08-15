Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C454C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5A4C205C9
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:31:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N47XHCOS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5A4C205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61E476B02EA; Thu, 15 Aug 2019 13:31:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A83C6B02EC; Thu, 15 Aug 2019 13:31:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46E8A6B02ED; Thu, 15 Aug 2019 13:31:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 204B16B02EA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:31:53 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id ADFBF180AD803
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:31:52 +0000 (UTC)
X-FDA: 75825354864.12.sound11_2d7339646c024
X-HE-Tag: sound11_2d7339646c024
X-Filterd-Recvd-Size: 4073
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:31:52 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id w18so1759869qki.0
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:31:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=no35aRJk15zFWg1jR8wwX86QzYLoUfFHVUo7VWQ/svc=;
        b=N47XHCOSmAXueVA0YYaev8/a4K3QvUHId7wqDd1kKuzb9i0XsPGZt3JSFV4fwHmm1o
         079FfdNxA44u+Lpn9KWO67P5gdQDjS8yLNUwxRyP+az0D6idFOXOvoIL6oT/ByHrYA+e
         5x2GXXGdhLQUUhHxcna9tpQrgumRatQu40F/xy7UzP2oUcoOJ5ObUyU55Ybx+CjVdZVf
         ZGK+QWvr7EafhXZLjXcXxcSaDgonosEcUP9Kh6/WmBW5wIhcwJ7Gd5u11eGiOYvLgYRX
         ruJyUluXJcICik/5Pis1nVgLz6wleggRuqyNbfxBltc6VpOrVEuqmr44g/tLfUNGnReK
         /wxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=no35aRJk15zFWg1jR8wwX86QzYLoUfFHVUo7VWQ/svc=;
        b=NwlHnAclw2S/UyFr8DUoT7peeNXp/yqOjxxPjcde5hvIYrumVd/pXfDIA+ApyhkA4m
         qoTcgho2J0za8IR0MAPcdKhcmjo9s+FoksG8UzwAlzDc5CuRNGbl+CmNy2EQSLk38D/a
         GEueS2qV8IZaMd67Q87tTuc2P3BZHgKuJyc22j0sJkV+5UFNkXaurXpVHvjUSYOZoIgN
         dSB6s/OG3yfdVfvXOGlkiySI9F6m01YmXSSKPi9QaELC+ggqIS0i/anD8YzzrjKDtoPm
         2SYwUXyAxxFMuitoFwHvz2AAubef0OZa7Kn3c5rHvL0aQo01k/J2dfmm81bxTb9QCRF1
         F9Gw==
X-Gm-Message-State: APjAAAWJx4NbJgNKlRZXW1h+nwBVBrhoLPFFE7w0CgnAAmblwgR7PFR7
	S5pYuk7980PxwawX3LgYHzg=
X-Google-Smtp-Source: APXvYqwTF1AugQK16mXeTAc3YHU1jdzIKEshxpTbcRaCWmkGxQukcPJXecgkAY0Igu5HQb1bcCAfWw==
X-Received: by 2002:a37:aa57:: with SMTP id t84mr5056219qke.34.1565890311488;
        Thu, 15 Aug 2019 10:31:51 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id v24sm1928599qth.33.2019.08.15.10.31.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 10:31:50 -0700 (PDT)
Date: Thu, 15 Aug 2019 10:31:48 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 4/4] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190815173148.GD588936@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-5-tj@kernel.org>
 <20190815143404.GK14313@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815143404.GK14313@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Jan.

On Thu, Aug 15, 2019 at 04:34:04PM +0200, Jan Kara wrote:
> I have to say I'm a bit nervous about the completely lockless handling
> here. I understand that garbage in the cgwb_frn will just result in this
> mechanism not working and possibly flushing wrong wb's but still it seems a
> bit fragile. But I don't see any cheap way of synchronizing this so I guess
> let's try how this will work in practice.

Yeah, this approach is fundamentally best-effort, so I went for low
overhead and mostly correct operation.  If something like this doesn't
cut it (w/ bug fixes and some polishing over time), my gut feeling is
that we probably should bite the bullet and synchronize cgroup memory
and inode ownerships rather than pushing further on inherently
imprecise mitigation mechanisms.

Thanks.

-- 
tejun

