Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5304C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:23:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A68F02086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:23:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A68F02086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4172D6B0003; Tue, 25 Jun 2019 03:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C85F8E0003; Tue, 25 Jun 2019 03:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 291838E0002; Tue, 25 Jun 2019 03:23:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D111A6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:23:49 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so7513421wru.16
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:23:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FvNRjQG2BPXWuW/pvCSIb3fcN4Eu0B3o2gMIAbG0coQ=;
        b=iFaIeSEXwf8AlyHYhxF396Pu+xcbB2Sh7nJxblnbI8eZX9zS28EIEPtVwYP4RLyXIO
         /883ajEoLgjnkZ4J3Ec3n6KLqWRIXjtYXvs3Swhdg9UZVlPp91lA12NdTy0hSTsWQHyw
         bSdVEiPEaVE1pb/I0mM/pl5MAyX69dt5iyZv1aAJQhrQZ7ei0PGNRPBxNKjZBQEFD0OH
         QVXDHEfE/UiICt+AgYjNjWW6mdJ1ngq4D0ct14sRc7ihFJ3ASDS2IbJPIpB6TKPb5swh
         6nujulNRRG5Fpskx2xgDCspjy/FFsrXE/R557FGadHHNiY4S/oGsMJ1/aHDix8717llp
         AOgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUiZ/dGs1xepieopgiX1fUCisxKVLj3gs3+avihzzDpCXWJdw6l
	pTffa2V3+FTConeQXsZnlcnUkA11IGSGY7zX0/48SXfERuCk0LUROgFzScDNpEylR65iTUbrANn
	tWNJPcyf1RoqNUVel7YxJ5SnmXGR/l85VhFmlVha5L7wbUlL05fuU0D5C2yCeVsH2Xg==
X-Received: by 2002:a05:600c:303:: with SMTP id q3mr19113620wmd.130.1561447429441;
        Tue, 25 Jun 2019 00:23:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSONYqiYlElJSIZdjqqEtQh7OwqXpGpLF+2622pVt8KOb/geyuoYrmSBXec4CqkzvD3xXQ
X-Received: by 2002:a05:600c:303:: with SMTP id q3mr19113586wmd.130.1561447428625;
        Tue, 25 Jun 2019 00:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561447428; cv=none;
        d=google.com; s=arc-20160816;
        b=asteVPtHyg80tU3zbRD7DstTMKOYBirhZ/DH9rSUQhQmt2JXSZbXVH29eiTgDcUgm2
         4st/70034o50orc9R1ek8HDFMUqZRH54A6mQnQvJLAuNVbVfEcYUYiMe4E/srOa3SvFM
         7JaFFebzPRTRRBKG/f1L3XsMk/Avvgww3dv7ZAN20Bgg+H/a2rupogdQUtQCUXr/SW5s
         oiZGhtqWPWrILKNGc6nf0TiE/tQS3t/KTiCYJua0ASBSAX8GX1cizYLdD7BFoMQm5SYF
         Gjx6yC1gu5AhtTXAm/1O7mLUoRHhyS4PuxWasUc0TuvEjVbghYjZaN+PWUQ1LDlknbCg
         WiXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FvNRjQG2BPXWuW/pvCSIb3fcN4Eu0B3o2gMIAbG0coQ=;
        b=i7BLyUmBS63CjjKrSmgjGGcF86pIQaiQ/CBXSGLl7m+lN+2LcOeozrObGpYN/TVHWi
         cnGKrXxZWAAqrDLGzaGpqh6Rh0JVox4fZvEwOFv5k/A/oeXUC2gnyXjkNMwZLlLMC/gU
         3X5c6xfQJVfWVHrFEcU4dIMVrzIbLChr3+357v7udxpnDN/DYvbRamGj5EyFpzroSARF
         NnfVYcGkYo7UVoy4i44pwMWqzonkaYsklq9PzOYr6s8RYWNxbXPSGlMyyc49WVl8GoRM
         o8GI0UAoNj04yk3wAFDRVWak4UIOUJ7EYalIIDI/o5a7yvcXyTOdrywD5cBJEW7mU9v7
         y++w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x21si1381027wmh.99.2019.06.25.00.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:23:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id EDBB068B02; Tue, 25 Jun 2019 09:23:17 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:23:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190625072317.GC30350@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de> <20190620191733.GH12083@dhcp22.suse.cz> <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 11:24:48AM -0700, Dan Williams wrote:
> I asked for this simply because it was not exported historically. In
> general I want to establish explicit export-type criteria so the
> community can spend less time debating when to use EXPORT_SYMBOL_GPL
> [1].
> 
> The thought in this instance is that it is not historically exported
> to modules and it is safer from a maintenance perspective to start
> with GPL-only for new symbols in case we don't want to maintain that
> interface long-term for out-of-tree modules.
> 
> Yes, we always reserve the right to remove / change interfaces
> regardless of the export type, but history has shown that external
> pressure to keep an interface stable (contrary to
> Documentation/process/stable-api-nonsense.rst) tends to be less for
> GPL-only exports.

Fully agreed.  In the end the decision is with the MM maintainers,
though, although I'd prefer to keep it as in this series.

