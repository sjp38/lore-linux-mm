Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43F09C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:40:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E78CD206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:40:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E78CD206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BB318E0003; Tue, 30 Jul 2019 10:40:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9443B8E0001; Tue, 30 Jul 2019 10:40:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E43B8E0003; Tue, 30 Jul 2019 10:40:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 460258E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:40:27 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i2so31907778wrp.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:40:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LQisq2oAL0oF4ofu3lOSLZRa8tQmd8kwYiMIzUMdod8=;
        b=ndwcAZBl/GiV1cfkOpgKnt1gXQgTQHfdG7cmx8aaIFuSzlIhx02F9uBj0xGq+C2KfN
         kYBLm0AZaTpGRrtv3zBuTcSZw22bKsWvy0ZOmjVlR1RwY30vlvDcaPjTwWRKUirYAh55
         18UHK38+7AQDzJxHF9iJK6zbxMQTjemDvoxzcv4QmyLDZ0EYb6fsia0PwCnL4OwZky8f
         s266heNPfZ49sADbtaZ5H4vow2NFpGiERx+1YFMY/264D6N4ljZNnvDK/J50a2j+LR1s
         z19vQakRB5jwLirdCZFKTr9lt6ivlPTgN0LYFabdvzm9RAXHNFOZbQoaiONzTMfIDI78
         Rm8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVcRl2LRNPGZ5MPMwhKuAddJMZPudgqgfvkMuRNUS4vJfc1T/NZ
	jtWTOA3aXMHSXTj2pvidFzWaJ1bhKX4Yhx/FferoyGPDH+y/ZNzns0Q+B3mbmMPJ+2BA12QQw3F
	XRjhrevz/Xmlvt830DeotblapxO+LPCxxFAk0+XqqbOR37TDe7KlAOn1JE/c+hWVS0g==
X-Received: by 2002:adf:cd81:: with SMTP id q1mr126548490wrj.16.1564497626896;
        Tue, 30 Jul 2019 07:40:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfGCvy8K/hgCybCn9oSZrLcoLF4oUtYBtkHRPssJQaiCuZ6tkzNHAjuFZhuTDxRfFR0KA9
X-Received: by 2002:adf:cd81:: with SMTP id q1mr126548464wrj.16.1564497626242;
        Tue, 30 Jul 2019 07:40:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564497626; cv=none;
        d=google.com; s=arc-20160816;
        b=PjzSHsavM8kF0L0x0pDy3SYjFvkWfMwTgGT19NEKCd/vupaN09mWZzNDODAmeQbkFn
         sECJIdPTnT8E2whZEwKBnTWjOTtb2JrjJ6poWHeyXeepfK+I3Lu0tsIZWgGlVU9M+VyU
         K41O0EquMlcZrl45Zajyt50Xn5hlocLz7/pwwjR3ZqQOmwa31kyd9FiZkd7ZkstLZM+K
         rH8NQCLuSYLBakf8NR3tbta75V5jlgshRpSztbQQy0iTv5nrlRvo/qGh+NBSuMXLB0UJ
         /y5mft5Ud9oX3KI9ZOVO+JtIw31YcfjWAzyWca9RzfGXBvsUQ2k7Ng8WAkh3YzPsEOcL
         yz+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LQisq2oAL0oF4ofu3lOSLZRa8tQmd8kwYiMIzUMdod8=;
        b=knFdIaxpak1JOG6b9q2HQOSfKZW/1DbVJ6Vr+EAp4+bDRhgoqFq5DiCQWYDinSdtwV
         Gbpb4kVioFHIrJrDCzr8if7F/IqZzKoqT5zsFaOKj2p3wAgLA7DTT1DTKAWmkbDktCWj
         5iT6ZGuV6fq56ufhM+fEPj8rJ2jg/GdPkdv+07jTFCfN6YbPVvkX4OQEmq+wgOtjIfR3
         GMclk0UVoSJVd51YuO9M4TLE1R/82tbBYWm+gLHRJxCQfLiE0mwcSFfQ5SfKl/o9z0+I
         oliHAb3lfOfohZQhVP99dlVWqo42ZnLCiVTKPDPYt1DHPUaDnDBnYChD13XbMdLrRDkb
         Wwaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i4si50100753wml.27.2019.07.30.07.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:40:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6570E68AFE; Tue, 30 Jul 2019 16:40:23 +0200 (CEST)
Date: Tue, 30 Jul 2019 16:40:23 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Message-ID: <20190730144023.GA6683@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-4-hch@lst.de> <20190730123554.GD24038@mellanox.com> <20190730131038.GB4566@lst.de> <20190730131454.GG24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730131454.GG24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 01:14:58PM +0000, Jason Gunthorpe wrote:
> I have a patch deleting hmm->mm, so using svmm seems cleaner churn
> here, we could defer and I can fold this into that patch?

Sounds good.  If I don't need to resend feel fee to fold it, otherwise
I'll fix it up.

