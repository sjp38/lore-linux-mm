Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A543C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:52:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74642070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:52:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lrFiJUhj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74642070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66C266B0007; Wed, 22 May 2019 18:52:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CF826B0008; Wed, 22 May 2019 18:52:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BEF76B000A; Wed, 22 May 2019 18:52:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23BAA6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:52:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n5so3742211qkf.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:52:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z/xm6Cl4ibMhuRCBQCtLQFmhKVon9z8MHhMjLCERca0=;
        b=Cye0YQuLkOwK5GSaQbijGPrHA49x30BC+1UU6vbhxJxQYY+u5EVrZjuuUZZnL4NhNq
         RSRdqRCxW+C7KntxG2p23GUKfxGlaeNr1JRtJU9lUf/aCTz5V4V3z9Sm3+jEiI3yRMti
         oAYurpofL497Cnn3dYS9tN8H7MQbs8RbnnFYuUdZEZ97VryHvTc4pcJKQ407YPFrt/+K
         NnmqLmgu5Gv/U6g22KWxQWLdZ5qB/hdVCWni1/hRUitk8CVkGmea0gIpDV+CfRern3nu
         Dknin0NqVGi5cufxJl5v6SF0HKoW169WON8DrtRAMxV/8S+QsbtlTqFkBPnGqWAuXNDA
         3hhQ==
X-Gm-Message-State: APjAAAXbJBtdCbnIeN6krlO26sN41BynwU5BFjxkkRDYP7Ynv7z/YKMm
	FWkl8aUqHhegpPPEaWcKQzb38zamehYnEY6Ag2C5+QQ4F8HhmeES0w0K355gJpOQbTo7JhnyOFk
	Nz92bN8ueNvPRIDpxJp1R7dOOWVbr1+NfNzSwJfkfssH8Bw0pVzOS1I1Idj71s1zl8g==
X-Received: by 2002:ac8:1608:: with SMTP id p8mr31306208qtj.81.1558565541952;
        Wed, 22 May 2019 15:52:21 -0700 (PDT)
X-Received: by 2002:ac8:1608:: with SMTP id p8mr31306178qtj.81.1558565541574;
        Wed, 22 May 2019 15:52:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558565541; cv=none;
        d=google.com; s=arc-20160816;
        b=qyOQCyuWGDj4pdAcMzRLk0A0Xk63Bo66IPOSOKIUHB0uedmRBKtcNTaJAXZqO7Rt67
         bZ4Ghl1L4j+UvH9njIUZyelNNoY6zmopnW4PWFiOGOpP3hhomWACO7aw02rk+MBDBZO+
         cO9N/i5Pe2u/IS7jt7PR6Kf/puJK5nlxQhYz7Pium0Rdbh6v/w/xoUhSJBDvoUP8Dp8w
         YlVAGCRCqN9omnFF+GibVAZw7Omnm1KMtgSEMK89KE2iMVjjcAC0evAwQ64iG6HWMXQ0
         KsOssflBBl2YN4K3mreTRRkLkiUS8jLVSTDsdPJZ8BVlEJQxfKkrvyJV17+ubfVD4BEp
         QQHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z/xm6Cl4ibMhuRCBQCtLQFmhKVon9z8MHhMjLCERca0=;
        b=p7eq4ZOZRIGJELjIf4AT/BfiOLVV7yDMa/zyZuH207aH1ZGCd/ezo3OAsU8kzYnUJW
         PwWthNyNdxFNFLWBgXokcCfau7BDBI/3ebEmp1CfLD7+E7mpKki5GXYnfsLIr26iNMfH
         sBPJMymLGLCE3RphRTPnEHKu9X71pao8dZETV2g43aMMNEIQRfBX7cPzhH0vWXWiaGpr
         x+FEgxbUOH0ZTlDPVfEXN+4jcKZoFiw3PN8aQERSU1zgnV+sGLnjb6+Wa+NgnyajtmjH
         T2rrvL6tbqTFVZGIoYvMPSvnz0pK54qktKgMA6xrrQJmQIfr4hllIA8ThwMz8IpuCdQc
         2gYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lrFiJUhj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u24sor14401153qke.69.2019.05.22.15.52.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 15:52:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lrFiJUhj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Z/xm6Cl4ibMhuRCBQCtLQFmhKVon9z8MHhMjLCERca0=;
        b=lrFiJUhjohnbp2rSC6LiceOG6jQ/wn0zbsCFI0zCEfyAIF55kVAyx0gaWo4RD2o01r
         eanhb7r/FQorOEI0fwbD1PfoRWVxWwx3Jeg1Nfew6g7qyAd964BRkXg8POP8u3swr+Vo
         jrVlYCOId7NNoVVhRTUjOXDkrvB2fm6wETueDBa50XwHpDYAXObJsbkd06JCnpyH3maw
         BBz5/NyifHbCbc+8wvyXzDI3+N7g/YlgDanbWNXadrnFKADZokNiOgL1VFUTZQbmDk0L
         1hTNzc3zIQatQHqcAh/+KMsGH9yY8qfVBw6e1qVJXJ5+YjpCaZlgkmbyEH+yxKbFDclq
         BqvA==
X-Google-Smtp-Source: APXvYqwewerjjcgUFras31nkDpRcgCScCGS6yclsA3zOzL0x3MdSxP2F0tK1PbZ1f6abn3fW4b6qJg==
X-Received: by 2002:a37:ef1a:: with SMTP id j26mr63212619qkk.207.1558565541350;
        Wed, 22 May 2019 15:52:21 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id t17sm16094116qte.66.2019.05.22.15.52.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 15:52:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTa5s-0004Hv-A7; Wed, 22 May 2019 19:52:20 -0300
Date: Wed, 22 May 2019 19:52:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522225220.GC15389@ziepe.ca>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522201247.GH6054@ziepe.ca>
 <20190522220419.GB20179@redhat.com>
 <20190522223906.GA15389@ziepe.ca>
 <20190522224211.GF20179@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522224211.GF20179@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 06:42:11PM -0400, Jerome Glisse wrote:

> > > The way race is avoided is because mm->hmm will either be NULL or
> > > point to another hmm struct before an existing hmm is free. 
> > 
> > There is no locking on mm->hmm so it is useless to prevent races.
> 
> There is locking on mm->hmm

Not in mm_get_hmm()

> > So we agree this patch is necessary? Can you test it an ack it please?
> 
> A slightly different patch than this one is necessary i will work on
> it tomorrow.

I think if you want something different you should give feedback on
this patch. You haven't rasied any defects with it.

Jason

