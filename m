Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71425C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDD621726
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:54:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="UWh7hJT2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDD621726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F287A8E0002; Fri,  1 Feb 2019 11:54:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED7E58E0001; Fri,  1 Feb 2019 11:54:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEF308E0002; Fri,  1 Feb 2019 11:54:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86F788E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 11:54:43 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d6so2508097wrm.19
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 08:54:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=LAbsLwu8sJW7WqnqGFFP5VTZ9qgQ8eLa2wTlFiB3aZY=;
        b=KwTOCJDwlQE1uoSvtqQxObzQJtij/uqghWviXFMaEscILP63AroZ7wvI4y7NCJkJE1
         yGHtQLLJfwLL6L9VxxarDL9QO0h70yTv+BSDnRshvAeiDnJYsIPbakczMu9h0yVXRvhn
         MbXmIZIzgb41CptfnkDJCrrzOn29jMIwRSYqLVdjATjZ9iz12JtLHbDM4qhSWWFkKcHY
         FlABLUqT3L49zJ2f0+IDc+EHvAwveQog5Hu8rFuTJUuyctPjekY34ayFmsIT6AVxcGmc
         eQf+TKX5S1AFcs3/4S9jj7XnT3LxCzMPMRTFd/+dwwv4V/1w4M0TXiAZou7AFQAZhzyV
         btTA==
X-Gm-Message-State: AJcUukd4TobxX2khSlRj8Rz+F3rQTVkNlWQdMRblSQgs23SJbMeWOKOv
	EsnUuNC36ATFlTqGXWgl7tKlPa3ePTNO/OxAbhLexKU4lKvPh5m7aFhSScsYR+MRdiDlz3MW38G
	fxc/53YKabS3nyoY8Si66EXaAchG2ZAS4bzeiot6pwYhTYwNlqrp5ZSrOlVdHW2gTHw==
X-Received: by 2002:adf:fd87:: with SMTP id d7mr37975228wrr.74.1549040082999;
        Fri, 01 Feb 2019 08:54:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6wN1OgGeFArOuHoGFfIHi7ZYWwCGJIc7Xv2XA3tJYJJMC0goUcWrDmcAv2VV0mNXCduBkF
X-Received: by 2002:adf:fd87:: with SMTP id d7mr37975167wrr.74.1549040081645;
        Fri, 01 Feb 2019 08:54:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549040081; cv=none;
        d=google.com; s=arc-20160816;
        b=UUSFwxx/AgPZNSBryQTG9XP0SMtUMlUdAj1ewcCHIF9Jd6NIWAzGZQUNPtsQX5y6AA
         ErAiJVkxYBGrvj3akAKby75nd4tyAwfDaTbjItQSN61fLr0NHhemORSoYQoMw2lrdH1z
         J5MQX7Jq0FHCdCLuJN+khHc1zJl57Yb1NXU+RKjIqmgbNOHc2hhLVuJlssd6HMilESDu
         7B9MChJOXe/kf6YQ6d4bKiCnXVzj++jNovXyw8JN+hH3QSpPl7BIrSLnkWLGDjfq+Vuz
         YX88XwsBTwpOLNI4QcC7gcv7At0R+ppFGId5HVStdriERhA1EkIimdse9EXkBklhGG0o
         kzww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=LAbsLwu8sJW7WqnqGFFP5VTZ9qgQ8eLa2wTlFiB3aZY=;
        b=ym5Y284kxxzz5YBMH09TUjpTvSY3Il2EJnEvhBiZyKEAHoS8cUuHRk3OCsb8nu6jiR
         nZt6xyT9DGIjMAa3VFZdUU0heKN1k3BeM0C61WbyT/KMvH5r24AxS6fUEhAY6WrabxHA
         9nIxy8VONcZQKfVcYLO61S4rhT1/FUd4ae/oUZ1Sv3WodqjPwSvER8ugOFeL9ykixI/N
         /VAjJPHEeV1DNjogXdcRuAO5KY9SP0J3e/sprSW3mmC5mA4K9u+RPs2JMfn15QKJxXyD
         gC4Ym0UFkhu6ncTyT0B49mHmwVQY3HlKY9z3RKK15Tg/S1BTyl5XNDAgwYahI/LWkO2U
         54ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=UWh7hJT2;
       spf=neutral (google.com: 2a01:238:20a:202:5301::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::2])
        by mx.google.com with ESMTPS id d2si674578wre.283.2019.02.01.08.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 08:54:41 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=UWh7hJT2;
       spf=neutral (google.com: 2a01:238:20a:202:5301::2 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549040081;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=LAbsLwu8sJW7WqnqGFFP5VTZ9qgQ8eLa2wTlFiB3aZY=;
	b=UWh7hJT2SP34itt3cmY6PLvgo9TZNXUvC3KQ3tPYXEPlFQ4hsEFesZY3sJ/92iXbSz
	CV3tOEjs4OxOm+CwLqfvUDm3su4SrQceDjvnKmqTRRU52pvPxJa0+7lNAFYpEv6umGiP
	rNsEgVyzLmyIrNFZpN9PXZs4m1IhXFY/h4qwTDr2rEdhF+OCGdVorYueo1pzoTniMW7y
	tdZ5ku2VLfBeaGu0mNe4zhxRbwoMxNpHD80QiIs1Y5t8Y3Gj5la92U6QJbtHVC4CeonF
	EezeSHHPFLQLIVZR/6JsaP6w/gDO0jwfBMD+d3AZoJlFA3pgF4TuFXTqfZWF2JgyT1PW
	D2nA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7b2dxirpixiJad29NQJbPwl29UVaHJ+MaNaC8Wwcm"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:b001:72d0:7d2b:70c4:d703:bb47]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv11GscVPa
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Fri, 1 Feb 2019 17:54:38 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <20190201080456.GA15456@lst.de>
Date: Fri, 1 Feb 2019 17:54:37 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
References: <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de> <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I will try it at the weekend.

Thanks,
Christian

Sent from my iPhone

> On 1. Feb 2019, at 09:04, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Thu, Jan 31, 2019 at 01:48:26PM +0100, Christian Zigotzky wrote:
>> Hi Christoph,
>>=20
>> I compiled kernels for the X5000 and X1000 from your branch 'powerpc-dma.=
6'=20
>> today.
>>=20
>> Gitweb:=20
>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-d=
ma.6
>>=20
>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>=20
>> The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet doesn't=
=20
>> work.
>=20
> Oh.  Can you try with just the next one and then two patches applied
> over the working setup?  That is first:
>=20
> http://git.infradead.org/users/hch/misc.git/commitdiff/b50f42f0fe12965ead3=
95c76bcb6a14f00cdf65b
>=20
> then also with:
>=20
> http://git.infradead.org/users/hch/misc.git/commitdiff/21fe52470a483afbb17=
26741118abef8602dde4d

