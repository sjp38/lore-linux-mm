Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE0C8C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 03:05:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AF30206A1
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 03:05:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RAldJ7DK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AF30206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA2956B0003; Mon, 16 Sep 2019 23:05:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D52D56B0005; Mon, 16 Sep 2019 23:05:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C67D86B0006; Mon, 16 Sep 2019 23:05:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id A033D6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 23:05:04 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2C94E180AD802
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:05:04 +0000 (UTC)
X-FDA: 75942920928.15.ring97_4947d1cca5c22
X-HE-Tag: ring97_4947d1cca5c22
X-Filterd-Recvd-Size: 3537
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:05:03 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id t11so858628plo.0
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:05:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=m/gYUtYqUvo6ZQAhOJa3OteVu4sO8XhLyRb2JBRNr0M=;
        b=RAldJ7DKhfD734MR2BcO0R7ld7KINGa9UXMchKZQS1Qfk29dBkksQkzZLtC4QjlkVp
         AdWlDuuJ0oB6QGeTBxLoWOHaSmCpfJA00KnKg7Wa78k5wCOMTsOH4v8v3XzPslqstQI3
         qAK/JlZIWIdcgwFcbuknA4zLXdlvkH1toP8mQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=m/gYUtYqUvo6ZQAhOJa3OteVu4sO8XhLyRb2JBRNr0M=;
        b=Gt4ZR5bLNy7BUttw0kx0C+2idBl3NuXgIb5IskK5xSD0rXHn5qtg96zgs91ukW7X5e
         xyMw3iV9V4b4KzemzDYlS1jnhAnkZsVXIt3HiNpCBJ7ikGx6/hdlxHXU94HefcOs4Mcc
         GjYY8ZpiXX0p3DTngL9qrj+5siygeov/Dc1OLTWotKgxqKWEGVF9zowe1ITf5+ftaHNI
         M9WFuPGhz6AHXSPmvt14/qBQyrHIiWmCjCUDLsC06w0vrjs/HkLJZd7xgIiKY7h/L2Pm
         tvN42U5edrTgmuMRUGFoJXidkjCVQ5GjWsTRsDi1cCfBTP3Vr+iVLGmKQLRoy3wzN3jh
         THDg==
X-Gm-Message-State: APjAAAUMM1FJ0SXYK/srsybHkawa7Vm8hzpkIx2ASCRBT4TZV9eEFG+S
	FZlXsy5tNaBckgYsnJTSLpSkyQ==
X-Google-Smtp-Source: APXvYqxjPywckFI1ehceUp9hEb5gRERP6bte07a2unP/1biXqWq7kYB4Se2dAnHJcD+Pgxf13MXn2g==
X-Received: by 2002:a17:902:5987:: with SMTP id p7mr1433063pli.242.1568689502384;
        Mon, 16 Sep 2019 20:05:02 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id v9sm457360pfe.1.2019.09.16.20.05.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 20:05:01 -0700 (PDT)
Date: Mon, 16 Sep 2019 20:05:00 -0700
From: Kees Cook <keescook@chromium.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] usercopy: Skip HIGHMEM page checking
Message-ID: <201909162003.FEEAC65@keescook>
References: <201909161431.E69B29A0@keescook>
 <20190917003209.GS29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917003209.GS29434@bombadil.infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 05:32:09PM -0700, Matthew Wilcox wrote:
> On Mon, Sep 16, 2019 at 02:32:56PM -0700, Kees Cook wrote:
> > When running on a system with >512MB RAM with a 32-bit kernel built with:
> > 
> > 	CONFIG_DEBUG_VIRTUAL=y
> > 	CONFIG_HIGHMEM=y
> > 	CONFIG_HARDENED_USERCOPY=y
> > 
> > all execve()s will fail due to argv copying into kmap()ed pages, and on
> > usercopy checking the calls ultimately of virt_to_page() will be looking
> > for "bad" kmap (highmem) pointers due to CONFIG_DEBUG_VIRTUAL=y:
> 
> I don't understand why you want to skip the check.  We must not cross a
> page boundary of a kmapped page.

That requires a new test which hasn't existed before. First I need to
fix the bug, and then we can add a new test and get that into -next,
etc.

-- 
Kees Cook

