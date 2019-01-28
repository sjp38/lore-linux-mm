Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6B77C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A5312173C
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:52:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="Z3nZvXzW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A5312173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 971508E0002; Mon, 28 Jan 2019 11:52:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920DD8E0001; Mon, 28 Jan 2019 11:52:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E9838E0002; Mon, 28 Jan 2019 11:52:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9FC8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:52:08 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id x13so6937240wro.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:52:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=fYy8sGt7/wpwSK7F/RuYxrqnrtG/2ZYafyDDkfrrFIg=;
        b=GMSXBeD66MCDK7GZgNjttqFHrOyXdl5gMDZVfZNgOrUKZ6F26q2frlc9zlwYuvXfy9
         shYesbGue2q5hzB5TlIZZKuOaH12e1WHtS+3aavWZVnxSzGBXaeHTkHTq9upwo5xs2OX
         NYn4KGTCAFxR3ApwnV96FO1Zb4H1s513A3jJ8B2NBdQMtHbTTTufo70zEOiM5L02/MUy
         Nm8FnAK8TmnhNw315KO3EnIjSimn2/np9ngzUWJALiI+YnhFzYgQyz1+8Dmc4Q2HrMqa
         E+gVZEumIX6z4v1sKqETzRw0zXTyGY8OLF/mgF8vFeRekdWR490yz0wjS7mWfQnc6Lck
         b92w==
X-Gm-Message-State: AJcUukcJ/suFUc8h4W4eyVBfm5g5onUDo1qkd3MK7Sg8I5ze+grsQAzs
	YUqt4czDS2QBbE8v6R8hauvWgm6W2e73mMbp8+63Je7QL0tqREDV9OpP40qidiFaCisoBUwT0IN
	GYfZ2YpWJjHZ9ZSArrKq28q4tx7Z5Qc7417CHQg1CT90omYVI9VXjRg/BciT02zE62A==
X-Received: by 2002:adf:e911:: with SMTP id f17mr23919367wrm.126.1548694327649;
        Mon, 28 Jan 2019 08:52:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7kMGPkWQ/xjiPo6a1CzWM0UUWryQMjPEN79KAgTwvRojmGc5Z3ChTIvALHUhug/6ZCPYif
X-Received: by 2002:adf:e911:: with SMTP id f17mr23919293wrm.126.1548694326589;
        Mon, 28 Jan 2019 08:52:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548694326; cv=none;
        d=google.com; s=arc-20160816;
        b=fQCFNFNlultTswkP4sgAuSD5kLdhP17qfbzF9ZcuxzM9h/0pBEfLbNGRIMnw6TqJ5e
         WQD0qaDvLMq9Zh0jvy9JfDtCl7k//bPOtXhzzmH4GhQY4Usl+O7oeHjwpORtvoLuUg+D
         C8PTHgaMQAsGfEo8I8bSXddlYOT42VYv5TNAmNQncxR6d4snqct2wC57FOSZXAXQuYE2
         3iXyfHO1PpaumDi8WccwAms2tt45umPBOfyIsGVW81Mo3j57YwtzAXHlLxFY2LCuntAn
         JJgv5Or8/J0dnDf4x77YOAFNVXExcN7VqLfZNq+lbIygl6EW4aQ9gaDaj1h2JuO5VdYM
         PvuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=fYy8sGt7/wpwSK7F/RuYxrqnrtG/2ZYafyDDkfrrFIg=;
        b=azX3UwJ9UvtzxoqPqPQho5JDpMK3dugdFd7WKzzgAd9KulabhV6ca0SHNINZ1/wjOA
         v3aV+J24ILvthyGFUHTIyAjGpf4qFH/INYfkLulRq0OhgepNYumcYZMf/dSO+TgHBrdL
         dn0s2GYaDYoS4u8Dqgg1e1DpdWPfbYwK0p0OPMbB76AzPk18B0RF/DXhZrooR2Fpo2W6
         DxB+GrHpg26O9KwhQeQOdXXbofpTdbXF8uuHC1KXpHF/ljm497Z3N//1Udqu+5Zj5rdQ
         TLXVbecsmKZ/hcsOr0sdfEu7UifzDJHXLokbS56HCoryGv/i9jGkrLUwNcSls/2gXyJ7
         ml+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Z3nZvXzW;
       spf=neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::3])
        by mx.google.com with ESMTPS id j5si61614426wrn.140.2019.01.28.08.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:52:06 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::3;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Z3nZvXzW;
       spf=neutral (google.com: 2a01:238:20a:202:5301::3 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1548694326;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=fYy8sGt7/wpwSK7F/RuYxrqnrtG/2ZYafyDDkfrrFIg=;
	b=Z3nZvXzWKbOfeF4i/Sa6/34PTNYvwUX9au7khE7YeI915MggrH+7DF7A+NQFL8hv9L
	PBT1NGaqhLOiNd3kMtdstCvRly3myWoknEsYQ23aH6JAtvvHo9/Vn+1QZtTl6i/SWrnX
	4jcrABnfX6MGcCReyqx1ZbxsiHyPzF94IrYl5pWcjSw0z525J7scVCTj4uErOr2XDEfS
	+H5w3aNFbS3l6jVuUC7qYa96fA2hMl9fmsZ/YQb65HwUYKsjRLQ/8KEnZcHG9NYU3uIo
	8lwtmzsFYNaswpHPgozm3U1/vst4gOhE1hF+f4xnbfSDY2So/750adeJ/mxBNWU8Gp+x
	Lwyw==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7NWd5jrozwSMRO89bpVdzWy5IAdgOVLzMC27Nvb91"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:8085:f5ea:1107:97ca:749d:8607]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv0SGq43xi
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Mon, 28 Jan 2019 17:52:04 +0100 (CET)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <20190128162256.GA11737@lst.de>
Date: Mon, 28 Jan 2019 17:52:03 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
References: <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de> <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de> <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de> <20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de> <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de> <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de> <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128165203.AvW5ZaFW-y69KVWDB6a07K_Pq4QrqxM5txe4R1VHQO4@z>

Thanks a lot! I will test it tomorrow.

=E2=80=94 Christian

Sent from my iPhone

> On 28. Jan 2019, at 17:22, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Mon, Jan 28, 2019 at 08:04:22AM +0100, Christoph Hellwig wrote:
>>> On Sun, Jan 27, 2019 at 02:13:09PM +0100, Christian Zigotzky wrote:
>>> Christoph,
>>>=20
>>> What shall I do next?
>>=20
>> I'll need to figure out what went wrong with the new zone selection
>> on powerpc and give you another branch to test.
>=20
> Can you try the new powerpc-dma.6-debug.2 branch:
>=20
>    git://git.infradead.org/users/hch/misc.git powerpc-dma.6-debug.2
>=20
> Gitweb:
>=20
>    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc=
-dma.6-debug.2

