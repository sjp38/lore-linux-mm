Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7E4FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:22:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67C1B20449
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:22:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GsP1PSkK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67C1B20449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6EE6B0290; Wed, 27 Mar 2019 14:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1758B6B0295; Wed, 27 Mar 2019 14:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0655B6B0296; Wed, 27 Mar 2019 14:22:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2C306B0290
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:22:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so14561654pgx.11
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:22:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p7uJNRLkzeeNJQDM4SyzmPlQbirmlbL45c4zuRXPsDc=;
        b=TOdDlrFM2HzlKl6O6TxjloPpwjdojHZu/r6dulxvNmXsEVwyhm4FurOTbIhbuAx6ud
         Ry7gJs5u5rYGrSPgTxnT/ZuVdK73SyspwLE1NA/qk/Pusr2eK0RQ5EGJ/yidzeOgomDQ
         TxqGYvxGac78rLpNMp7VNzBNyGYIqtpOHYqHTG/i6UpDGmWdDIWmJaryK7NnxNqTV1N4
         KdxSpReCAIBzDl8hO0ME8pZiPXCPm3EwNulpaqjBn+kj//MJTS5P2pFeBWs+nzJzFJ0t
         xjzZCTvxDvas2xcupm3JD+ukbQCbchp9NwyCL3oxDYxAS1MyZn2kLsKW/AUas+7xPkDG
         N6OQ==
X-Gm-Message-State: APjAAAVnmoeQOo0xAJQQ+ql62s+tbSHHRH28p459/8rMX0aEQ5y/tZe7
	Eb7GbaNHiBw6Nch638sPr6MCY18k8Ei0oy5RY7CMO52Sc7yW2Yg2l2LKhto4/DzZsy+7h7jFNOW
	udZpHOpq36PkXjpn6vYxj7WfE+PeKqXHvYW3chWGhiBcbkCmsqktR6hhK3FRjB48dGQ==
X-Received: by 2002:a65:510c:: with SMTP id f12mr36622727pgq.40.1553710925474;
        Wed, 27 Mar 2019 11:22:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVN9HlfzZ2WewmnZufKG4EQJK7HCyKDiBXkEIvOAF08FmySGiwqEMPA9n4jW8rkhPUIRjs
X-Received: by 2002:a65:510c:: with SMTP id f12mr36622627pgq.40.1553710924238;
        Wed, 27 Mar 2019 11:22:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710924; cv=none;
        d=google.com; s=arc-20160816;
        b=m2dOF3BLSMd9ef0Qp6q0NQ4BF1piB5+r4GPZJo++w1id4KTbU9XfRkXaDSpup7p4Fz
         8b06ZEDiXI/wpuTo1e7ylPbQVnJNmHe3VPHCqTWEa0f9Uj4C+P4DIglFlVWAWQJjFj5K
         JrPTb+hypzk21Kl23OcKrhXwuGf+JtvaCjU7mSBrfIMcCdDb6m1h7VeDXxz8h8L6C9X2
         nFgJxziMrpDQt++jI2kLIo0MnrTkEXkVYYc93zwWshUD7eIJ30W7iXDP/AQn2u0hWkCk
         bkaRGQMEAy8n4/ykxyzYYiuDdZEm0OGvNmTPoI0eIYa6IOtMDxCpErSxtOeHLJA1N+mu
         OepQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=p7uJNRLkzeeNJQDM4SyzmPlQbirmlbL45c4zuRXPsDc=;
        b=dcmjLZK2wr4gt+WqARuBaWMsKsuazBPRan0w1amvQ5yDL3G3gp0f2oG8KihEd+OMUW
         FgqHGLEsNFsHkPo1/eQPThWHRuZFnKKq/8z3hBldGefzuHMoa3IQBImBxZzita8k/21/
         ZZHJJqHQ5s90poG9nr0rntsG9kLWnIK6evMuevUoyPBn342jL2dmvZ18A1s0nQTo3BJv
         yP+1hjFZsLoDMck8cMf1Wf/Bgg7xyVrQqOwqVW+vQnBfmnB94bNF5zzKb+ZMGglHfrRR
         nYdrWiXEDiLxsxiYvyR7QUez04gNGS/Uszv4eGfH1FpwQgOdaJTSms3Eg9vzJhnaFKPB
         yeaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GsP1PSkK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n11si18362648pgv.491.2019.03.27.11.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 11:22:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GsP1PSkK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=p7uJNRLkzeeNJQDM4SyzmPlQbirmlbL45c4zuRXPsDc=; b=GsP1PSkKCM3pKHBQoPlZ6U28O
	p7kN3WPwHv2Ayga/YUdwllSSRNfrRZDjXDr6XKNHjs72DF8Bq71fI7ZJ5tqFi8MTOO+xsM6nvRqEt
	yphYGTt3bEDJAUcNFhtBV50f4zqN9fzKU9pyTlijQCa+r5YDvSvtZjz1e4EkPCQG5GrreXvXQBDwv
	rGhTGKVG545O5Gx1e9+8nIQyoP/5Hjg/mFm/V/gatooBIn2wADh+sz8/qcqinBr91u+VLItmb6kWb
	StTLEYhh50ngqYJ9fhOZhgCmFzZgBAYd9ZsyVBZtXNJqEm6AMp185aMwJaTHmYhc5wgPihAYpuiq3
	39u185IDg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9DBW-0001Q1-GP; Wed, 27 Mar 2019 18:21:58 +0000
Date: Wed, 27 Mar 2019 11:21:58 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190327182158.GS10344@bombadil.infradead.org>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327172955.GB17247@arrakis.emea.arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 05:29:57PM +0000, Catalin Marinas wrote:
> On Wed, Mar 27, 2019 at 09:44:32AM +0100, Michal Hocko wrote:
> > As long as there is an implicit __GFP_NOFAIL then kmemleak is simply
> > broken no matter what other gfp flags you play with. Has anybody looked
> > at some sort of preallocation where gfpflags_allow_blocking context
> > allocate objects into a pool that non-sleeping allocations can eat from?
> 
> Quick attempt below and it needs some more testing (pretty random pick
> of the EMERGENCY_POOL_SIZE value). Also, with __GFP_NOFAIL removed, are
> the other flags safe or we should trim them further?

Why not use mempool?

>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN)

Why GFP_NORETRY?  And if I have specified one of the other retry policies
in my gfp flags, you should presumably clear that off before setting
GFP_NORETRY.

