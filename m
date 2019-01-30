Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD34EC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9971E20870
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:32:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9971E20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CDDA8E0002; Wed, 30 Jan 2019 12:32:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5138E0001; Wed, 30 Jan 2019 12:32:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 293628E0002; Wed, 30 Jan 2019 12:32:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01C0D8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:32:18 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id k133so277799ite.4
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:32:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=e/uuji5N7Go5MZ6ODm48wSxdSPUtMpgGLJuq6m8HZHc=;
        b=WTN3GtO4QxS/221klmWAqokZB/aBWSVHTRLC5x5gNs13gmsh/mB9Zh/4F4xZ283Q5N
         r0PHy463aUvdnnjzfgi1epWNt5iuYnCp+ZiuLQF/uClRFkytz7nFNjMRtkkLS9SJIKA3
         ExbjUzXU48DDzF06N6EfDvICfVW68zQ2/WdaHLrR2b7bBU1qHK6dycNuvD5hAX/CqrCB
         RydkRA3yAPYB1iiukPNdF1WLOHzbGHYPoXiAzL+2Jo4GKkTwiBpNGq0ruPbZAoeX5FWq
         3CHVN5pu77OBVfyYSFrxFlLjEEw9kZBTYKtwyGlEffk6TVr/q0l+SapTNbZGZ2vtMXtv
         geZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukfaVhB1itnYLSXrC9TTBkXH+WGRCrERrWXghcnjqhfveFEXhuYo
	6wL/8bvIJA5r4GQGNtN5Iv1ehieCC2SXCGTAVDynqpqqLnRdm90Aor3imNUpLNq/aRqrHIpopxS
	GolJRrJPzj4TiBXJEY4semwN6eSWPwSDbeKOaJtkeFjQiL7aAkytfVyM1k7kMIe7Brw==
X-Received: by 2002:a02:9a01:: with SMTP id b1mr19853192jal.18.1548869537755;
        Wed, 30 Jan 2019 09:32:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN52xoWJ8vPcQDK0JQymwKOH3335hhEfB8LEERagbkef0aWO15r44JoeQ/RByjYS4nkheEl/
X-Received: by 2002:a02:9a01:: with SMTP id b1mr19853159jal.18.1548869537198;
        Wed, 30 Jan 2019 09:32:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548869537; cv=none;
        d=google.com; s=arc-20160816;
        b=bT4LeIM3deL36iX//wrqlPoJwuwcRry1Ta4WHGqJxyn9Neq/HPTxWSW2Ph4RSw2RPi
         URjFbNPh8AP/RI1x34OEBY2q6+ulohEZZwUeKO/XXjCUclbC3LvIGU+Z58WbQwsHvV81
         0mYsFO+rRfzuPGjJu/8rID1qLUr5a5nBIZBSh7d2pHh0hMnZipn5GsnJVvLiJPsDIuG5
         TT/rf8hVtftWNxJXI/JPSCDz2juY+P2IR+fQWgbR1tQSmT3OP6sisIi3Yq1H0vrFjyn8
         ceQwDf+HOmPo5oi/Pl3rmKZw/GTDM/3ifXzmyGkzXQHdrl4IQiirJUXbjwlYxdlfEeYV
         1OLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=e/uuji5N7Go5MZ6ODm48wSxdSPUtMpgGLJuq6m8HZHc=;
        b=i3St4A3hYXa7+7yejyAn1Uvq8WMZYKYX19bow28dRaUYpWCtAU4hzaPbD39nSX8Q4r
         vPuWg6GzM1/18x9pFEJUBd+3YOaOrHLJsrU+prn4lzlYsV0Sk9jbmM6g0WdaNHS4ZmZL
         Hh+YO3sIa9bgxu6ldayvdHGl/1FLnAVjD8kA58ry4QS3d19QUsHG60y8YQwS5102719p
         InZP5o5avjerzmSH7Fn1vgsFy2DALudC91QBBLqdpW53QDXbqhAU7pVljTKQeXq005j8
         cfxrSAtwEGqvFVBJkUeaM+FeVJm4A1ovZ5mf6xBCFeEq4Sbl3mGLdeMvBLS438xhTKhU
         taSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id u76si1231879jau.27.2019.01.30.09.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 09:32:17 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gotiY-0006g6-4S; Wed, 30 Jan 2019 10:32:07 -0700
To: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>,
 Jason Gunthorpe <jgg@mellanox.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
 <20190130155543.GC3177@redhat.com> <20190130172653.GA6707@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <39edda88-acd8-c8ec-a6a5-64898006b69f@deltatee.com>
Date: Wed, 30 Jan 2019 10:32:03 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130172653.GA6707@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@mellanox.com, Christian.Koenig@amd.com, jglisse@redhat.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-30 10:26 a.m., Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 10:55:43AM -0500, Jerome Glisse wrote:
>> Even outside GPU driver, device driver like RDMA just want to share their
>> doorbell to other device and they do not want to see those doorbell page
>> use in direct I/O or anything similar AFAICT.
> 
> At least Mellanox HCA support and inline data feature where you
> can copy data directly into the BAR.  For something like a usrspace
> NVMe target it might be very useful to do direct I/O straight into
> the BAR for that.

Yup, these are things we definitely want to be able to do, and have done
with hacky garbage code: Direct I/O from NVMe to P2P BAR, then we could
Direct I/O to another drive or map it as an MR and send it over an RNIC.

We'd definitely like to move in that direction. And a world where such
userspace mappings are gimpped by the fact that they are only some
special feature of userspace VMAs that can only be used in specialized
userspace interfaces is not useful to us.

Logan

