Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C119AC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:25:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47696214AF
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:25:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Wmn42cCj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47696214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A64396B0003; Sat, 29 Jun 2019 10:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3AFF8E0003; Sat, 29 Jun 2019 10:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92A018E0002; Sat, 29 Jun 2019 10:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f78.google.com (mail-wr1-f78.google.com [209.85.221.78])
	by kanga.kvack.org (Postfix) with ESMTP id 47DFB6B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 10:25:30 -0400 (EDT)
Received: by mail-wr1-f78.google.com with SMTP id e8so3641316wrw.15
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 07:25:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tSfTfCg1RYrQS9+orWf92BVXcSGyjMupz270+2KJ+Us=;
        b=oJ/+101XceJX3awrKL7EC1lcJv7nN2aSnpTwmahrxWIRrLfgpgk5I0XOoDuQMbUNM7
         dGLApM/wdxMPoMJUFCyUhpsFRrWlgRRe2gXgdBjlNSMw7eQLfoxntFVMzO/wsVZXjri7
         lj6IFtiQhD8Zx9NqeoQW+TOxmiad0Mvxal9mwoxbYRQVlheuI8kQxSgnv7t6SFLwZ0YO
         HQR1HqjAQdUxcLeCn/s0Tf3pll2dX/jA3gxEhJeOekP9mZf8/RTAZUK+XEyd90Xggk21
         6+GlU1qO9GA00zK43yWpaY35fsBNg7rk3yaxu5E9WQhDJ+9n0T7sk7dcCPg6HMXdDYzh
         4cPQ==
X-Gm-Message-State: APjAAAVnEuvmWpWfqeNg6Tsvk44VmFL7Wh1aug3XspR09Fm94ZHWZnm3
	BLWHMC6ubLD/x+aSazHIw1UPSlAZazA+gDiSmsGPCHIiXJd+Jw9lgVBtqGsi9RA5l4RIYX1Db7e
	6QE4+WUbgSDZRvcyR/XWJNeS4WZiEGVGfZRYWC2E1dygQvRf/r4EuezYO8BAKhexGaw==
X-Received: by 2002:a5d:6a90:: with SMTP id s16mr12338826wru.288.1561818329630;
        Sat, 29 Jun 2019 07:25:29 -0700 (PDT)
X-Received: by 2002:a5d:6a90:: with SMTP id s16mr12338797wru.288.1561818328788;
        Sat, 29 Jun 2019 07:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561818328; cv=none;
        d=google.com; s=arc-20160816;
        b=YDM+NkRYTo0x86BKFuFY3YlLiPAfftMJ4H2hMv8kLNGOq2rV9gEkla52r45llxgpD0
         n7nLTKVDDHUqYcxC4qjvabdUII2xMDnE+kjXQnsDN0fv2XvJj/tWbMDt6ZsXTsLF+JP1
         1BNG9SbCsm3eHagoj2hm+Y16RBCnHIbuMWWO3RWBfMpVZTDnyiyzOsgXpCrilpPhV/kg
         wEcRC5d76qHGYA6Jp+GvESLzpCSkVyfZypyVtT2XVJ80MS4f/KRZPzaMmjiDWEuyikUm
         IFWPWmkcg95aoCbc3ljbm46DfqYDhy8cfziCEzEQlpgv91ogYUb02Dc6zNlhHQEdt0j6
         ei1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tSfTfCg1RYrQS9+orWf92BVXcSGyjMupz270+2KJ+Us=;
        b=kgDxfY+I3AhlP04pCeaQ/aVs/5/0Ac6+9MVVDGuSflqck/c8JIKtLWbMKfdBz3hXTR
         EUrGQtUK80/iQrUSiqnDugQJvKHonDR2cPBpSbZBPLjqjTRUshXzP+7Os0o7/ueBdHaF
         flsr1ZxIi7Q+b2vrPYSOx4izEqe2ZD+jMDjG+kX3CJyd/+hwZJlHwJM2A82GHqGpNkiB
         SWbGBeEcgszNyu8H270ikfyUM8+bKlY27YMLgcKceghBvkz5x/oRFj5gNTG+KfrCbIRk
         uXascu3O8aKwE6Egoksd9xfvDdxf7OhunNtu1sO+4439B4rnoY1hXEPuIH73lwkp/JZS
         o2LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Wmn42cCj;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z139sor2874014wmc.25.2019.06.29.07.25.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Jun 2019 07:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Wmn42cCj;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tSfTfCg1RYrQS9+orWf92BVXcSGyjMupz270+2KJ+Us=;
        b=Wmn42cCjIZF370922nlT8XBZNT0vFC3qdUoivrJz5yLafRIjdx1Vw+bUvno+QUBVO5
         oMyQcmwqGx4DE3Y07CmSTM0IATWqZAW8kgg+hDEKwh+1CP4NznlAWonwVsCaGpQLaVCV
         I2vA/VdkUZjqS9WvauRGJBO3Xjdwe01bpXzqQP8wAMh3LJ6yI1E5Z9SfpRw+TuNVA5cx
         Mol2Xo2HUenKPsAtO6b1Hxjmm06+PdB0ii0cFoQihuSTWnRJjwjpf6NZuH7lsl3/21RK
         LnPOrpaBytkjll+vsC5zrv5VKacw2e2sTlF82+ldUSC/dM1uFOjAFEnxgQGkqlBXSG7l
         +TOw==
X-Google-Smtp-Source: APXvYqzYjeGlAIXCK0Otnr3tBdPOmwP6gFHgUXBBLaR5nRWD1D7mhQsGKJ7ZXMMjG4yeTA5UDqjZKg==
X-Received: by 2002:a1c:dc46:: with SMTP id t67mr9957034wmg.159.1561818328264;
        Sat, 29 Jun 2019 07:25:28 -0700 (PDT)
Received: from avx2 ([46.53.248.49])
        by smtp.gmail.com with ESMTPSA id g123sm3503855wme.12.2019.06.29.07.25.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 07:25:27 -0700 (PDT)
Date: Sat, 29 Jun 2019 17:25:10 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Shyam Saini <shyam.saini@amarulasolutions.com>,
	kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org,
	keescook@chromium.org, linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org, intel-gvt-dev@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	netdev@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>,
	devel@lists.orangefs.org, linux-mm@kvack.org,
	linux-sctp@vger.kernel.org, bpf@vger.kernel.org,
	kvm@vger.kernel.org, mayhs11saini@gmail.com
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Message-ID: <20190629142510.GA10629@avx2>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
 <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 03:00:10PM -0600, Andreas Dilger wrote:
> On Jun 11, 2019, at 2:48 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > On Wed, 12 Jun 2019 01:08:36 +0530 Shyam Saini <shyam.saini@amarulasolutions.com> wrote:

> I did a check, and FIELD_SIZEOF() is used about 350x, while sizeof_field()
> is about 30x, and SIZEOF_FIELD() is only about 5x.
> 
> That said, I'm much more in favour of "sizeof_field()" or "sizeof_member()"
> than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
> which it is closely related, but is also closer to the original "sizeof()".
> 
> Since this is a rather trivial change, it can be split into a number of
> patches to get approval/landing via subsystem maintainers, and there is no
> huge urgency to remove the original macros until the users are gone.  It
> would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
> they don't gain more users, and the remaining FIELD_SIZEOF() users can be
> whittled away as the patches come through the maintainer trees.

The signature should be

	sizeof_member(T, m)

it is proper English,
it is lowercase, so is easier to type,
it uses standard term (member, not field),
it blends in with standard "sizeof" operator,

