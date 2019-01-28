Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D63C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB9F62175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lVQH1nAe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB9F62175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F3248E0002; Mon, 28 Jan 2019 12:49:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A0638E0001; Mon, 28 Jan 2019 12:49:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2696B8E0002; Mon, 28 Jan 2019 12:49:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023168E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:49:10 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id p8so6600784ybb.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:49:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RDoi/eLjxnbObU8/lFllv41Z8VtANrIPfKdXbpygwCE=;
        b=tKsadUOYaOtLYpwJv6Q9usFa4JcngfKaHvqX7m49Yr4Ox2laqWkhcsjlp/v80M/+vh
         iU9tge0huW1JDAbTdVxYr6gJj2YlC+Xhplybx7B6S45LbUDJAACk5pQV6HRyXo+onEZW
         EYpz+mHVrAn67cnCke6P1O4cLp1q50NWJezFHV1S9MwiOjly3TZ1zj2Sjf98ydUtn8Xh
         VqhLYhSp9fcQGDwD22nXNi1O9+J7VSMp0+LT3cc1kfFQA6P+kcQu+hLwHXbS5+tqjXim
         HwXGrZ4myislm08Nl6c6YZ25Is/yB+lUh8fYIM1n1eqNcjtHGsYQ1PCjqFIZzzM51Ho6
         v49w==
X-Gm-Message-State: AJcUukfUMM1v5IISC2tPOTijX2DStdxqZ7s6bkgn0O2pmvzenmKW7kzw
	BVB763Owta10n4EsTY1PHZ0LjQ+NLOWH4FPIj6wPzooGVg9r9RXvgtCV77ZP6G2OLsEFwxzO2OT
	EdwxTmgIFk+cmXhD/X5WeNFoAVUBtn9CQmD8UrqdWKWuWMS0YlqZAleAWR9jbZVeHUmoksIvw01
	96q3EfsFGW0O61Elk6mtuc/ilReA6OdqsMEUu8ETOn5YLIqx6ekqWLmtdMoYBtCrUUO/vm5oPrV
	3Y+tgungu5FHbShTFVlMJJ2sT8z2eF2o5kwwGMfk13Off+S+T6Jo2S3kRWmV5F5hU2AHuzchvps
	KHwxUjI1Sl3D2ipq4H9k9AJlrQYglcwx/Lqy5KU4r/PBv0JGw9rKOB185shgBeQmetpyUiKhww=
	=
X-Received: by 2002:a25:7909:: with SMTP id u9mr21396535ybc.451.1548697749375;
        Mon, 28 Jan 2019 09:49:09 -0800 (PST)
X-Received: by 2002:a25:7909:: with SMTP id u9mr21396496ybc.451.1548697748663;
        Mon, 28 Jan 2019 09:49:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548697748; cv=none;
        d=google.com; s=arc-20160816;
        b=eLnqKgexPpou4P5l5LQJjQ9ddlhZ2p0UsA6Q4UipjU215D8TMlkl5lpBlLKq/qIRMv
         83nfzjjTT+VjO0XiFXTSLyjb56C8RkLCtkig1B5HmsBugCnHcCFEURskMpX5O2QHCkBU
         Jswz7XEQ9vdD39WNGVoajKZwGwoP/0K+FhebZcq8xv0wwCzQatXC4Zg0q7QBov6fbyMz
         O397l/9TJgwZBfV+z4SOYTtrLqonSUP1+ZpTC7R4u/Yz9ITPP04ytU1uR12OzRSg0Ptk
         C/F/aJ2262VueGz6cYCl2GZkfYjx8KooPUoAN40oOGjtkUBY33ArfcUOw1tdl0PV8gno
         Qknw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=RDoi/eLjxnbObU8/lFllv41Z8VtANrIPfKdXbpygwCE=;
        b=ZuQHemSKOb6cQm5ob5HWKBjHczONWew8B+HFf9aZQjcR29lkZNuQwGYVF4h6eyoMJk
         RcjfOP1jfQ8TiPBtul+s7CiKCyYmbfuwfR0N2lDPoos0XEC7k7Bapn2WyIHsEkpkFjEn
         yA2bPjVIf2z4Q33Ud8Lp/eE07Wr2+SGcdNxJ7yRQGDUnpthp7v9egzPfHi1nys2YUGbu
         jNNHRzovuzGhccFXPhUuPKKNX/bbBJ/4iBAAtV2oFCybCajhfhVDgfPJLkxdTK3cYsE+
         X2l0xJsI/+AVWPawHFonbgk5AiXVg+yimZB7O8tUeM2jQJjDZC7DtWW1VZ+OWzRpGMui
         TeqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lVQH1nAe;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p130sor4419008ywb.39.2019.01.28.09.49.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 09:49:08 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lVQH1nAe;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RDoi/eLjxnbObU8/lFllv41Z8VtANrIPfKdXbpygwCE=;
        b=lVQH1nAeTUapo+A78necDxJ89EsWzDvsbvfeD3DQE7e36L5IebWuxztHjBVoiEnB3H
         JeYQjUy2zp7nWDkKEDHWbhMsmEV1MFDjEeVeJ8VygkmA3LoR71R+X5dLBG4+lqqUOaWi
         02xvs+8jBWBa+6eYq8LBoIGsolX6zO1GdwGD3IFAMWM8PbB4KrSsY+KxY9yeJ7jCBhY1
         0UCJptuXx2QuyCQjU/AzkD5lNtgIKEWL2Qosqrg5N6HL8+iL2cLg8oWv6QbP1rznpvTm
         cFlCvSg7b/VQb0x4QHr+rmpIWzqsN5L/045u6n82TWmN4rcvRTAXhNjm1X1Hcwgj+I2M
         YJUg==
X-Google-Smtp-Source: ALg8bN4UwYkLurYiTtunS7LxeB7dpx1z6ERbMLfdg4VnL53YCm4TRhvjnIQJ3e8G5n+bKLi2/RRHFA==
X-Received: by 2002:a81:4f97:: with SMTP id d145mr21795942ywb.198.1548697748275;
        Mon, 28 Jan 2019 09:49:08 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:31a1])
        by smtp.gmail.com with ESMTPSA id n16sm15879617ywn.31.2019.01.28.09.49.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 09:49:07 -0800 (PST)
Date: Mon, 28 Jan 2019 09:49:05 -0800
From: Tejun Heo <tj@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128174905.GU50184@devbig004.ftw2.facebook.com>
References: <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20190128170526.GQ18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128174905.BMCVG1w1ppsdW1mCClvABHA0kKw0S0ABSAHcN2OJ61Y@z>

Hello, Michal.

On Mon, Jan 28, 2019 at 06:05:26PM +0100, Michal Hocko wrote:
> Yeah, that is quite clear. But it also assumes that the hierarchy is
> pretty stable but cgroups might go away at any time. I am not saying
> that the aggregated events are not useful I am just saying that it is
> quite non-trivial to use and catch all potential corner cases. Maybe I

It really isn't complicated and doesn't require stable subtree.

> am overcomplicating it but one thing is quite clear to me. The existing
> semantic is really useful to watch for the reclaim behavior at the
> current level of the tree. You really do not have to care what is
> happening in the subtree when it is clear that the workload itself
> is underprovisioned etc. Considering that such a semantic already
> existis, somebody might depend on it and we likely want also aggregated
> semantic then I really do not see why to risk regressions rather than
> add a new memory.hierarchy_events and have both.

The problem then is that most other things are hierarchical including
some fields in .events files, so if we try to add local stats and
events, there's no good way to add them.

Thanks.

-- 
tejun

