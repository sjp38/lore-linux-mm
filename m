Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB360C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95912206A5
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95912206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F5AB6B0007; Mon,  9 Sep 2019 08:16:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A54E6B0008; Mon,  9 Sep 2019 08:16:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BBC16B000A; Mon,  9 Sep 2019 08:16:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id 09E316B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:16:04 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 87A209097
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:16:02 +0000 (UTC)
X-FDA: 75915278964.03.loss11_34b2a3fbc1250
X-HE-Tag: loss11_34b2a3fbc1250
X-Filterd-Recvd-Size: 3847
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:16:01 +0000 (UTC)
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0127B89C33
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:16:01 +0000 (UTC)
Received: by mail-qt1-f199.google.com with SMTP id f9so11350470qtj.19
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 05:16:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to;
        bh=cR0iPk7k3gak2smW+VGCzi1D6+WqwWLkfLqRmEk+oQ0=;
        b=UlncmaZyUTrRCj22EKeJ1isaRY1ip8nXMpYvYifNyLr2AJCjIV1oGz/eWhL4FmhL/D
         CDA7i0OKY+iuxqyrqx0udN6rJVI8Ra3XCEzlFk1R3Nj40pQ5z2Y/AcTxwpegsyFIV83k
         wUWtOiKcVbdddkU/A/QeGTbRubetB0ICgk/V1v+xfqZRSjTl8Nh7Npq4k4Bl5+eqkinl
         NzPmvGxWi2cCV6bPD5E6/rcIOY07Ua3Qf16vmFFFYqvMx3uCka7VyTU4uWt0XXRPMS19
         k236ietGMwRzNGMrT72V1smJwsQSQ1fYS0+74DX2LxN6rkDwEbRWYrCIsv5A/fTUiLpf
         ffuA==
X-Gm-Message-State: APjAAAWDRmFUuZ9XAsPq23zJRfCmLgOsX3hOBaX39yIElOAFiTM5CKch
	Flk+1jTtU3h1KxxVGqfUEVCtPJuR6axRzF7q6NbVhwa0b2uW8zeUIhqmaxYrLSDjCZTbzDvr8TR
	5RUfRFpcqCnE=
X-Received: by 2002:aed:3527:: with SMTP id a36mr23116294qte.82.1568031360371;
        Mon, 09 Sep 2019 05:16:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTjEC9gLktIgrr/FKS4EvJdW8yr2QsPhfhm1/EGltRDxNNwBhSFB09DwZLmFGxdw8mqFXn1g==
X-Received: by 2002:aed:3527:: with SMTP id a36mr23116262qte.82.1568031360138;
        Mon, 09 Sep 2019 05:16:00 -0700 (PDT)
Received: from redhat.com ([80.74.107.118])
        by smtp.gmail.com with ESMTPSA id g194sm7059848qke.46.2019.09.09.05.15.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 05:15:59 -0700 (PDT)
Date: Mon, 9 Sep 2019 08:15:52 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: David Miller <davem@davemloft.net>, jgg@mellanox.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	aarcange@redhat.com, jglisse@redhat.com, linux-mm@kvack.org
Subject: Re: [PATCH 0/2] Revert and rework on the metadata accelreation
Message-ID: <20190909081537-mutt-send-email-mst@kernel.org>
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905135907.GB6011@mellanox.com>
 <7785d39b-b4e7-8165-516c-ee6a08ac9c4e@redhat.com>
 <20190906.151505.1486178691190611604.davem@davemloft.net>
 <bb9ae371-58b7-b7fc-b728-b5c5f55d3a91@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bb9ae371-58b7-b7fc-b728-b5c5f55d3a91@redhat.com>
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 03:18:01PM +0800, Jason Wang wrote:
>=20
> On 2019/9/6 =E4=B8=8B=E5=8D=889:15, David Miller wrote:
> > From: Jason Wang <jasowang@redhat.com>
> > Date: Fri, 6 Sep 2019 18:02:35 +0800
> >=20
> > > On 2019/9/5 =E4=B8=8B=E5=8D=889:59, Jason Gunthorpe wrote:
> > > > I think you should apply the revert this cycle and rebase the oth=
er
> > > > patch for next..
> > > >=20
> > > > Jason
> > > Yes, the plan is to revert in this release cycle.
> > Then you should reset patch #1 all by itself targetting 'net'.
>=20
>=20
> Thanks for the reminding. I want the patch to go through Michael's vhos=
t
> tree, that's why I don't put 'net' prefix. For next time, maybe I can u=
se
> "vhost" as a prefix for classification?

That's fine by me.

--=20
MST

