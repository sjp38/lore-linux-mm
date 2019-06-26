Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B575EC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D57208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:50:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D57208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AE198E0003; Wed, 26 Jun 2019 01:50:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15D0B8E0002; Wed, 26 Jun 2019 01:50:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04D628E0003; Wed, 26 Jun 2019 01:50:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C17C38E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:50:07 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id n8so523374wrx.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m0Ce8Hs4EDtaDCwOvGktpreYQ6KM4B8AhqtkoKgoPQQ=;
        b=s83zCobZWLUPg6UMadiTumiUwyXBY3me5bIbkekjnkq1ONz7dhvBNmKn87dgM3SJ+v
         LhpK0uldvkGfHX2MMhU+cUoNmbG5f+kMeIDZnYQj7AXs0UHg5w5+KzD2QOhGJvp+Vpa/
         vFegIxOEZQSRSWDUBSKMkyO2SIa24uhb+F0pdrZgfJJ2ySraWm6ggu9N5aEcvU6lWbsC
         NlkdreXBE2wxH3fg2MFh3kXleuZNgcNFe0fbfAcaER+FQntbXt6UP9rPO0umqspe0a9W
         gc9ECfaOXN1QYb1ln4VWbQAJPF9i6jwZVUr9g685w03n7soB5/lURUqGQMD74xtDeI5m
         7HVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWWfRGQLusvt7DKhyNp0yiNfDh4GpZJ2h3gXBlvOlYKJ6an34C7
	/hNApzXWl/2qHaGSLcfwmX//mT0YCwvihAEzYsyJN0QcZkZwP/1a59L3lv4s6MRT6b5+ajF1wik
	1gX8uOXuHB5wMBZ2pnPmMuGvxGAmKKvi9KG5GUEdGE55GzVVB3M8DfKk58LMn2SyyXQ==
X-Received: by 2002:adf:ec0f:: with SMTP id x15mr1779832wrn.165.1561528207343;
        Tue, 25 Jun 2019 22:50:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzP1qgevi4XvZZYRrv/or8gT7iX/QgASaferu8IO/A1niFPiBpGpf2AT7lOW3QUZlB/3js9
X-Received: by 2002:adf:ec0f:: with SMTP id x15mr1779762wrn.165.1561528206716;
        Tue, 25 Jun 2019 22:50:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561528206; cv=none;
        d=google.com; s=arc-20160816;
        b=JpOP64nQ4fS4gATOs+E/UnvzpcGjulkf66NcZ1HKRAu3cqulPuwC4FgNdGLYB4hZXt
         Qr2cRCJa1ubLlu4CJM9k4TJdqsY9FYOQcuMbGkCl5DPLt73k49A7LDVIFBbLk1OYAdp7
         qF7dqn9W08WB5mpk9neMCSSwHh9GrIz3NyCg83emrGyyzHfHMBvhWFac+tnAF2mnmkWY
         /4Jdh6mU5POV74+o3pXk6/4oNnH9k7Xcfrd465urJq1t01lxZQ+RdaUbF08UI6Ej4k0j
         EkRnpxRo2dJLow2QfUOD9JrUii8F85ddy8d8I9D61o2CqPs8nX3IdGPirH3P3YIMmPwC
         k7ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m0Ce8Hs4EDtaDCwOvGktpreYQ6KM4B8AhqtkoKgoPQQ=;
        b=NJBeeMuHx2jxYpqGaMV1f1uJMRE8N19MtSi4C6vXRH49Sqm72qZzgEQ63SgiYnR8/d
         G0o0nPtT4RSBuANAije0DepNoQhBE5qA43F/6w3K8m8a1Zm0kZ9US/Sl2SA6CQ7mEObD
         +lXW39XTXlAEgfGkvWAew5uurYSasPTvZe3Gf1ZlAN8ZNoBJM2g0fPTXhYzVSTxpTTfq
         ekmUzR8ADL5teaBzCaFIOkDbS0YZu0gbylF8gDp9IbQdkFKp0ZPzk9WwCBgzIHYFzvpn
         QiCQG+PfjHeZzZkfMqDS5j4Na290DPiHAANmvwmdsQ0hLWgDduZF4Dsvq8sphlqJdTCr
         00QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f6si700708wmf.170.2019.06.25.22.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 22:50:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 1443D68B05; Wed, 26 Jun 2019 07:49:35 +0200 (CEST)
Date: Wed, 26 Jun 2019 07:49:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 14/16] mm: move the powerpc hugepd code to mm/gup.c
Message-ID: <20190626054934.GA23547@lst.de>
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-15-hch@lst.de> <20190625123757.ec7e886747bb5a9bc364107d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625123757.ec7e886747bb5a9bc364107d@linux-foundation.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:37:57PM -0700, Andrew Morton wrote:
> On Tue, 25 Jun 2019 16:37:13 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > +static int gup_huge_pd(hugepd_t hugepd
> 
> Naming nitlet: we have hugepd and we also have huge_pd.  We have
> hugepte and we also have huge_pte.  It make things a bit hard to
> remember and it would be nice to make it all consistent sometime.
> 
> We're consistent with huge_pud and almost consistent with huge_pmd.
> 
> To be fully consistent I guess we should make all of them have the
> underscore.  Or not have it.  

Either way is fine with me.  Feel free to fix up per your preference.

