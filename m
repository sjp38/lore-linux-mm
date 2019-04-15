Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8759BC10F13
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:46:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 501AF2084E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:46:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 501AF2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gondor.apana.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4E186B0003; Sun, 14 Apr 2019 22:46:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFDF26B0006; Sun, 14 Apr 2019 22:46:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C137C6B0007; Sun, 14 Apr 2019 22:46:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4426B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 22:46:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f67so11004169pfh.9
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 19:46:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ToA02dx3ht25pJHA8PBT/UuVIrfdjx8CtVztKUcUUQY=;
        b=BtLZkTpu/PQd/oSxQb3vhV93/uXat7H2+rqHRBLhmF4gNwHskxW21JLSKenKCxZRIQ
         Sw5E8HpEH018K7oAq5x/zIlugaJ7YxugEmvntf4TsNS30fSddCuWZLLdReGOVDE2pZ1a
         fPmL4q0iJML+Jeg8npkQuGTsGvSa1Gjl5kecN/HBrlC6sgCP+/YOSRAsj5quT2coi92d
         u+Fh+CuyuART4f1BDV3WgXFKj46z7zG/SKibT3yJXdy4xTkOMC4uJvQ5OGJqDKxlQI/S
         fBLdvnw2aiiqr24OsUuA1+c0OoTrhYzYRrPMvvvT9JIQCNrr4MTub2mdSMf0+PQma4D2
         Yoag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of herbert@gondor.apana.org.au designates 104.223.48.154 as permitted sender) smtp.mailfrom=herbert@gondor.apana.org.au
X-Gm-Message-State: APjAAAVvIToQY+0W5NNQfppf5PNQZ7UIhKK9BmpTlALokU3WwUJupc1m
	T57hxpzEB0U7la+KBCRrlgmTGYgaspV9K8nfiV36pHsqD/rtb+KHQ1lqb+GFrJ7/2mQODLzowsg
	1eLFNmijbAYZbu9Mfb6CYSmdObtxe88ovwJjCIcfHF3trN2qlpFeBUXAPTD66PjX3YA==
X-Received: by 2002:aa7:800e:: with SMTP id j14mr11301735pfi.157.1555296406209;
        Sun, 14 Apr 2019 19:46:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwElhnqnqBwL0dyvEBNsxnSPOXTzvoZzE64FwM2AA8H5Zi2sKwJdpxUnPLhk76P5t7MyPcL
X-Received: by 2002:aa7:800e:: with SMTP id j14mr11301674pfi.157.1555296405195;
        Sun, 14 Apr 2019 19:46:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555296405; cv=none;
        d=google.com; s=arc-20160816;
        b=OIGgSzneDWZTzS0B66wCcotPZNuiymzUS/u35RMX2+CvXz8EKayOdkG4/3fUHrCq4t
         V3vLniU4Eq8EmnYSTAQ7PZB4JYTIk2ZDmQ1s9gsQrUwjqhnf/dRS26iTAb9nm2Q1yYya
         1dZIM32a87BC2ucBkunEhVZO7SPim52MeAee2MVjz9h0E35MUn00YY7IQ5hKO2WXB5Un
         4R59xMfMiXQ2Us3g7+105ay9JN8do47cUa/7boJbXlskQujWZ6JVJSDWySEtF0A/TeLM
         wysP0JxFxykRV0CHxxCkbwgPVQUocZu85IUSB6VCevQSj64loI6gdz/80Eg8kU3qisX0
         73Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ToA02dx3ht25pJHA8PBT/UuVIrfdjx8CtVztKUcUUQY=;
        b=MXZH9eqDHO7ltTIxMc9AmkdtLEr4c0Ulv1JKM4j2o37mNdFmnlaSQ+MRdDN7TqxwnX
         w5W1qOxHGjSkd0fRm4dKSePbu5jYGjqm8RCeVRuZsrLs7rL0iZBwYwyM+87wpKKXrabB
         DAPf4ln+s8y1EN6Idy1QtqeSTsPXenGadptEgp8GFUv1sfL9Tu3QChqot85mxINpPbZ4
         OXhAzzt4tlaWh39+rxD8A0Ks7ntQxH7cFSIVeBVaR+4G7X597DuPYZee3PK1ILMB9gcb
         UzDn7y+PVVwNQHgzKtUeUpDalKk6lTw7YigoQO66dFjwk9C2+4S+d2GaIFX59Vhx0bUK
         m2nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of herbert@gondor.apana.org.au designates 104.223.48.154 as permitted sender) smtp.mailfrom=herbert@gondor.apana.org.au
Received: from deadmen.hmeau.com (orcrist.hmeau.com. [104.223.48.154])
        by mx.google.com with ESMTPS id ba5si13888034plb.24.2019.04.14.19.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Apr 2019 19:46:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of herbert@gondor.apana.org.au designates 104.223.48.154 as permitted sender) client-ip=104.223.48.154;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of herbert@gondor.apana.org.au designates 104.223.48.154 as permitted sender) smtp.mailfrom=herbert@gondor.apana.org.au
Received: from gondobar.mordor.me.apana.org.au ([192.168.128.4] helo=gondobar)
	by deadmen.hmeau.com with esmtps (Exim 4.89 #2 (Debian))
	id 1hFrdU-0001NG-T0; Mon, 15 Apr 2019 10:46:21 +0800
Received: from herbert by gondobar with local (Exim 4.89)
	(envelope-from <herbert@gondor.apana.org.au>)
	id 1hFrdP-0003On-6f; Mon, 15 Apr 2019 10:46:15 +0800
Date: Mon, 15 Apr 2019 10:46:15 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	linux-crypto <linux-crypto@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
Message-ID: <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190415022412.GA29714@bombadil.infradead.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 14, 2019 at 07:24:12PM -0700, Matthew Wilcox wrote:
> On Thu, Apr 11, 2019 at 01:32:32PM -0700, Kees Cook wrote:
> > > @@ -156,7 +156,8 @@ static int __testmgr_alloc_buf(char *buf[XBUFSIZE], int order)
> > >         int i;
> > >
> > >         for (i = 0; i < XBUFSIZE; i++) {
> > > -               buf[i] = (char *)__get_free_pages(GFP_KERNEL, order);
> > > +               buf[i] = (char *)__get_free_pages(GFP_KERNEL | __GFP_COMP,
> > > +                                                 order);
> > 
> > Is there a reason __GFP_COMP isn't automatically included in all page
> > allocations? (Or rather, it seems like the exception is when things
> > should NOT be considered part of the same allocation, so something
> > like __GFP_SINGLE should exist?.)
> 
> The question is not whether or not things should be considered part of the
> same allocation.  The question is whether the allocation is of a compound
> page or of N consecutive pages.  Now you're asking what the difference is,
> and it's whether you need to be able to be able to call compound_head(),
> compound_order(), PageTail() or use a compound_dtor.  If you don't, then
> you can save some time at allocation & free by not specifying __GFP_COMP.

Thanks for clarifying Matthew.

Eric, this means that we should not use __GFP_COMP here just to
silent what is clearly a broken warning.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

