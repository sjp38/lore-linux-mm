Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8387C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2751208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:59:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2751208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F66F8E0005; Tue, 25 Jun 2019 07:59:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6668E0002; Tue, 25 Jun 2019 07:59:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396888E0005; Tue, 25 Jun 2019 07:59:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3C268E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:59:53 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b1so7842751wru.4
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lE+7liccnRpiIpgLdMxWmMKoiV3j2oVjRzHS5uLvmvY=;
        b=KbECLspDmF6X7vmyFH1i0HnVfLMkdC5L2hyid+i4+LIFB+ryDGJ8NDIV2KcaHRTdr0
         INT7SBrGJhpShVd4se3wSZDx474m+1TABU+OBp7ybc1wkhoXRJQv16R2dfC2KjKOFvM0
         UyN914zO26hHO8epgwD+hTHoxypzgYX4eG2ALsjN3UCAfDFAXvIdolIyEb/2j1dEJjwH
         /+Q0vFIDtpcgez2wF9iQ1noorlmw0Wx9qbdB5XOZRzxenKHmwGDirw8ssFJmElnUwH5O
         Euv1YKQej4o0npcJLHG7XttZbTk2lo/Z6JP9teF+IETr+TopJf5m/623M2yKzL7Ii+Of
         7QlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVIqpfXP3UDmWBu/Kw11eJmUAHKw9vJQOMSqRRggl37MtKtRqdV
	cQAuCY04dMm0Uz56pqxqueM80UcAEiK928u62kT6tcvA9AAXHL2g5K+nHKTM6YrukxRfhZ0n9eF
	TbBUAJk1j1EmrZ3UV6xjakuwOAN0eIA3HUzYnoge3bYUCQJThyAZAW9xe9i4HO2s7Og==
X-Received: by 2002:adf:dbd2:: with SMTP id e18mr688035wrj.110.1561463993523;
        Tue, 25 Jun 2019 04:59:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvJzAYGM70Vrd55YCx3TluQeQhB04guD+FELc9+OkssJKqOisjy8V0wW55g8reJoqFF07N
X-Received: by 2002:adf:dbd2:: with SMTP id e18mr688004wrj.110.1561463992870;
        Tue, 25 Jun 2019 04:59:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561463992; cv=none;
        d=google.com; s=arc-20160816;
        b=syPVm2k7+ERG5FA5y3drQKLFgsi8l8IhzF35mxKq5y6pZ0Qoj7Os+K7hUYedyH4yka
         2LStNJO/dTQGOqsiibParuAoMUDBTSGdqZ3lxlYxQA0IuyLL55zC6neL3ag7p/JEYAlA
         +iWjioG5hs2AYWYfd/F92PqOuJfMJysctJ1Mswcp5RYDphmOg4+Qd/n0H8g+wGumnKLr
         cJx/01zG7gHb4NGLzb/0Z08HQZU+ampa1jLOAIDFmLgsqxNhoKNpP98bq8yCRki+KSuR
         u/Ghfz/GG9NimDdiK7bPjmhX99defqEBcyPIKfEqXNRO4nRadCE2un9D65yd7nwj7kIv
         6FdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lE+7liccnRpiIpgLdMxWmMKoiV3j2oVjRzHS5uLvmvY=;
        b=As+W9RWN3/I59M5yraWnSMEUfrOvFn01Q9OVw9NoHoFZ5ihChQ2EDsPC6uCWRJRynI
         QdNS5lY4uJ3yZHqZ6EC9jVvM30t3gdYQkjh96WYHe4sr8V47g7RIGX9dNCFGt1wjGi6p
         pqgy+KhzgpTKIMnj9gqHOHrp7+zQpIyjN0rzkDpalfW3C8AqisinmA+7PLRof4MuRxcP
         rSvZJ8xbhU/r7eaL7DdC19POJZC6bKz/owPR0XX9EMbq6xhIZgQ3v0vOhEnxJWX6Tdzb
         lTIR9P4IvLbsi1hjhFnOWv7t1BSeR8h3BUtSCfXPhwSyFderPLauhu6lGIoqs8+qcXgS
         kHUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j197si1746347wmj.66.2019.06.25.04.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 04:59:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D3FF468B05; Tue, 25 Jun 2019 13:59:21 +0200 (CEST)
Date: Tue, 25 Jun 2019 13:59:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190625115921.GA3874@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-19-hch@lst.de> <20190620192648.GI12083@dhcp22.suse.cz> <20190625072915.GD30350@lst.de> <20190625114422.GA3118@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625114422.GA3118@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 11:44:28AM +0000, Jason Gunthorpe wrote:
> Which tree and what does the resolution look like?

Looks like in -mm.  The current commit in linux-next is:

commit 0d23b042f26955fb35721817beb98ba7f1d9ed9f
Author: Robin Murphy <robin.murphy@arm.com>
Date:   Fri Jun 14 10:42:14 2019 +1000

    mm: clean up is_device_*_page() definitions


> Also, I don't want to be making the decision if we should keep/remove
> DEVICE_PUBLIC, so let's get an Ack from Andrew/etc?
> 
> My main reluctance is that I know there is HW out there that can do
> coherent, and I want to believe they are coming with patches, just
> too slowly. But I'd also rather those people defend themselves :P

Lets keep everything as-is for now.  I'm pretty certain nothing
will show up, but letting this linger another release or two
shouldn't be much of a problem.  And if we urgently feel like removing
it we can do it after -rc1.

