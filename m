Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A2C0C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F0B72089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:09:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F0B72089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D596F8E0005; Tue, 30 Jul 2019 09:09:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D09998E0001; Tue, 30 Jul 2019 09:09:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8FC8E0005; Tue, 30 Jul 2019 09:09:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB748E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:09:48 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id h8so31801240wrb.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:09:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P9gGesMST2/7dn2UE8/oGBCee+OWxFLWjQ44x+/UaLg=;
        b=NMEdhGSt5+S3NZR8k/Bx5I8ovUT9D4r1h5NsWlMesTTfIvSrYNH1+8uFR/5hcnaARK
         B0+htjAafuMzLatSWpDtPqdg3+Hj7an8gtdDNRHUYPTzvm/jbNX1Jat86wDrtityRKna
         +wyqi1+gaiUEnjHeJBDj8H500uccN12471oPmngJh6s24CjNYGp6sVBTPuIMqEebvg4j
         tR4Sl4W4JQnOo6tQppN9sUEL5+biWcJYDYB7l2H6Z63PSrVo9MbfP/b1t/c2SkFU3mfH
         r2Qmxjkacwthnmm0mYXcwoEWLtkWYCIBj6JPGumbAa3TtJqGnO61Z706ZEpbJjPd59EL
         EvMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWW/oLlnGoQsPWHdS5IiKqpjbzMneVX5pPGsROUC+8eww4LJ8OK
	EziwjzjoTEci8XSIoJvyMdF9XfGNxdFOnEjz67CDKpSrYmUxGo8iY+FDruuuIeLSiXvANmIT1iE
	S0gnhyKaVyQ/yOvAYbOO1qLFvJw0iHYzVi0P1erGXm/Xtr6k1hJ+BIey4wdU1k/rIhA==
X-Received: by 2002:a5d:51c7:: with SMTP id n7mr46980620wrv.326.1564492188171;
        Tue, 30 Jul 2019 06:09:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHfljnXJXnpjVQ/S9ZFjdGkYD22pg61JfjVd6kN8b/eW38k0IP40Hocl1WmcqTNBTzfhUd
X-Received: by 2002:a5d:51c7:: with SMTP id n7mr46980581wrv.326.1564492187585;
        Tue, 30 Jul 2019 06:09:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564492187; cv=none;
        d=google.com; s=arc-20160816;
        b=X/fLIRZxUy/cxGQLHTQTSBIZAYGUnz8IZYPfIEW+y1x/UXz8/KIV4kirLEcxDhwDst
         Ohc+3bo1FIp34EbpTV/S6N7SwjFGmy1c8UX74V+DJtCStEaExaM+Fv43/QDzWbZWJif8
         4F2AZsbhjk+6dkYbTsvW/rZsHGJQtYK6gYi2fGKmseX1PQeJcEaDDTobk3YD1iBMG7ou
         Q5T1U/oGiOnlD3Ff9OddBcODLXr0rVR9+8/Vq0NZCO7Ye7p9XcjCy3MK+BpUPTxf+8ak
         aFKO5PyydkfiSvDlZUjOP8tPs1J+ljz2Lof40sVcDGd/g4hVzo4LB/Lcvz6c7YpM3rPX
         cGrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P9gGesMST2/7dn2UE8/oGBCee+OWxFLWjQ44x+/UaLg=;
        b=zKFrqokl/rJy9bubkP3ZcET82vi6oi9f2MTscyrZHf1UesESC/B2lbf5vOX5r3SS8f
         nQ08jaysvs3R5HK28A1aGbjQJaHuX/y6KbrQWBjNG4rNr5qNtBHpzn10Pbq8qKtzo+KU
         GZbPpluRW+qx0Zv0OdKHW2orGHNy7wjwJl/6L04EXTsXSEHpN1+3LiDt14wqjbLG5uwD
         y24UU5u823O5HGNV+pvcKTEGlyQlLEpeDSCnTxxCS97GJarDXdCZEWJCK8tfNlyrlgYh
         VO1yiJw14WDqgYdyx3RZohix0QQljlyI4nOYmewrdgqWmA4kQZXYQ9YSt7h/1vCwxAIG
         Neaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l13si1906735wmi.92.2019.07.30.06.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 06:09:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B0B98227A8A; Tue, 30 Jul 2019 15:09:44 +0200 (CEST)
Date: Tue, 30 Jul 2019 15:09:44 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: turn the hmm migrate_vma upside down
Message-ID: <20190730130944.GA4566@lst.de>
References: <20190729142843.22320-1-hch@lst.de> <20190730123218.GA24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730123218.GA24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:32:24PM +0000, Jason Gunthorpe wrote:
> Does this only impact hmm users, or does migrate.c have a broader
> usage?

migrate.c really contains two things:  the traditional page migration
code implementing aops ->migrate semantics, and migrate_vma and its
callbacks.  The first part is broader, the second part is hmm specific
(and should probably have been in a file of its own, given that it is
guarded off CONFIG_MIGRATE_VMA_HELPER).  This series only touched the
latter part.

