Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373CEC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:47:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D038C2190F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:47:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D038C2190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56BED6B0003; Tue,  2 Jul 2019 18:47:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51DA78E0003; Tue,  2 Jul 2019 18:47:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40C288E0001; Tue,  2 Jul 2019 18:47:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05E306B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:47:34 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v7so173174wrt.6
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:47:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vP1X5jEyDL7f5HaMaCanu2s4UbPdv1ZUzu4c7zA0DWk=;
        b=IBKcWA4OxVg6NdpNh9nbyCVxz84ZE0ziGEkESnBesDrOcDpzE5khF0FWuZmijDDnVO
         dPoImO/SZdWlJ9J4ljBwkATIIMNdmYlce1W5GOtdPQlUpX6dXZq3lOC5wzuwI14x16Nr
         UG6n01rz+EVfd8Sj2qEvEZVvEfzmI1Q4iwjoX5npXD/8LTVCQbmf05j8cCXmbSzttySW
         JnbFzLiCsLbYsuuEppX9bGbiRjql2MrsruGWLl1fzaXUqHa3K9FWAnKyR11dAlaQVkwO
         eQrSVciH3dun1lN0ejXP7YrdbooKSKEbp9sx7S9J5+odgRcXVRdTQFyheMm2YdzKT0iH
         XSDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXoo7dzl4ymS1xe+SrXHcEEoEl7r0dY0tEur5szAu13FyDFjw+n
	uk+WWvcwDL/XkE0IKOh2gU4FRHUbEE9fB4pn04uKPAzNyZ/lCFVgV4VBlf5Wp8ew/MRN1BiHhtV
	zIfl5XBTJqZFUoJB42mrwRLhaNL91cY5apBX/lqf/iTj8FDA0eox4UngCIr24WHSknQ==
X-Received: by 2002:a7b:c444:: with SMTP id l4mr4788063wmi.15.1562107653565;
        Tue, 02 Jul 2019 15:47:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3E8RM4JG8HRk8dK1oxnKAflHlALHf4XfShkNyRGSYX1bmuJaz3mgcfuQkb7IVbdTIPY5X
X-Received: by 2002:a7b:c444:: with SMTP id l4mr4788043wmi.15.1562107652929;
        Tue, 02 Jul 2019 15:47:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562107652; cv=none;
        d=google.com; s=arc-20160816;
        b=phObPAy1xJaK7FFgRPzNz3O26HOeQPrVAudE1yQ9cf0pHpcN2Bz7C/BriCsItt9rL1
         WZbk2mG82UHe//kydkfBHp2GoSE2rx1omspO5y/tl3TvUkAOEMXyMMkrlY+UsKp+6WNk
         BWd8dF9EVyll2SwxIqYGbBJY9lcKScAwbVgtKkShIa8T37Tm5npC6Lwhr3baaavFg5ge
         AvHFgaohW5vOQ3AqLC0tA7f8NTroVScI+bZ6T/m9hP087yyjDpvZHXcBgL7hKpp7XgTM
         g0dj/tIHKjGUbx2E5yIIXmR3NxlMlMejUgjJ/kqaPRDDAExzcps00jEm7SiYRGB+8sDO
         QqdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vP1X5jEyDL7f5HaMaCanu2s4UbPdv1ZUzu4c7zA0DWk=;
        b=WJJY7YoVdkTQwdQnwCAadjQEX9YQsRbaQDqAO8foqfT29jrMQYblZfF6ToE1zMFpdP
         +wINElETlmngQ66UyP7aCRFw2NcHOkW9p51ZJgvG41gO7ITZrBnlW/3zN8kdC40Tl20C
         EmQ+ryxEXtrPNF8derkSYM75eezmlqCPtpFcVPxrdZCfdtHenD82mREl0MvehEtq7D4N
         Lf/0zsqBLK5t/fv+C8f3eriK3T80OO7ukCbhWZwmxPpeEiQs8SqWlfQUttYZuoDiviHB
         Mh8u8nUm0WqLxlErKe25L0Q0Y/I+ov0Tqs3y9vqNh1KR+JI9DfgCciFDds7pplk+1Zyk
         Know==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o137si202884wme.39.2019.07.02.15.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:47:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9F50E68B20; Wed,  3 Jul 2019 00:47:31 +0200 (CEST)
Date: Wed, 3 Jul 2019 00:47:31 +0200
From: Christoph Hellwig <hch@lst.de>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v4
Message-ID: <20190702224731.GA23841@lst.de>
References: <20190701062020.19239-1-hch@lst.de> <20190701082517.GA22461@lst.de> <20190702184201.GO31718@mellanox.com> <2807E5FD2F6FDA4886F6618EAC48510E79DEA747@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79DEA747@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 10:45:34PM +0000, Weiny, Ira wrote:
> > 
> > On Mon, Jul 01, 2019 at 10:25:17AM +0200, Christoph Hellwig wrote:
> > > And I've demonstrated that I can't send patch series..  While this has
> > > all the right patches, it also has the extra patches already in the
> > > hmm tree, and four extra patches I wanted to send once this series is
> > > merged.  I'll give up for now, please use the git url for anything
> > > serious, as it contains the right thing.
> > 
> > Okay, I sorted it all out and temporarily put it here:
> > 
> > https://github.com/jgunthorpe/linux/commits/hmm
> > 
> > Bit involved job:
> > - Took Ira's v4 patch into hmm.git and confirmed it matches what
> >   Andrew has in linux-next after all the fixups
> 
> Looking at the final branch seems good.

Looks good to me as well.

