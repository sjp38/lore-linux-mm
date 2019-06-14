Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 023A2C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:49:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0DE621721
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:49:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0DE621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 586946B000A; Fri, 14 Jun 2019 05:49:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 535746B000D; Fri, 14 Jun 2019 05:49:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 408616B000E; Fri, 14 Jun 2019 05:49:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAF56B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:49:17 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 21so449512wmj.4
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:49:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BqMmcda2UhZJdwcOwUCwLTwklaJVU7iFg6alpTOEc5c=;
        b=lwiqths9E6MQDajmQiADzpOH+G0Oi9Vh5dIU+tUkiBKut3Y7eiiHoNCBj6S+nHZBa4
         eamJ5n5b5wXjQzwB7nPYmk8QACqtABo+vcuYCV5bT+9PaYy/czOrWQWxyH2VnBvaZUOC
         C2oCz0sgAEU7YpSCTkHaNHOjqa6K8QezMaOIZEJ/EX4dYYwycSuSjykFGf7mSoC569z5
         I6w59sRmnZjvYM67U5OkW4cD7HDUg9EUhnVgznCEuaPj1BGrB5kjoP1D0uOIIPml3EQf
         d3EW2T35n8u5Hr5nbIIyrKw62nQs8FHcb2SadwVJ2L7kGJBZoS7AevHfg1/UZ/dqLyfz
         A/Eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWEG6bNVT/fKpFHJTEjtpXKa+hzVRyLA9nayYlDgQej9MqlA4vK
	tfambFgYMZ5Jiy/Y+PDzpBJavUmh3fi2e23UVmNRziaC2WROtThqrZ9G5yY/DCENJbysoEXda4v
	KunV/1PwxweSSkwUHB1KiHp04nc48PivhgG44YMOwwiJC0VC6ry+5wDSHnn2DrZGjmg==
X-Received: by 2002:a5d:6b03:: with SMTP id v3mr43279437wrw.309.1560505756496;
        Fri, 14 Jun 2019 02:49:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWEsb5C5F9ypzxPrYby2PtSQH4CDboZHFaoLS+uaLVVN255A+aqf0NeyU2Nvf43csAIEAj
X-Received: by 2002:a5d:6b03:: with SMTP id v3mr43279378wrw.309.1560505755806;
        Fri, 14 Jun 2019 02:49:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560505755; cv=none;
        d=google.com; s=arc-20160816;
        b=swcWj6rtreHAYy3d3482akRvvIJrCE5kiI/BSmXZLK+1YZBSOC15L68i2gKldyhYFD
         saK+MS85sWjPUz8RC7fJrsz8T/Tamzv9MaaAzGa1ZlHK+cHDzKpRwjbVTn5FIFfG+s4I
         /ioCASM84ZT2m0KipGjPnqvaw745gbAvfGFblymYa1qPQbaUAA1m1veNoNFhGDe+51DF
         8z60MqO815Lb7aPCCLfvFcOi9oL8328Yvpy8TZrsK/evOtYbE29WAZfhW6YJekmldmQa
         U/9LePdVWd7zJMlXK/O6P73uzcbIfGuK9ZXTZjdplVzky05voD0V6FlQSmRFkh1Hf2uq
         P+Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BqMmcda2UhZJdwcOwUCwLTwklaJVU7iFg6alpTOEc5c=;
        b=TsLkGT2L3CnfNrVSnd/sNRapQ9i7kqXqBmE5RtcE/qJALCFD+6yBBYCFs3ZUp5Zl3G
         /o0QGsioEB0YA9HGI40WQRXFOMspvGFZP37bHrb0Q0tIhHNEK3FZTRnS98xqjcDHd12+
         r0vslVSv315Tk0+k6V46od/JCPc/kizrFtd0gY/sjs+9sdqtxBB0yCGeLu57bkhYe8FU
         1La0VYPlUBSAoOrl2mHbzUpkmsgDcCPjbo+/cmDlAGWskZypxNIBEr92F9LA7JApZM04
         D8s/ceb2vTNr8gkRPL90+lOaj+XxyTcDrHPUBeWNmUyprlxaO/W478EZpjMb5eXnZNsb
         r2qA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t5si2029965wrq.223.2019.06.14.02.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 02:49:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 8158F227A86; Fri, 14 Jun 2019 11:48:48 +0200 (CEST)
Date: Fri, 14 Jun 2019 11:48:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
	Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org, uclinux-dev@uclinux.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
Message-ID: <20190614094847.GI17292@lst.de>
References: <20190610221621.10938-1-hch@lst.de> <20190610221621.10938-3-hch@lst.de> <516c8def-22db-027c-873d-a943454e33af@arm.com> <20190611141841.GA29151@lst.de> <80d01a1d-b6b0-18e8-811c-71af14cba3b9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80d01a1d-b6b0-18e8-811c-71af14cba3b9@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 03:36:53PM +0100, Vladimir Murzin wrote:
> It looks like NOMMU ports tend to define those. For ARM they are:
> 
> #define __swp_type(x)           (0)
> #define __swp_offset(x)         (0)
> #define __swp_entry(typ,off)    ((swp_entry_t) { ((typ) | ((off) << 7)) })
> #define __pte_to_swp_entry(pte) ((swp_entry_t) { pte_val(pte) })
> #define __swp_entry_to_pte(x)   ((pte_t) { (x).val })
> 
> Anyway, I have no strong opinion on which is better :)

It just seems a lot easier to stub out swapops.h rather than providing
stubs in each arch so that inlines which we are never going to use can
build.  I can look into dropping this from the other nommu ports for
the next merge window, though.

