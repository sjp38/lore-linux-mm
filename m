Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 961FBC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5508320863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="yEv9p3Bj";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="sOL+1cid"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5508320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7448E0002; Thu, 31 Jan 2019 21:56:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA7488E0001; Thu, 31 Jan 2019 21:56:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C97048E0002; Thu, 31 Jan 2019 21:56:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1F78E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:56:42 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n95so6165366qte.16
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:56:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kNwOmD4qScWhcKLoOmnQcn0KA61vaBJyRUtJiXQgS1A=;
        b=ftGP/YDJ3qPbnNOjs1/jxQyQCHr1RZUDTArWa0oerD+h7HB8VzSQT3TN39VDUD5qC5
         Ggq3taKr+VkGiUBg0GdHwzTYkLZnS19jSTF3BS/hTtgF+H33XKcnQodzukURm66m0SE2
         ds1ML/z1octb4aE5M7XDtSS96kJF7Cl/QTqjHJ1gdfVhbjFoYM3G1AbAWAwJZb7pw8Cb
         KDxStiV0QHds28yrZ1ox5w+NJXWllmWcMhbjs+EodMFkgX9EtLH4o3UFXB40aHEKRuSa
         /R6+t98LkRunkuaEUp0Cj62Qir6oUdbMZegk6e/HgO5WpMRlPhh1kbgqQhnJ0daCr4fg
         k6og==
X-Gm-Message-State: AJcUukdFLVlvH3qW7KkNmfGEKFY2mkwdfwYv6cVNyFAuTe7zOZ79/2yg
	LHAM1/s1KkPi1W70V+m+TcKKcm64Js3KJRGCQjOZvM66BvaOoW0E6952YnpfvxpP6MFvTaisjoq
	uUjJ2jGE3pmcmsgKhJc1vUnuY1UdylB+x26W358ivH70dyEj5GLtn+MSjUWRjmXkiFw==
X-Received: by 2002:ac8:326a:: with SMTP id y39mr37459367qta.175.1548989802408;
        Thu, 31 Jan 2019 18:56:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7jcBoa77gFXvJfi7MlWLDvIya8D0FdjwoBzU5Euc/wOZ3ZIx0Ad9jTYSUvRw4NTGHvl3Ko
X-Received: by 2002:ac8:326a:: with SMTP id y39mr37459344qta.175.1548989801961;
        Thu, 31 Jan 2019 18:56:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548989801; cv=none;
        d=google.com; s=arc-20160816;
        b=hn4Py8f2dG4wvz+ng6r7cIxEAa+LWL/M1gtb3RDqZ0gVIYHsM57ET2hVN8OxKtmytL
         kMOWNQ0Z+hGlNLK6r4NCVjeMvZJtBofKT3Q5yAQirfDVvklPrpBV79aPnlqcur5z75ib
         UYrznbPNNjCNNfbJHFKUNvcDG431MCR00bJcp7rl6ZGIgYtTNZ8rmF4BYhZGcTrcqw07
         B6dAsoskEu1zQwlSoyACgyW5wHNbCHxCiJnKgNizp6jdWzRkYt8crX26+yBFTNV+prSn
         c69vcZBqa5LTs3HHcLvfHeTwmw0kRv7KnHYqCXsoMKDpdeI1JZ+KgM2GuR27/h0Mkggk
         qvuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=kNwOmD4qScWhcKLoOmnQcn0KA61vaBJyRUtJiXQgS1A=;
        b=BzgHBE7x7Dtn4Gl81Vy1nPqogV/qZKzPjHWnA2+krpr9UGAG5/h1csQUIfdcFBpm+5
         Ener0nduoAf5Nj67yE/zmsN9fmioCtnB5oKlFS/Fxh+cnGmEgv4iHVgFTi11vt7WgPGa
         J26P1Lh8srblsHrEZQ/vLkeW9ZrtuyxfYLmbG63ev8zZYcbn3P481fvnO584Wi3XWGJ4
         WjUsmy0yoZZrMGSTVuJPT9Ix8OyPJoLVNd1uYICqINPRtA1wuHoC3NJLZfk2YEf4J85+
         j7ziFxPDGJY7tRlrq667tzWfJQwpxYgt7+bFcCtaKUpscOCZyzDS9TNa/oGVyDbBYzMY
         Fr7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=yEv9p3Bj;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=sOL+1cid;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id s63si4554574qkd.0.2019.01.31.18.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 18:56:41 -0800 (PST)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=yEv9p3Bj;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=sOL+1cid;
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.west.internal (Postfix) with ESMTP id 267062D61;
	Thu, 31 Jan 2019 21:56:40 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Thu, 31 Jan 2019 21:56:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=kNwOmD4qScWhcKLoOmnQcn0KA61
	vaBJyRUtJiXQgS1A=; b=yEv9p3BjuzdqAum9m4uOVgj2pXI6effC7wjH6eAaNnr
	/iJLfnIIhxNcdfHlcfvaHQ14XhY8/GAll84ONOHN1vr6F93Bajm/mAYe/4J9Ehvb
	It/ho46s8NiA62twpkezuvqJhIZ5L9jhv7zVscn1iHTVaiIsw+jDVgCdrckV3biu
	dsC3hiysafCPQwk+ndZKGq52cRTOx+3tQ20i/xYI51KPbVuuHmZp3zVJ3XhMGh66
	GsCQAfEHfo0zpQLx/V0VSkXx4pTFJp/d8uuBcdgQenOxHa6hedM2oef5ufm8Hv6k
	ksUVbdhtqv79+G/g4bHZhXPWeJHt3UVZlLptcHvK3eg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=kNwOmD
	4qScWhcKLoOmnQcn0KA61vaBJyRUtJiXQgS1A=; b=sOL+1cidlZY7phOYUZTpaV
	TwmT1uZVkxHjgnySKlZ1GAfzyub9D7+4zYFTf4kjwUqZuh/yFOXMKsj+J5auBVXV
	ujDIeioFQN9frmiRJLanT656X0XPlHJDdkMJoXBbXgL47LP+XSrOr8m1P8dk+nFL
	xmK3eb4fb7lLOMQX1M4USCiC6ufrY5FhCih7yze+aXvOPw+iL8VN+Vt9srmKV5Ii
	OGIXhHFWm+mjUWEZotVdl3iISE3DuSfTQ1XzDAgf4KRQ0MiTaURTqm9J14nmhUp+
	b47kHtqK/anIWQ9mMSN7cZUObXJdT452pCV37911MixC6665mDdLCR9Q0D2Xh4Yw
	==
X-ME-Sender: <xms:ZbVTXCwveAejpOnN4YSPSW_3LOSpiwr_0gKkdh7UARdN_Yz3za-EgA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeejgdehgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddvjedrudehjeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:ZbVTXEaiTGimvXDokB5kvVgMpj7F68QJfb5yROcYtOC8k_SU58UOpg>
    <xmx:ZbVTXJ6jrznYyfWiDXb-av3v_eMzLCpbfnySP83dzaUy3d6E_rvExQ>
    <xmx:ZbVTXL47lnwyC-l859hwP6rtrFcZMyztaWbkED207gutD87HNlrEMg>
    <xmx:Z7VTXESw4SjPanit6sZcBbi3pZFyeUtm2G0M_Ke-HV5NH0-BAikIdg>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id CDB7AE412B;
	Thu, 31 Jan 2019 21:56:35 -0500 (EST)
Date: Fri, 1 Feb 2019 13:56:30 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190201025630.GA29854@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
 <20190201005838.GA8082@eros.localdomain>
 <20190131171306.55710d0820deb12282873fab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131171306.55710d0820deb12282873fab@linux-foundation.org>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 05:13:06PM -0800, Andrew Morton wrote:
> On Fri, 1 Feb 2019 11:58:38 +1100 "Tobin C. Harding" <me@tobin.cc> wrote:
> 
> > On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> > [snip]
> > 
> > This applies on top of Linus' tree
> > 
> > 	commit e74c98ca2d6a ('gfs2: Revert "Fix loop in gfs2_rbm_find"')
> > 
> > For this patch I doubt very much that it matters but for the record I
> > can't find mention in MAINTAINERS which tree to base work on for slab
> > patches.  Are mm patches usually based of an mm tree or do you guys work
> > off linux-next?
> 
> It's usually best to work off current mainline and I handle the
> integration stuff.

Awesome, thanks.


	 Tobin

