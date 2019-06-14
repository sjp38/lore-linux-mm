Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EE93C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:39:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21BB720866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:39:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21BB720866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44688E0003; Fri, 14 Jun 2019 02:39:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACC3A8E0002; Fri, 14 Jun 2019 02:39:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E16D8E0003; Fri, 14 Jun 2019 02:39:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFCC8E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:39:55 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g2so648927wrq.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:39:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+HVlVF3JkqO9sIRzIf5H0hPtZfQqOnXYnEHiYtGvvsg=;
        b=heJAERZrPEagnhZ4bZqPuHtxQ0VBTT6BnkVZPv+WO0robR98ovDFqSLfOh270p5rc0
         RV5XYn7q6DPGvNHEqz0NTaXkF4N0s8rsGcF+cQpOZRKrC6SWt5SoJA9/EzxltOLaJe94
         teaqSIYH4ES+GnmUZBxmsoW7ik1yjCqNQgPpadh56sN/NwXwolyew8E0KNzJixyeKYQY
         BlQymvVK9GN4psiBzjyu3PRVoRPCzf1x8BgMiekquUyLEW1tBrrpUWC3/IxFOiFYaWCZ
         K5T+k7MZ1JZ0qe+JqQPY7y9zrW6ky75oIcOEtEq27AoSNsGSqmHUvbEsoPt/8YcK80V/
         gXZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWzV9o1DrkfOqSz6V+VsAsDnkYMWMU4TDQmEejLRwiqQ3Ogo5Vb
	xjmwlVWqePWo7t9ieTngfSKzW2l4vLqNbRZMPSXsFv7K/MKzprH0oC80h8onf0SgJGNItEACxpU
	HcXOT0VTj0/0+L6RohH3wJB47hxKSQff9mfz4i0/vCmncJh3yUzdEQmXd1Uo8Pnj2bg==
X-Received: by 2002:adf:ebc6:: with SMTP id v6mr1529582wrn.222.1560494395017;
        Thu, 13 Jun 2019 23:39:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBS5yKmYyouZ1H0NhGijEwNsOC3WLnkAEEyVKoz1QdfgCNNST/QSZZ8f48Cj9lQPh8XW0y
X-Received: by 2002:adf:ebc6:: with SMTP id v6mr1529544wrn.222.1560494394448;
        Thu, 13 Jun 2019 23:39:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494394; cv=none;
        d=google.com; s=arc-20160816;
        b=W/a4r1jYm+eQSfm7sX3CXvH0Mr0VMUqAXkzd9ZP1ZO6vTbZn/IQGqyF7hOs4lmxG8q
         801whQBdoy3khyf/ZSrN9BJk+kukOaqtI1SrevZFhzgpY4tu9biXsDnQYVv+z7J4spzu
         sl8TrFE+NbcKjcVdwZvG/yTjdqfRQ1u2D74QMgmclxaJZQQhywUt5ofrJiepTsa3E+vo
         PAaDuVhWUibZdmq0et7AGHAE3w+wj+Ny+LMmvfCbbbIt0G/b9+JocxK9kaVffrTONZoJ
         0ZbfGzfNWZSP9+oeFpL9PsR4jPHHmvKPikV1UJKwIJq7tuQb+nwSMf4uTdwxLZA273F4
         3nUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+HVlVF3JkqO9sIRzIf5H0hPtZfQqOnXYnEHiYtGvvsg=;
        b=YVgENJmiQo5Mtm7RF3M56f8nyx1HFuR7k4Fp709MzSKYUMSNltAwFc1QiYmmAyeXtp
         CsUvZMeVT9eIxlOYMFSg0M1mbCsB+TFn1nETXU92j32BK0end99RdkLSxYnP/N/fQ9Ux
         cI+Gd9e8VgOtEBYq0OoX/MHXGpWbA/O00pF2rGApuxlquogCJ8O3EMXXOTHdC0tLvpnz
         RRvURxgPZT32beu9kHRLnhCxiWL7xf0veIhTHVB1PGSbTdAEI1cnpM47iDv94jesHmg5
         vfz06cjCf6/oYtaYDlofxLC83Wv76X5X+Dc6aV/FXWbdv5utTROhqUMpqsLoRnqsZWgA
         2+Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m8si1659748wrn.174.2019.06.13.23.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:39:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D92E768B02; Fri, 14 Jun 2019 08:39:26 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:39:26 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 17/22] mm: remove hmm_devmem_add
Message-ID: <20190614063926.GL7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-18-hch@lst.de> <20190613194239.GX22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613194239.GX22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:42:43PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:43:20AM +0200, Christoph Hellwig wrote:
> > There isn't really much value add in the hmm_devmem_add wrapper.  Just
> > factor out a little helper to find the resource, and otherwise let the
> > driver implement the dev_pagemap_ops directly.
> 
> Was this commit message written when other patches were squashed in
> here? I think the helper this mentions was from an earlier patch

Yes, it was written before a lot of bits were split out.  I've updated
it for the next version.

