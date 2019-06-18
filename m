Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAE2DC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5F942084D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:07:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="le3JAsoW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5F942084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41E7E8E0003; Tue, 18 Jun 2019 01:07:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CEA78E0001; Tue, 18 Jun 2019 01:07:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 295D68E0003; Tue, 18 Jun 2019 01:07:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E500C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:07:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so7121147plp.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:07:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=jnbiF6PM75BR23D0fug4o/KmiVF/a7iA4ZJbUbk0ou8=;
        b=E/Op03eEJfb9hAvHd545BaObQQPxgXSN+1MXGAGIJ85tIY9sIPUGeH1HTlr0akGNnY
         0SXf2a7AHsc2xFs5CqS8qh43u6VcQTT5kMxEvl5YcupHon6utkC2A0A0e5Ez1Ita9aT8
         SX9TLTUy0uXR0p4kwLHTutTSai++hVdzh6j8JYHXdmpWhOKVbdx/wdkGwX9HGd5zeYfm
         YsFwUkLDwuTgWgM3erHhz61dGavqBtBwLHA0glAXK/VmjTdb7LvaN0YBHrO8ztSaswiV
         WqUYFopdNyRJwHaAJRwkNQLtR2bu7Ut94yDTtqBx+xoODskptEqrjZXH8JeV0LM8Fld3
         pRVQ==
X-Gm-Message-State: APjAAAXnzTe+KSmuZMWTgYgX+irCg8aMztfTcKBqZbCY3Nmm6mH+VzKS
	ZYqGAulCBUL/7qfhw+o4trjfms/aY6ItPo6HOIxk0xVYF0rdcZuR6RazEc2SNHr9LrZBV+xVfgy
	AwqbLg1uTeldQ9P7qe4aketGs/xHFYB127A5YGrHqH0jsHagmVire91KZ78UbR9IxVQ==
X-Received: by 2002:a63:4e10:: with SMTP id c16mr887738pgb.214.1560834464340;
        Mon, 17 Jun 2019 22:07:44 -0700 (PDT)
X-Received: by 2002:a63:4e10:: with SMTP id c16mr887701pgb.214.1560834463552;
        Mon, 17 Jun 2019 22:07:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560834463; cv=none;
        d=google.com; s=arc-20160816;
        b=JhmEggQ0NuzI7D2fCEpzvEdL/GDr3zv6j9HzuLBUK0Nz7xojnjA6FjrRwThtnWg0EH
         DCf1+YVE98+rXLoc+ydEOBS8MNFgpwgPZQrBwEMKntxhYyHQ1ivtQ3kI4Oq82GygeNPV
         E7n7oP3G95ROzq3NPPS5Vi/mKEnx3lOMfNUVBGuP8lGbaY9Ls8ACFxIJaLyDG5gMEVP0
         15HxZxupXa2MqFHPZNzfAEUDCYtdsKQrE977xcHnxYv4LZULAC5cExPAxeukyJzLrPui
         /jGWFMQDgFDE7sRNTOPsEF6FSL3+pNXlggYOc4KBKiogCCFYtpRJKU6gFyEhgq2PkjmJ
         GwFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=jnbiF6PM75BR23D0fug4o/KmiVF/a7iA4ZJbUbk0ou8=;
        b=Db9Fodme6EWUqB9gzNBrWYiadRTI8bHnfmy3oI53CNDwv3+8SVuKPQhClNZYvon7qc
         o1QWzhl+/wBdPxrCKqMDemujtAYNt0zkD50c2YixPSaXDDruJxd1oeQqjWrQ7aMfAM/o
         UtB73WmCPDhf3T/vxMKg8NdeUpd5a06V+bqzcsmcHrXVZmdY6uKBVzEMyaEOESDzL2M2
         8Mj1ldWCfpXQEQIZm6KANWgU5VrxAntpfif7zkOjsjuKiEXbNJil1rO9C16z85Yo2Ue3
         Sl38sGrDJLkEFypRaKbFqY3OJVktCCsf55hBEwtY4xxppUehkAWmtizvKZyxq53RHGEk
         FUVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=le3JAsoW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor16126067plo.34.2019.06.17.22.07.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 22:07:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=le3JAsoW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=jnbiF6PM75BR23D0fug4o/KmiVF/a7iA4ZJbUbk0ou8=;
        b=le3JAsoW0dSW819/UcwrgN8EH4ftLCyDsaZAgc7BOsWEPsmUX0qr3b1uAwcH5U9Ht1
         rYLqymUfXJnabzvyyX1WX3d/KTwGSvrT8fnKeDa6nGKyqmaAbpptt0uOXdARKhOgLrZp
         er1miUtYnUqo/19kfQnQOzsv/7Dso4BiTuyW0=
X-Google-Smtp-Source: APXvYqzorbbiv4F/V5ltmPIt8/jvpUkr2OK7EJlOoHFOkJ7aNwm7NJJnDee7dkk++naciFbEgk4+6w==
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr4439628plt.337.1560834463257;
        Mon, 17 Jun 2019 22:07:43 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id l44sm1116128pje.29.2019.06.17.22.07.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 22:07:42 -0700 (PDT)
Date: Mon, 17 Jun 2019 22:07:41 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201906172157.8E88196@keescook>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
 <20190617151027.6422016d74a7dc4c7a562fc6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617151027.6422016d74a7dc4c7a562fc6@linux-foundation.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:10:27PM -0700, Andrew Morton wrote:
> On Mon, 17 Jun 2019 17:10:49 +0200 Alexander Potapenko <glider@google.com> wrote:
> 
> > Slowdown for the new features compared to init_on_free=0,
> > init_on_alloc=0:
> > 
> > hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> > hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)
> 
> Sanity check time.  Is anyone really going to use this?  Seriously,
> honestly, for real?  If "yes" then how did we determine that?

Absolutely! This is expected to be on-by-default on Android and Chrome
OS. And it gives the opportunity for anyone else to use it under distros
too via the boot args. (The init_on_free feature is regularly requested
by folks where memory forensics is included in their thread models.)

As for the performance implications, the request during review was to
do that separately.

> Also, a bit of a nit: "init_on_alloc" and "init_on_free" aren't very
> well chosen names for the boot options - they could refer to any kernel
> object at all, really.  init_pages_on_alloc would be better?  I don't think
> this matters much - the boot options are already chaotic.  But still...

I agree; it's awkward. It covers both the page allocator and the slab
allocator, though, so naming it "page" seems not great. It's part of
a larger effort to auto-initialize all memory (stack auto-init has
been around in a few forms with the Clang support now in Linus's tree
for v5.2), and the feature has kind of ended up with the short name
of "meminit". As this is the "heap" side of "meminit", what about
"meminit.alloc=..." and "meminit.free=..." as alternative straw-men?

-- 
Kees Cook

