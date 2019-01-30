Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29B25C282CD
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:40:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26A712087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:40:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="foloOtaA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26A712087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797448E0005; Tue, 29 Jan 2019 23:40:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 746988E0001; Tue, 29 Jan 2019 23:40:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60D608E0005; Tue, 29 Jan 2019 23:40:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09F258E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:40:42 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id g3so6609125wmf.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:40:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=wlCPd9t+ai37SuMMWwk22tHj2OiZPFG7JEALF32RN7Q=;
        b=Pu1oX1WiqQO9PqsjYbod5n4clNIQ0QZZvB8kK6l0TGITsQ/3Hg5SJeL4MVqz+cJjBv
         TnYn5zcH1Jgdr61xX7MmlSnkKShkKzy1WW9sQi1IMD8FPTI8EbuiFBheirHH87IKFLLI
         mNcVdoNguU8R3PuaWbsZ+eoWc+3W501kkdBQ9YGImJeKbls0rv7hbdb/pmnXfMBmyb6n
         D8mxZ2Mx32IlS24T7nOWs4PoQtMYsi8E8BfqhbfYIIGgtWvO5lfWGmL3D5FPrGLUV2Zj
         hmHRbvkvjRFrhYsc0EzjuUVrb2gOaktwaG3iv+bwpOpHK8WkM3riFHyKKtqT3K4cn9/0
         JA3w==
X-Gm-Message-State: AJcUukcyKRRgFArxToMDxLoVIZypO3yEW4Mm2quU6DpddpTJKwMcDUdQ
	yHvL5X1Qnc7j5IpPVv4jGhmEsQ9WYzMp3h2Clz/Zo/ULy7tW0y5koKGN8DI6wbG6Um9xdmO0bKm
	nJdpgUbUL1MWM+q6rNfTT7KiaDakxfvN/CDgMzpF9RFywYHURI7lSmE4opCAGR83b9Q==
X-Received: by 2002:a5d:4a45:: with SMTP id v5mr27038637wrs.7.1548823241473;
        Tue, 29 Jan 2019 20:40:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4BmxaNauIvw4R2fS1S6A4pVP/0T9X6LX5Kp8kReSawM33Vjv8fCd5ZTo9zqnr9OgRQHCFz
X-Received: by 2002:a5d:4a45:: with SMTP id v5mr27038604wrs.7.1548823240604;
        Tue, 29 Jan 2019 20:40:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548823240; cv=none;
        d=google.com; s=arc-20160816;
        b=tOoggwDqOdvGBzf+SBMmuGz0VBEexwbPImdu+lCoBlQzSuV3SWaruIrTnRU0QMk1uM
         rhorJduO7aVgcVfoe6MAIaCgoPISujlxKtRW9m8kL+8cBhY1oOHpM8Tth5luIh3fZ+mu
         6ZTJm/tU+ej7g//+PEAvWne986kkk/2U9N9LNIVFPIvejsVyCkqGIluS+k197diRmcHi
         WveZGtaS2bHvHrKggs/PElEw8ASXToPXwMk5tImo8jazNcMqUO5fA5KkBZVvULFjqHxa
         gsCWAX/uEb4infaNfj+Y0yHoiX3JQKATXhchxt58zCR9FKln+17jpdjPYu0y0Ms9muyy
         MVXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=wlCPd9t+ai37SuMMWwk22tHj2OiZPFG7JEALF32RN7Q=;
        b=KtCkfcrjiZMHLhRZoI1rmFes6SCUvTrj0HyIo/h6QGKUPnMjysleFhd5QD2+B7tufn
         QNDzNKTq4l0RBFku7OSnJh4IfNBEi71l3UGy4AO0twDI4ZdzLZ5yz8vB4KLhdJ020bFm
         WYiI2W+ti5yHycaTbJyb+qMcLHa2l0xbKWQM06vGonRIg8ch3NigjesdbMRqdCn9Rzqy
         XMj77INEImOhZDS9B/vSYmaB6Z46WsCdq1oAe+HdJ0qcvKWlEurSfyZp+Tb9x+kdi2pi
         GfjjJ36DhzupuUFU6OqbDxJH/Wdlo4dhf4w+L5OZ5ZYsFpSslmAAJdidJVey13o2CaYg
         997Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=foloOtaA;
       spf=neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::3])
        by mx.google.com with ESMTPS id o204si688351wme.148.2019.01.29.20.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 20:40:40 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::3;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=foloOtaA;
       spf=neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1548823240;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=wlCPd9t+ai37SuMMWwk22tHj2OiZPFG7JEALF32RN7Q=;
	b=foloOtaAEH4rC5WxFzXtM15drdrKtWXNro8r6JsxpiqC/sIPu7OjHG2KVcnbarMDd5
	jL0DGH+uTVYHZQ2Ry9f7q8EQ5dfEzNWOBcuHGY2P255lzF/PnvysXD7XOIUu5IV3Z81C
	eZyQOaNdOOeUeHdKDDk3BSolRrb86N+f36Pr+eL956xS1FOlX0wlfV84zXdoRSttmNCK
	TFxDTAGcuOehwJpPGTI586gt2hH2VBZEZcN0S3QE7h0mvXyj0qmggPV/9t/nj4dwyX3d
	xkG1i2rre7QKVGl0JGKDWxd49pIvlIX9ML9oZJTH01XF5SMBKKGvicyfWYoFTMcEvYMh
	fDQA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7NWd5irpgkCKCilfXBXJD48yBI66ylK3+2uPIEi8="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:8081:5dd1:48c0:9ec:f37f:30cd]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv0U4ebCQ0
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Wed, 30 Jan 2019 05:40:37 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <20190129163415.GA14529@lst.de>
Date: Wed, 30 Jan 2019 05:40:36 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
References: <20190119140452.GA25198@lst.de> <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de> <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de> <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Thanks a lot for the updates. I will test the full branch tomorrow.

Cheers,
Christian

Sent from my iPhone

> On 29. Jan 2019, at 17:34, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Tue, Jan 29, 2019 at 05:14:11PM +0100, Christoph Hellwig wrote:
>>> On Tue, Jan 29, 2019 at 04:03:32PM +0100, Christian Zigotzky wrote:
>>> Hi Christoph,
>>>=20
>>> I compiled kernels for the X5000 and X1000 from your new branch=20
>>> 'powerpc-dma.6-debug.2' today. The kernels boot and the P.A. Semi Ethern=
et=20
>>> works!
>>=20
>> Thanks for testing!  I'll prepare a new series that adds the other
>> patches on top of this one.
>=20
> And that was easier than I thought - we just had a few patches left
> in powerpc-dma.6, so I've rebased that branch on top of
> powerpc-dma.6-debug.2:
>=20
>    git://git.infradead.org/users/hch/misc.git powerpc-dma.6
>=20
> Gitweb:
>=20
>    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc=
-dma.6
>=20
> I hope the other patches are simple enough, so just testing the full
> branch checkout should be fine for now.

