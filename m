Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59741C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:31:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11C6E218AD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:31:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FoyI7ozW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11C6E218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B62638E00D2; Wed,  6 Feb 2019 11:31:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B11F48E00D1; Wed,  6 Feb 2019 11:31:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28DE8E00D2; Wed,  6 Feb 2019 11:31:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74A6E8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:31:31 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id l7so4847262ywh.16
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:31:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wNdena2+B8aX2a+ugM0wS8/ZQKJ93/KLLHUWmxBvBdA=;
        b=Ee+5WIqHqmIYrQ8LlMSLhn/rMPmtHEy4Eeo1UkECKex64n0mLRlwdwwlWoaiqgfJYF
         ylKpO18J3X8MelPZE9IZhNHUuHFeIUQrO3orgzcRr8x4eZHQJfU6pk9e3RmLpsKaW/0q
         30h9QJ71guWHU+CKn7dx/3oD/wq9VPCLEPDCjb7YuYK+f7AdzxzOr7ZRUbwItWHxGrjC
         rkyUFQubQ07Tn3iDzXr6JVinlG5IRmOfmVAwUIplSY5rX4QfIN9pbojp8OA9Zn0+FrU6
         jpNoiq55r27Frxb2JNXOXkGhPl/mTGHWapWEKxid28yhY4o1Q7mcG7S1/CQQ2MsuXvpI
         Gddw==
X-Gm-Message-State: AHQUAuYusEbUAAsWHTpYRAx9xrw03Y6M9Fyts5YmvPdC6/ZmAsCG9JfI
	CMJADZCJAxIZwCFQCzgn7aDnWykLrSKN7LH52xtg/mBzAbvm0HiqPBLtIpiex2+Gvq/4fpgdqy/
	dxZ7RkeUocFFbs9Rj0tBpUlESJ5VzmFYDQTjTfIQR4xb1ja7NT6wNS4LBaxysxSi+ieYId+w0w6
	4wAvqtXTeBmfDW5TSG5+bW1YJr5pcSDsO6m7QYBP8cfVujrEKZpZxvJJ5ouPjHm+AaaUQVKniAy
	U0+FW+JYWC61Y+dMPq86yUC4hGgnKaO5CIVWFw3at1HgcFdlxPe8ml1qYQtP9NLnNK0Li5+0HPs
	KYq1vXyRCth8ETJg8KHssmnve56n9AFRAXN77hsQxg5DdN5yyd5nryY36NNPDTLkN4dzNcyU2g=
	=
X-Received: by 2002:a81:4f93:: with SMTP id d141mr6849047ywb.341.1549470691229;
        Wed, 06 Feb 2019 08:31:31 -0800 (PST)
X-Received: by 2002:a81:4f93:: with SMTP id d141mr6849005ywb.341.1549470690754;
        Wed, 06 Feb 2019 08:31:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549470690; cv=none;
        d=google.com; s=arc-20160816;
        b=YkopwEyLmyHCyqEyCpXIHCf/XlaTVGpRTytNDfz1xgrJb7RAf7bLSWckt7k5EjsYOq
         ovfvwre/XkyCh3K/NBhp98Iw2G6N9kwi7w5Wy+hYvpA+ZQSMR83HHeTz4//9/eAbSH/z
         abC9eV2qV8UkWQg3aoQ+6H6OA54wWOoLhOu+fCNfSiNXo/GV0DEyyRBrB9ocGj3MAL6d
         6IaaLchDZQsgHYB4KszIQuyK8LtmMVgeZD7qzUJlQW0rNwM17RSvJpnLLDQmZUNGQ1np
         giFc/ot/fksbw041FuMIMhwXRmNjVWVluFuT6bbKi87nB0w4a6+jPZrTfwSUQiYYIhmu
         zD2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=wNdena2+B8aX2a+ugM0wS8/ZQKJ93/KLLHUWmxBvBdA=;
        b=YbB/64izFmg2vhgKn/vr+q+Ghb1QUWCT3DW1hdn6sb9FWE/qPoZA6cfqTToA5QUe7u
         kmDNKmxptld9gj61xOVhzQveI1eueX7BfAZAqeLjKTTSBSSoSvKcaDARlUqSnNW/OSa1
         K9GjSfrugw4He+odO3AkBteRh65wdLZ20fgNt1Vf0PFWSBkloDHYewkPTc/ubxFhH+ge
         cFxrsTNrLBO+6MWkJCrKumUKFC8iDCyLl1bTnbcRPLsnFh9IRTqwkuy1ZhcgiK74/EPb
         37fEaWOc2o+2Rsy3UzzkW6BNEHYskvIph6+eDmkb14noy/cT4pT9P22HVXZw929iPNX6
         LMxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FoyI7ozW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor132093ywh.141.2019.02.06.08.31.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 08:31:30 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FoyI7ozW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wNdena2+B8aX2a+ugM0wS8/ZQKJ93/KLLHUWmxBvBdA=;
        b=FoyI7ozWtdHwL7oqCXYUUa27Kf/CaiprIDAZ27rG/ACpPLcrWyKa5448OHvNTwROYF
         NwPr1ZVvQRs26d03SWa2IgPykTLNmR2baqqGttPyd4YdRX2bTD0ATz7oXqJ56LbNDLqs
         n+aajVTnCVnSMj2BW6HTRm4ujB0BNTlZ5GrZJ/IntyXEoW1lE9ItV9X+hU0jtYQGGPGu
         VfWmViXqIKvfKe/zlpj5v0kpLi406kWNT2Ed9GqNjJwpZjIkIAwQTbj1/x1P94/fq+H8
         J5WBCLIdTFycbBUHFlDNjEv4pO3T67zIeW0GBSE0GGjgCxfNMQ5TGYbiq9tDAABK1t0+
         c9KA==
X-Google-Smtp-Source: AHgI3IZSfrAYkVVaIWkI0ae+BkZR3ywza4XTLtz8W+WpLFGoP2XVY2s3W+QFN91LpxAKSw2sgqk32A==
X-Received: by 2002:a81:1d44:: with SMTP id d65mr9320079ywd.483.1549470690190;
        Wed, 06 Feb 2019 08:31:30 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:3bf9])
        by smtp.gmail.com with ESMTPSA id x132sm4394382ywx.27.2019.02.06.08.31.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:31:29 -0800 (PST)
Date: Wed, 6 Feb 2019 08:31:26 -0800
From: Tejun Heo <tj@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
Subject: Re: [PATCH] kernel: workqueue: clarify wq_worker_last_func() caller
 requirements
Message-ID: <20190206163126.GH50184@devbig004.ftw2.facebook.com>
References: <20190206150528.31198-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206150528.31198-1-hannes@cmpxchg.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 04:05:28PM +0100, Johannes Weiner wrote:
> This function can only be called safely from very specific scheduler
> contexts. Document those.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

