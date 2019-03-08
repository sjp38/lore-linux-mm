Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 876B8C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F88208E4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="C+SYhW/9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F88208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7A008E0003; Fri,  8 Mar 2019 10:28:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2AB08E0002; Fri,  8 Mar 2019 10:28:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C18708E0003; Fri,  8 Mar 2019 10:28:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95F698E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 10:28:25 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l11so27901850ywl.18
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 07:28:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=es1/thk3hoUT6a0CwJnVIOFCsRTZM2H+z7e9ODWXPCQ=;
        b=DskMiKCOX9fAA7PwjWDNWvBGngFcF0SU2ld2y0StAwWvV1CwHhAtitWyaQrAjVzxOM
         GqVc7JtD+iZ5BVd/q2L9lLKSfghDRwNp5V95tijF070jMkygaKXBrCwcJSQLHH80mT52
         /6rz1W60PAaTqXuokGw7LNy41uDnh2MB5rshGE4JPXEiXuzY1TZ88vM8QkqS6I/toWI2
         avrZ9B+zKEpRkS0C1Ag1RkJDltvZqH+ZPf+77u5DluPmOMs5xifPvuqUJ1iWJM5WDXxw
         ww+/H6RR0/I1i8LR1HwuBJIYKD8yzyc5VGriD/+T7JYg69FEIKpnbDNJG/dWZsnBvgcc
         CXBQ==
X-Gm-Message-State: APjAAAVJFlV+I6mHPFUk0yOT6Udi9f1jJ4X6/ZfFEHmS5Npc59NBBMC5
	ATAXg4s9qGyTv1g2Y30OLR++f7Dt1Qy3eNtZJPgXrPqmNwyRUJMvl9W8QOIWMkQIu2oE/9yWm9t
	Y1ENVPqe6CgkoObu4jLOO3ZWPI0Boj40zt+Qo8sJqibvAz17fVPTLe9ov6q24aVE2t8gI2XAi1x
	aWS5iuXjx/zJTK3bi0QKKMDnebhIKj83bzWJYUXEyUQfVZZD+yGB0CdrFgKXW0pGSieSLWIjmnv
	+lYeWUNoFWo2gveGdEi+ICCzp2ZSQJp/f1spWNqnGzRSYAsPxIiL4jFpBEbdYSHNdHz3Md+JQAe
	J9/8YS4UACp2PV7xcnMbXefS0KIvMf4SFLiankGggUDirJD6Uak7OCo1/82fc5tVDO982GRQkF8
	W
X-Received: by 2002:a25:7650:: with SMTP id r77mr15964296ybc.206.1552058905035;
        Fri, 08 Mar 2019 07:28:25 -0800 (PST)
X-Received: by 2002:a25:7650:: with SMTP id r77mr15964231ybc.206.1552058904252;
        Fri, 08 Mar 2019 07:28:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552058904; cv=none;
        d=google.com; s=arc-20160816;
        b=alapIgpNfjSdyjETs9Te8zlrxBsP461wKXvK5ODR284e9dYJAsJRePYpLSvpBLagGV
         z2FUUMldFzdZKSYFD6Ksz4E3EBVq8sUlhJ/yQLri1HDzFas4alOAe/sIkxVhVzoVSd87
         iB4NBByEztFPb0SA//Ngyrwm4EwQiBV2FL9pIg/jyG29gX5k+U9bDogv3t89VMuD5lr1
         epz16EuDUODI99x8L3UBzx/R991FE3j/StJM0V/blc7v8BToa5rBqG/UqM9UwP/RAJl7
         trpq23YXnrMND/XTEUDLAq1c+tivSESwc2GwT6Uz8TVC2zkAkoPOTqFkZRBoQ1Qz2ihE
         cPHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=es1/thk3hoUT6a0CwJnVIOFCsRTZM2H+z7e9ODWXPCQ=;
        b=lhTLkJJvZTnoCDMC3T0ySgKx/4XtSS1kzL97/zFvCHDVwoMftJaq9u69qjNePhqjMI
         67n0Y6EqPz4qYAXm7yepj4Wdwue3OgBnTPB3X+LrN6U2bL+HqDWu7hgJp1JstUg2mkAz
         ePvXw6FXEC1ZoZhnLK19Sc1kjIDFp0pOWt8hazlQvAmKS/Cne1oP0VbIjzeLKGp1Skoy
         YTOLKz5mVPrCglhNSvmbCWKHkbVCKS0P/VmV6jlPq/bUjqsp5jUW1z+ueeIwiCzbY/HT
         TOaGEberkWsBO1atKfaVO7rzGSngiLDUpC58JnJVKNwJ1wAeGfOBWTKpZSvNBJY1axzp
         Rklw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="C+SYhW/9";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor1548952ywa.46.2019.03.08.07.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 07:28:24 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="C+SYhW/9";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=es1/thk3hoUT6a0CwJnVIOFCsRTZM2H+z7e9ODWXPCQ=;
        b=C+SYhW/98DRn7mbeftP5Bq2AbuAX7KuViHXSUAvc1IsYNrJ7tOev7hx50tI6RW1RHo
         kNUEaGRnrhS1RtYE4mWKYQ4Zrs9caruA8gdGq6Sm8l+4MvNZuzY0Ou2AwpopygZg1H6B
         EnS+5OlPRw9FsxEIlo+V9zhlIp/YUENj15jQspsBKLtlrTLxu7ep/OdPMhWufTO6xxEU
         KgYT/kgT3YChzT5J5hCXXPeTDshI5at5Fb+Hn+42S2ww9tGyC1teik/rRjM4Yuob0ljI
         w/50Cw2sSqKG5/hLuMDJYDYTCIIi+nZ7BJM5eKCMCvdjOCUFd3EWKH2mZ83bnlqA6TCR
         bALA==
X-Google-Smtp-Source: APXvYqyc0geEIyeysQhQBQA3bHmVi1yYqIl4pBFfAN9RZNmAsvYKpWmEgZ/BboNg9gDxcNVqFB37kg==
X-Received: by 2002:a81:a652:: with SMTP id d79mr15361903ywh.472.1552058903364;
        Fri, 08 Mar 2019 07:28:23 -0800 (PST)
Received: from cisco ([2601:282:901:dd7b:316c:2a55:1ab5:9f1c])
        by smtp.gmail.com with ESMTPSA id d85sm3121148ywd.96.2019.03.08.07.28.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 07:28:22 -0800 (PST)
Date: Fri, 8 Mar 2019 08:28:20 -0700
From: Tycho Andersen <tycho@tycho.ws>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Message-ID: <20190308152820.GB373@cisco>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308041426.16654-3-tobin@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index f9d89c1b5977..754acdb292e4 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
>  	if (!is_root_cache(s))
>  		return 1;
>  
> +	/*
> +	 * s->isolate and s->migrate imply s->ctor so no need to
> +	 * check them explicitly.
> +	 */

Shouldn't this implication go the other way, i.e.
    s->ctor => s->isolate & s->migrate
?

>  	if (s->ctor)
>  		return 1;

Tycho

