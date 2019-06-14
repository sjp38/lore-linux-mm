Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BE2DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D7A20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D7A20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D876B8E0003; Fri, 14 Jun 2019 02:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37BB8E0002; Fri, 14 Jun 2019 02:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4D278E0003; Fri, 14 Jun 2019 02:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2758E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:47:45 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id p16so213050wmi.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZRvQKZgbHP1/3FnySKYs/gT8crcA9dQWhMJPaikEnAg=;
        b=QVSN5agRPiIXnIHCYixXrfMcGxggsoPbQ20V0wh8qzLrdL5S+hKNqqAUEpSzn6/Nil
         s4MltiHSocRDZ9sJ0FpMUx63bcoBlnC6rj1SO9ioJPtOqT5l9ALV55cngCaoxpOjdN5g
         E73WiSlNz+gZ7liE2Atg5LWVdW48nYk9etProPtRT//6G42y1kaAaO+u+9qAZLWOiN4W
         JzQlL7fifOr9DbL9eWym8OYcBwFCF1bDH4+OAOzL1z7MsgSME9BYJTFMrU7t4XYdHGKb
         h+9B81VTeDoQmOjUkCfPzvYZIPM9lN3CKB6wVezOIHjNgOBoS61AOeUDI+7K0NbaLQS0
         i8UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUOgLXUTbfhK9QT3Wu0d6si86v4mlV6JB1kfCHJiiL3LM1e0IYH
	3lVlL24Tp3GTUxnEUJSVmOgGTKMjvVgjwrbFxdO1ccBs061WnsdWcAdG2zE7cmTVYrkR2YLQvY6
	YHWcuz8UuRnsxlXCF2hwSWqU18m3n94ESf5y0VnkGicKCbgGYpi1mIAz4jKfxuDKwpA==
X-Received: by 2002:a5d:484e:: with SMTP id n14mr38427324wrs.348.1560494865045;
        Thu, 13 Jun 2019 23:47:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwo3GVX107kwIjQsxOlybtqPMG3UJsQ/twLKIv0liTqO57P64mRcI+8cxb0qHFBe6KWE65r
X-Received: by 2002:a5d:484e:: with SMTP id n14mr38427281wrs.348.1560494864409;
        Thu, 13 Jun 2019 23:47:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494864; cv=none;
        d=google.com; s=arc-20160816;
        b=c1f4WMbd8/I0nrVYjbuyRCnYQRUV4ocja9jPB04QzlfercmfHz7fG8lTykAK9AXJlI
         O6G4xEcFTKZgh0wr9I7M+XkXFgwUIs3TGfI1+s08E6Tw2byf0r16xV3yn8qFfU3cAX79
         Cq4Hf2cNOh14c8083D8s4H1nQXEw4o6nEPdJBRBK6n/ksogU1ufSeZl5GENUPzesc/sY
         54F7iD8mO2zpMZzyNm4aZGVBp0dCY7cO2ZhDHg9zCqoWHARAa2iHxlUj/yBHC2ULUA1V
         DpBir9qSQbbZRr46CevE83ylOgojU80OcZdhV2vFTtK5cx/Jwac9dtqHTNkE1Bu8/gsz
         ik6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZRvQKZgbHP1/3FnySKYs/gT8crcA9dQWhMJPaikEnAg=;
        b=jQ2rICgGYxNfqpmok/E96isb4yKJq3pkF5hR7hBtSc8FgCBkUIgf1n57PrYfb4h5mr
         RbdS4b8M2wf8vQ3o2bt9TVv+GylsD05TBkD+kbzlkApWwVjMLXz5+Knu4ZkWufwdWvZ1
         cfJIO3/teHuEGQP5RyTNXBFFfEifRs8CswVwEDyo+A06lYJqlZzd+vSPE5Hq7kt4caeI
         6Rx0CpMasgN/s1aw0O1knE02C5hM+t66x1p8g5f7Ujm2WCWNVioegJirplLtSAE1OOBR
         5z1GfZYdrlkuyHDgxrwZBEETLRmYjONJQXkgHypPOjym1jVyFb/XIg3oGTDxArNQ9cG1
         Zm3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w13si1230636wmk.22.2019.06.13.23.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:47:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id CC60468B02; Fri, 14 Jun 2019 08:47:16 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:47:16 +0200
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
Subject: Re: [PATCH 21/22] mm: remove the HMM config option
Message-ID: <20190614064716.GN7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-22-hch@lst.de> <20190613200150.GB22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613200150.GB22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:01:55PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:43:24AM +0200, Christoph Hellwig wrote:
> > All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
> > depend on it instead of the mix of a dummy dependency symbol plus the
> > actually selected one.  Drop various odd dependencies, as the code is
> > pretty portable.
> 
> I don't really know, but I thought this needed the arch restriction
> for the same reason get_user_pages has various unique arch specific
> implementations (it does seem to have some open coded GUP like thing)?
> 
> I was hoping we could do this after your common gup series? But sooner
> is better too.

Ok, I've added the arch and 64-bit dependency back in for now.  It does
not look proper to me, and is certainly underdocumented, but the whole
pagetable walking code will need a lot of love eventually anyway, and
the Kconfig stuff for it can be done properly then.

