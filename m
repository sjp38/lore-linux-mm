Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7E5BC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6583621E73
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:34:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R644OPU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6583621E73
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 116876B0003; Wed,  7 Aug 2019 14:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E766B0006; Wed,  7 Aug 2019 14:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E808D6B0007; Wed,  7 Aug 2019 14:34:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C41A06B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 14:34:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so80045119qkf.14
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 11:34:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TEd6gatoycG7ZYK/wRTlCi/eISRx26y7juuHAC9jUEs=;
        b=PsMN5+j4H8CLnI2ZYiRKDoNP74PGIYm6afYRKgrEAw1EDw52UODbvZYBmuZIW1Dr3s
         +SjdsdSy2Xhfd7iG1qouzX+x9VzFMPzD/1cHmSSHw95rJrUR519Pi/m7N3MGIvyUghc1
         u47/k2A0JRbjcGpxJR+LGU5eNrn4WOVatD7QFb3J0tKlFyHc180eMLY0ZVYuNkAwH2hF
         SqozFSpZ4GvmiuH/w6VQk5JjkW3dV3/Yw9VdhyqTrNKu0fFwRU9zPAr7qk1qC7YX3tPd
         U5TVe5wzUQ4FEitCqgv6dXST49IT5OmhvRId9m4fBUFZ+wyu67Si/VOCnAatnpzPPwFb
         hBew==
X-Gm-Message-State: APjAAAUw7Q/ogzv7TygNWYa+z0Q8GGZZNwwrkbo36nHywrQzjhqmwAsU
	d1V4SIVrx0Z+O6nV3Yw4E3YVXW0caCWGZuKEwccQfRNNMjfAO1xi+zuNcXRU5rSoElyauuuOPwU
	As0A9Pi8CeVfY18YTm7nSCjKuufzlfbkcE+ryfnJtWRQnHvYHZZrJ+BmCgyXRVQg=
X-Received: by 2002:ac8:142:: with SMTP id f2mr9405233qtg.336.1565202877596;
        Wed, 07 Aug 2019 11:34:37 -0700 (PDT)
X-Received: by 2002:ac8:142:: with SMTP id f2mr9405199qtg.336.1565202877090;
        Wed, 07 Aug 2019 11:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565202877; cv=none;
        d=google.com; s=arc-20160816;
        b=p+1jePEHBw639VNLP1j0UhbjZp6olzelBLKgNqksQ4bJcIPhw4qZ924F5kEnhhRLti
         5oEU99XPjTaqqOHcizItci00Y3zJpNC3DaWjqq+/7gJoGL3v7CK7ccHPzigdNDPC8zLa
         2DJ0KIWi/yOYDoKJKThXEm8ECzLCkkVV4IFsztDbCQHp944w07P24fPJ0vIc44HFuux/
         WcWFrRDcF/g8Muh7UFzXL0mh18/3jU1/XFlolO6xr58dbDA2w+8YO7lbI+pydGAgKd8o
         HJsL89ypQ4jMR/y3aHHiOXmtlGvAoNDgDk+g6cUmbm9nUvMpZoHXBwnVZ7UV6Qcv2LDn
         Fflg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=TEd6gatoycG7ZYK/wRTlCi/eISRx26y7juuHAC9jUEs=;
        b=t+OSFWM8CDUGcIbDhDNT8vEWm3EiTEi9EZnmqGGqoowmIVszVzWaLI8IFdyYVxmQpC
         07nrwetOjRhpVlgvWUunwnjbbY8EtVWaS2/Rb2pMQRE6IzXyMh3SFIIy0qhX+ShvwtRO
         6dM4QRxfLA7J1HKlIL31JiAXYfQGS13PdjZm2fRErherjtHv/WRgo7RMp8LMF0qbE+Gv
         KpHJPwov0LSrsCmvDMoblONJIQCTFAzBfxOq5PEMEslu2V3yNoLmrtIbuetokCA0KJTM
         NeDXOtiEQvgONNr8U2yAdQwvj6xw702yByqQGzhKucLtkI1VZCX5Ju92MZ2pcqlA27vL
         fTRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R644OPU+;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor1970486qtk.20.2019.08.07.11.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 11:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R644OPU+;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TEd6gatoycG7ZYK/wRTlCi/eISRx26y7juuHAC9jUEs=;
        b=R644OPU+lCko3k9nDXGu9/A/vuDcJn94rJoMUPsDRCffxsG+isnp+BHBLQmc2K644e
         66mQuGkZTGxAke75vOwmSvJK6B7tThNNgU17Mmy0pGVSIX7MQcF/72c5IwF+SVKe2+/9
         3vXSRys0roMn1jdcB9qW6Ab8phv2F8C6FUUrmfEUu1zHhqC8meLDYyMaehtDUQwJF5bQ
         Y8GRTNQsLFdruJQs1xnvhyznDmk+7799OjLS/bJHXjEXyrGCjSTajeSkhizcSbuqKREl
         DPUrIKRtYKK8ndWxQKW2D8e2SYP9w65swXBr4FQtUapMvV0tAHkSYCN+X0SubrlfmUMZ
         lRmQ==
X-Google-Smtp-Source: APXvYqw/m3khFk3Yualfy2xpN4sanvEEAmz6JBxD6EOIZ0rs6tDT7YTG6mbRbwiCk+s0QUksrpFdBw==
X-Received: by 2002:ac8:2439:: with SMTP id c54mr9364734qtc.160.1565202876678;
        Wed, 07 Aug 2019 11:34:36 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::6ac7])
        by smtp.gmail.com with ESMTPSA id i27sm37896195qkk.58.2019.08.07.11.34.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 11:34:36 -0700 (PDT)
Date: Wed, 7 Aug 2019 11:34:34 -0700
From: Tejun Heo <tj@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 4/4] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190807183434.GN136335@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-5-tj@kernel.org>
 <20190806160306.5330bd4fdddf357db4b7086c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160306.5330bd4fdddf357db4b7086c@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Aug 06, 2019 at 04:03:06PM -0700, Andrew Morton wrote:
> > +	if (i < MEMCG_CGWB_FRN_CNT) {
> > +		unsigned long update_intv =
> > +			min_t(unsigned long, HZ,
> > +			      msecs_to_jiffies(dirty_expire_interval * 10) / 8);
> 
> An explanation of what's going on here would be helpful.
> 
> Why "* 1.25" and not, umm "* 1.24"?

Just because /8 is cheaper.  It's likely that a fairly wide range of
numbers are okay for the above.  I'll add some comment to explain that
and why the specific constants are picked.

> > +void mem_cgroup_flush_foreign(struct bdi_writeback *wb)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> > +	unsigned long intv = msecs_to_jiffies(dirty_expire_interval * 10);
> 
> Ditto.

This is just dirty expiration.  If the dirty data has expired,
writeback must already be in progress by its bdi_wb, so there's no
reason to scheduler foreign writeback.  Will add a comment.

Thanks.

-- 
tejun

