Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F50C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5546A2184A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:29:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5546A2184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E48B78E016A; Mon, 11 Feb 2019 16:29:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E01DB8E0165; Mon, 11 Feb 2019 16:29:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C96458E016A; Mon, 11 Feb 2019 16:29:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8523D8E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:29:27 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so324747pfi.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:29:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=T/I45QOkNi6A1+UrvU1QchWKr3K3JR6njWVUPbAU3vs=;
        b=I1t8KAEiQqG+tOW1G9965eW7eHhjf50ztFB6bDLHg2ufynhWKregiQ9Dm8U9DiKM0W
         HIuYtP2d/1MS1cvP7i2G2WzzDs0QeoNkSja0RKMoO1Cv/8owh4TpEWhc2svk2Y4X9cA5
         l69e/WOihYV/UCItYm3539x88WJ9Ku7XfC0bzvmUDmX7lf9p3+2fjbMQkvo9avIWuEKA
         jQfVlknz3FavF5xMSNKxeBHFjNf3QrKqxcdWAPa40ikwO7WyGYFpm5mXr++GrsU5coJE
         kivC3ArkZ572is9brxONjkInd87M+lwX3K3UAAx5KEJmnQGdYY4QtQo8KX2N1wZogEC7
         VEzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY6tCx7bv5HxnDt79MWeqKHpTZqNA1dqUiRXXdX1sb1nqwG0fw6
	KkcYVn3U+7RjYbf9BVCF9InrmsMSeqIEHJJ0ay7xSqnY5s7wiUtktFRzrg3X1K1N90wopsReL/r
	CuWhEwSHOGhCKLMpZi3VXjGqVYLRooIewBro1QRtA7bRKnnxZc282DtKmicgDRqeMzA==
X-Received: by 2002:a63:20e:: with SMTP id 14mr275639pgc.161.1549920567216;
        Mon, 11 Feb 2019 13:29:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbB96y5b2QaP4fLVbziDUwyrWnZpbJaHwOoMcpOqvnDc2w0adAaQXc/BeCEL8NXZLOLSzth
X-Received: by 2002:a63:20e:: with SMTP id 14mr275612pgc.161.1549920566655;
        Mon, 11 Feb 2019 13:29:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549920566; cv=none;
        d=google.com; s=arc-20160816;
        b=BN6WEiXxLFm9Je2ATW/Gmk0gyNqscl7L5LlrraqDCNJU91GtvO5Gar3v/50kVn4btq
         XEyfwnDhnkc8OfoG2U4dRx5z0QGznmxM9iVhLoNbiPwR2tmphuzNstPSkPEe7n7dyPGC
         qCB+hhwQvYjyG0guUjw3bkb8zwOd9gbZtOHC3awCxDQu5xmm6IriupqBIqnjNgv8+4b4
         G7wN1BluRw2v1FCCr8Qdf0QCkTdbXXiYKYiK0jiy8VvLVpXWDph1dHgk0BoB7/UD7T6h
         DmA+HljxuehT3gRYYg/ZxeThYR50GmTVV77M22T0hLMwcwaYqduG5ASgj24HQucLifiY
         NO2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date;
        bh=T/I45QOkNi6A1+UrvU1QchWKr3K3JR6njWVUPbAU3vs=;
        b=ORKDbNbficydHRiWBWcL75iWMF/G1VVOfhlsfV2t2eb7/PAzIj3fas2hXw+F+98vIU
         +k/VMfzAtGBkpKbVjjms8baRdSd0+/fXEUpX5m1YZcXRK8QagpCyWyibFyZADm0U7aSC
         3boq8ksPfXqn8PaM6BccVaMUpeLJopN7olYkklSEf2nvqcdmX49en6D2p3XVXbmcsSGm
         uk8ejQ6zCsAElE6OCo2P96Rtspv2Dvrj7bHzYz0kQxUtT1N5DHKRDmmf7UNUE8foALJx
         fLXpKljuV3d7mHPA/xERL+k3H5QaDBWm+oLnrJ491Zi++imUhs2yXhVU2orlJItAFyZF
         mQQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s16si1569830pgi.23.2019.02.11.13.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:29:26 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:29:26 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="133483233"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 11 Feb 2019 13:29:25 -0800
Date: Mon, 11 Feb 2019 13:29:14 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211212914.GB7790@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:34:17PM -0800, Davidlohr Bueso wrote:
> On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
> > Ira Weiny (3):
> >  mm/gup: Change "write" parameter to flags
> >  mm/gup: Introduce get_user_pages_fast_longterm()
> >  IB/HFI1: Use new get_user_pages_fast_longterm()
> 
> Out of curiosity, are you planning on having all rdma drivers
> use get_user_pages_fast_longterm()? Ie:
> 
> hw/mthca/mthca_memfree.c:       ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
> hw/qib/qib_user_sdma.c:         ret = get_user_pages_fast(addr, j, 0, pages);

I missed that when I change the other qib call to longterm...  :-(

Yes both of these should be changed.  Although I need to look into Jasons
comment WRT the mthca call.

Ira

> 
> Thanks,
> Davidlohr

