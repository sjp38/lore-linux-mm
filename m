Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22FF4C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:31:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB7AF21E73
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:31:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S/hC9pFy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB7AF21E73
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A69B6B0003; Wed,  7 Aug 2019 14:31:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 756BF6B0006; Wed,  7 Aug 2019 14:31:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66C4C6B0007; Wed,  7 Aug 2019 14:31:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459256B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 14:31:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s25so79740084qkj.18
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 11:31:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9vz8o0/Fg9HbJyVE2ylEHY7Bd2jvJ9o7HmByhNCHje8=;
        b=Mb8uz+FGk3thZW01GNH2PH6IxBboy+xJj4eslQTm/ca81OQgmryzkjo/2WuzcnGN5q
         tjeMYU1lh37HmKSUkEOCH/w3Gjdgahm9YfdtVGYCvCdWNDwO8E8Hjkp/k1bT/Zo3kAL3
         GE6H3qyVR1uP7HJwt7HZkub6ztgpWmgpq2ILe0qfHZ/EOJx4RnPKV3j1/vHtnHyAwx/D
         BETYD6VnHzA9d9l1bhhCwC5s2LciSsBmnIglCA/LX1O11nlExOlDEHhO4FeFZCG720YC
         XeO0uydgLzVAWKxXrZBOMoxDU6eV304qIiz/BUQh/iClIX5avSQLhxH4ewmm8QlhDhfB
         I4mg==
X-Gm-Message-State: APjAAAVCoQk3R4t46ukD515yUbzJXW6y1iWrvzIi9iOkMZ3Kj+kEN11q
	WPSdcgQE5MA4Z76yFP/RgMeRcfw7hka4fA7akMyPIfx7+pPDaKPx0I/qR6pHVzhIoySCOPo7TmP
	DPJ9zcmfSnoNNHZmi2RStiGypFxUN7rPrk5qfNnZAEdDXgd+Emv2vhSg63eIhVkA=
X-Received: by 2002:a0c:b786:: with SMTP id l6mr9610981qve.148.1565202715965;
        Wed, 07 Aug 2019 11:31:55 -0700 (PDT)
X-Received: by 2002:a0c:b786:: with SMTP id l6mr9610912qve.148.1565202715089;
        Wed, 07 Aug 2019 11:31:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565202715; cv=none;
        d=google.com; s=arc-20160816;
        b=q2sN99jjpkL9CLnr73pHoTntSi2X/poQsu+OrtZT/04iV0o/sXEhOYbIbFOWzSxmdo
         bfZKka51y1EJAkaKnGAj6k3YJ/WHaOrixGLPoRf3AjReP8OOjOVevnjheAP6ddpIIory
         PDAM9nMyA/HP6K8G2Iw1ddj1LFcg8a/cOhge8HIZ3mvdLFF6ekZgk85OUTbbqJ+93Ao+
         56xJnLjlCT9shKXDrsaroJemu/EanTDO48opfQ/JxOUet3arCI1xPNQfhlaXvKmOAXHB
         gjx1ebQM1C9kIlACQp+IJR/dWzbFychBNJK1plfyBPpwoEkbPCe65j4jmKVI7/BX6+du
         ds9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=9vz8o0/Fg9HbJyVE2ylEHY7Bd2jvJ9o7HmByhNCHje8=;
        b=EFycASi8R0It61Bm3r9Zh9wMHMmKDFNryslNpqFbHiUVS8ttSTrZrfUHsamDiyUVAn
         pnfXcu/nBSqA1o9Vkter2J8DxALqGhaDxIrbXRymG3GLRnMySfb52ikyF5jJr2Ak8D52
         F5gUp5Gu+OAfWiGpdKBqND6QZCMeCdkfvIke9HJZRuC2qduBH9Ke1cYkMmaCiUhiFo8C
         FjIMpjoKxv2LnPsLwRDZCU+VQD/52Y+quynZ5rYr+I2bTfiEp1UzY45r3ovJJ+mpSFZd
         oG91LHSftw8HKnNLxekyh8P3LqOLEygpHAxTNkd3EkO8hG4czNyrXNAAXoLH5CkuHuUJ
         Jtdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S/hC9pFy";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor887865qkb.90.2019.08.07.11.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 11:31:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S/hC9pFy";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9vz8o0/Fg9HbJyVE2ylEHY7Bd2jvJ9o7HmByhNCHje8=;
        b=S/hC9pFyYsK3bBGpkS+QRQZx9iC78MlaFPdHy5dgV03bOA1Dd/SJhJT31pXIM/Vdpr
         pTggs2ww4s5HKZ6Rl822jfjP1lfNILksJxMEIOa1T+LCO8oErZSfUgyFzQR31AWOeOSi
         spJB4tB+m3qzO4p/d+Wyh9B9np+ZwkmgbeoAG2uGbxmQRjowE3F4Kc9wJwRI1Y52Qx9n
         n5/nIcew9FwUxZ1EQwHSBCBD4d/V6vY5SsokAC80mHelGqNJlGBMJsesOifrtC+/Dpu6
         5atcb/gJevn9CWlil28jn8uHgxtBr+UG4Ps4fouBx792PF2Ko3Zbv5IQY43ZLeBdoo6F
         xdmw==
X-Google-Smtp-Source: APXvYqw2S8tifKu8V/Krxm/Xjt4iJUYrR46IiTCnMxoNFDowG4ynyeA1cuZ35IBd4uwpAyDAkgHk7A==
X-Received: by 2002:a37:c247:: with SMTP id j7mr9721021qkm.94.1565202714521;
        Wed, 07 Aug 2019 11:31:54 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::6ac7])
        by smtp.gmail.com with ESMTPSA id k74sm44829295qke.53.2019.08.07.11.31.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 11:31:53 -0700 (PDT)
Date: Wed, 7 Aug 2019 11:31:51 -0700
From: Tejun Heo <tj@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190807183151.GM136335@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
 <20190806160102.11366694af6b56d9c4ca6ea3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160102.11366694af6b56d9c4ca6ea3@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Aug 06, 2019 at 04:01:02PM -0700, Andrew Morton wrote:
> On Sat,  3 Aug 2019 07:01:53 -0700 Tejun Heo <tj@kernel.org> wrote:
> > There currently is no way to universally identify and lookup a bdi
> > without holding a reference and pointer to it.  This patch adds an
> > non-recycling bdi->id and implements bdi_get_by_id() which looks up
> > bdis by their ids.  This will be used by memcg foreign inode flushing.
> 
> Why is the id non-recycling?  Presumably to address some
> lifetime/lookup issues, but what are they?

The ID by itself is used to point to the bdi from cgroup and idr
recycles really aggressively.  Combined with, for example, loop device
based containers, stale pointing can become pretty common.  We're
having similar issues with cgroup IDs.

> Why was the IDR code not used?

Because of the rapid recycling.  In the longer term, I think we want
IDR to be able to support non-recycling IDs, or at least less
agressive recycling.

> > +struct backing_dev_info *bdi_get_by_id(u64 id)
> > +{
> > +	struct backing_dev_info *bdi = NULL;
> > +	struct rb_node **p;
> > +
> > +	spin_lock_irq(&bdi_lock);
> 
> Why irq-safe?  Everywhere else uses spin_lock_bh(&bdi_lock).

By mistake, I'll change them to bh.

Thanks.

-- 
tejun

