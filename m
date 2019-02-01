Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05355C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B28C02086C
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:58:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="HcVwliAM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="j63DN7o0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28C02086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F65B8E0002; Thu, 31 Jan 2019 21:58:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CC778E0001; Thu, 31 Jan 2019 21:58:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BDC38E0002; Thu, 31 Jan 2019 21:58:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA098E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:58:24 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w1so6132278qta.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:58:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HSl4cOeylKJWGZ1gRfcpgzkKgRGUpcow+/PQb70GWe4=;
        b=WG1svRKucWb7t3FOxNfPnqLHfsta1fc2gmP1GTrnBPoTpZU4tgrWt5+hRJi3cKNy0i
         NRTq6VUM51VHtAcXm9RmvS7sVOOBtSyzbAR45Cp7YenC5KRCjezQgSI8QuFqGKgJTdhh
         yUuuf9mo9XDv4eW6bm0mxxAbrvGEOQdBCuRsgHxCuIs56oSpbpm4FSXR8oBD4WQufPm+
         AMSexW+TRiKwegFrQHMqaxc4Q0zEv/+K4CT5C6OyKRlwVgwNPCp+XKb4Jq1teWgWqZ2A
         cnwvobw5yX5DhH1YqNeKCmwD9NHVJbtrbupCjgA7+MU6pd0MIRgv5ZFmL7e2FLLhzGde
         pw5A==
X-Gm-Message-State: AJcUukew3cIS9CIUhWWybuIUFPVTk5rkCBMlgZ3oQBpArcUNJx11TPR0
	78UsVPWftbsgFXKWJFvLsnqPvkthl2fWw9BynOpcNANE5zWjBT5g4Ox3Wckw4db1Di8Sy7Jt/5J
	RN7f6tjMEC+fO2CsbHaUD1Qz70Jhjy/IWLL6y6BIvhEBEU2NjJEfQ/VZoF8Ef6mJzhg==
X-Received: by 2002:a37:e20b:: with SMTP id g11mr33032071qki.21.1548989903787;
        Thu, 31 Jan 2019 18:58:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7j5rOaxavpJhO5fpSSUlf+olqTn96SnhhcRdM1h1pRNmu/0ULNLBsP1KTSZ0KQTERYO6fQ
X-Received: by 2002:a37:e20b:: with SMTP id g11mr33032052qki.21.1548989903067;
        Thu, 31 Jan 2019 18:58:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548989903; cv=none;
        d=google.com; s=arc-20160816;
        b=I/YB1lT8LQ5lZsI2GipZH86dIeG2Ko++IFlkuJhc+4dsP+qB7fmhXWtkcGrsi8eclq
         GTqzFNlOsQkmLTtqxbWv7/Ays1elXBZOz8uvbFcwC36sD+P9TkKfXQPz6ImOkEdIKdQa
         2RXAfBrA3nRep66E0JUpjsC8PhEkBmF1DWJI4vXic6BiuGCW3KrNxoqy9fCUg1xkiPxk
         20gHm4B3TaQN8oeD+CFRJtFkTpHs+2klulMW/fofGXkj8crHN/w7kdOjHQxksVzTwMXL
         B+CfG9VYErM79/zxHJKDQSAvxVreyXPNWSS7dtmc01wCpSzT8YO9e57x7uwUqdNC6Ibu
         weDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=HSl4cOeylKJWGZ1gRfcpgzkKgRGUpcow+/PQb70GWe4=;
        b=dntd3Ww0QLDk5Ux2WwE0rk1WlG08dC+Sxfz509WBMCEHtAZZFeDdfl/b0VPXjnmNao
         gzlPFPAcVEN2X87rnGx0BFJQ9q+mJsnG/19Wu7QDma4cpFKdCSrZ3Yl1o7XYwdut5+WD
         3kOHOPPlbJkq8huZRcXOZYuGEQkLXhsJpcLYhHpAzPgW/lMTklBV3Z1z0gEqI5bp7bGX
         hVw/OJCiKLynI0VBlyAjczNMT/56ARodhRotK0onmc8alucgl5Y8RsTgGjoF+EavHR2T
         j43iy864A2GgvoMW/v/ALXL7p35xGF9dHmeaa7IZmYXqM4FOaN7vEyZazEm1758h0g2O
         IxkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=HcVwliAM;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=j63DN7o0;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id s2si1691973qvm.19.2019.01.31.18.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 18:58:23 -0800 (PST)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=HcVwliAM;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=j63DN7o0;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.west.internal (Postfix) with ESMTP id 524622DF3;
	Thu, 31 Jan 2019 21:58:21 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Thu, 31 Jan 2019 21:58:21 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=HSl4cOeylKJWGZ1gRfcpgzkKgRG
	Upcow+/PQb70GWe4=; b=HcVwliAMgEFBku4Jcy/ar1EZHhhVXBxHKogoSpDlCVo
	jz9id7tTOaY2YqB28p3BPdb1Hzo9XDtIyARJH/kwd5ZRQp7N7moYxfPuC37Oy7lS
	Up5Tfs2t7KZzqtMxNr8E4n+JEQQiJ8dSkHnqWS6IK4Dypd4p8hbs9AVLwpIiBdRF
	Yp5c6yY1HizhocF1q7CaKuchG2JcIpNVKUosvajP2bbxDKnyEHWYJ1JujUXDSNt4
	q6BoeTKDBHglSIIDvSy6RJj9pMV4lBk7UMWlTPC/4aC7LW0CY/pQUVhQrFZW4sVu
	G3TSO7oZJKlboVYxkbjhR+YVpM/4nv3jYW02gK5a6lw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=HSl4cO
	eylKJWGZ1gRfcpgzkKgRGUpcow+/PQb70GWe4=; b=j63DN7o0MmyWYmkAsVZJXw
	12a6yCEGIoNtkAsUPmPxnF2mOntwW6Jsiv15m5VVFYBPtJFgY9lTOGRgOEWLh70Z
	fjSITzgZ+mzUzw/llYKC9SUuEgeQG3RyjrJN6VmkSWDg6wnnIbNFq/PD4W7VtBs4
	BS/WexbMMlTrA3htZ84/+TPuHI4BDVEbfq+42s+g6lOn3/NCW8ooAhOTb6ITiDos
	trXXktVhRt12OBLT/nE66RGLfAZZQxSSW0/dV8iwubvn7QdRZOlGEAcpye/+z+oG
	14u8TAGtwy98dyhC2UflTyk6r5tmjU2fxejGia/H1RAmCgwX+9uG1Iqg8zSrWQLw
	==
X-ME-Sender: <xms:zLVTXEFDwTR7FVROIVM-smlfRvBqyNE4HjMQ3PhwKWsHEPDJBVyBhw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeejgdehgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddvjedrudehjeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:zLVTXJdtepDoiYhMQbfG7Su3P_NYowRweoE4Mt9bkJEcIplJANzSfw>
    <xmx:zLVTXKTGf-kOcqWV2TroPEtU4G9NhlC8BfKLXT8eNbf23hdYkO2Gqg>
    <xmx:zLVTXKvfvNjEIT-SiWVkJiwtbTasrrL-lprwmA9HLjDfUyjztrH51w>
    <xmx:zLVTXMzFVRVxHKI_8NqEvcaG_KZXYnlrRBK6En1mDsk59T8Kx45wow>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id E175CE412D;
	Thu, 31 Jan 2019 21:58:19 -0500 (EST)
Date: Fri, 1 Feb 2019 13:58:13 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190201025813.GB29854@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
 <20190201024310.GC26359@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201024310.GC26359@bombadil.infradead.org>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 06:43:10PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> > Currently when displaying /proc/slabinfo if any cache names are too long
> > then the output columns are not aligned.  We could do something fancy to
> > get the maximum length of any cache name in the system or we could just
> > increase the hardcoded width.  Currently it is 17 characters.  Monitors
> > are wide these days so lets just increase it to 30 characters.
> 
> I had a proposal some time ago to turn the slab name from being kmalloced
> to being an inline 16 bytes (with some fun hacks for cgroups).  I think
> that's a better approach than permitting such long names.  For example,
> ext4_allocation_context could be shortened to ext4_alloc_ctx without
> losing any expressivity.
> 
> Let me know if you can't find that and I'll try to dig it up.

Thanks Willy, I'll try and find it and bring it back to life.

Cheers,
Tobin.

