Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02DA2C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 13:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0CCA2175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 13:45:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="WWW/ZZ4i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0CCA2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A0A98E00C3; Wed,  6 Feb 2019 08:45:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150638E00C1; Wed,  6 Feb 2019 08:45:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 066EB8E00C3; Wed,  6 Feb 2019 08:45:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4C528E00C1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 08:45:43 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id q18so2452298wrx.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 05:45:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=1B0x+fHheTpxhqrmIHIXM2dJK3tS381uY73XT9HFqos=;
        b=s8aUHi6yFN6eGdcaeGBSqcO98NAJnFTIYjBEx2AFeLbUYW9m0xnxwJtHj45NYvNOZ0
         szBxzk/9WmMW5PnD7YSDg0NZQoQIiF/Urez78WTD+luEy0HR+weX/n1InLFGmbq61XyK
         6YfnaZe02EsnmGKopMvfsF8OfmvYgl4CN7su4YVEX9bstEasJHwqiDV7moVwGa5h0eiK
         /Ab85XFlcoiuc56Ai6vme6qlJpPd9FrgrnYiqKIjPS3VATlCYWTihooehlDJ2RBgLikW
         5Z1t6Im/pB//5ifkot29j0fdep7PJyt4wwIcj1pvjmO5JfzKNhYvl1H/soO4BruVXaNS
         hFVA==
X-Gm-Message-State: AHQUAuZtlnEkDA+JVSxL18FnA2NKDOf0R276FVR8GnJSOffaxF/nA88n
	fmn3+gZQUWvYvZmIYeubqfNd9g1Evjnbtm19fYARtWBm9LDRzEfkBiNL6R4aKDqm5Gm3nhJU5Ha
	lr9mdDopPH64hmTQ26R0LPtRq+A2zMGRRLnSx5yg4aMpMEug4Hy/dyvbha44h1R9CSA==
X-Received: by 2002:adf:f8c1:: with SMTP id f1mr7864958wrq.31.1549460743004;
        Wed, 06 Feb 2019 05:45:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IatyT8SJNKlVMfPBIVjYsXh4v6OxjXy3+N9IsQnKQ8Xt7x2/yXQ6UC+UVjO/wHq1j2DvK6g
X-Received: by 2002:adf:f8c1:: with SMTP id f1mr7864900wrq.31.1549460742027;
        Wed, 06 Feb 2019 05:45:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549460742; cv=none;
        d=google.com; s=arc-20160816;
        b=DXX8PsVJ+p++HlIqXagyJPwAVfXTYrUWnTo7gaEiudGsdcmSnHAIMGv9ztQp1uB11d
         PImzHQYuzPn5G7yMBWnqjIH/bjpf8Ldl9zwbw/UrmkoR/teuQUy/xyIrZKbmOhnOp8qb
         AJIv6D3UERJ1wq9AlY0NVYvPFaed5Wyk94L++cH1H0QHEKIcgd1mPM0XCnBmPrnsXiF2
         ccm6nRrR++AisPqUH5KlEdTIo9x9CF7XDWlvVqlkmyJ91DSsIM7QjWsSSPMsKBNEvf0S
         VnbTuMgSGvQCb591tSeM3tTbdfZPMqZ5l6ToBhEwoXhfBx+hljITpUw+sgvv9rWopGZN
         gxyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1B0x+fHheTpxhqrmIHIXM2dJK3tS381uY73XT9HFqos=;
        b=udHPzqHvSUGYsaboitFiVTDM9jKGfl18dPz0an3YgacG/MRWTbE8DHlm/V10hw4kW5
         tL4/Mi2wyHlDglTilg41uteVqrgkClbqr3EVETN5kBO5h2a0Tv/XXeeVsdgFPb+Db+5x
         ClBVsKqXrqszo6qlIe6lox7RS+AWL/HRbPOgMT1jLxsZZ/jErKztNkmaX3tGfwLKMgCg
         9rYbtoOb5WErInet/d6TdT7Gm/+rEr8hayat/w+skp0GOhQZ5w6+EsSHtBCWyHa45Iul
         i2PRn1aR4SOmPgNMTaODGUa7Ldwo+HmfaAQMLQAidNZ0fN4JHj3kfbvGQhwQhfACYweN
         3joA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="WWW/ZZ4i";
       spf=neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::11])
        by mx.google.com with ESMTPS id g5si6886859wrv.375.2019.02.06.05.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 05:45:42 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::11;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="WWW/ZZ4i";
       spf=neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549460741;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:From:References:Cc:To:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=1B0x+fHheTpxhqrmIHIXM2dJK3tS381uY73XT9HFqos=;
	b=WWW/ZZ4iys91zypJvaDIFXPI9hect7KK3qlzTk0H3NmZpKubbOq54qewjmQe5vgztw
	1wc9V3qkqb5jCCt/6y1+nTdy+8yWjpGkxALm7c21tVvPQIQAOO4DwO0coPax83GWWXj4
	kYZss1QNfl6AKZx768SZf+pkG98UAuMJXZiVt5E6xAOr6sv75OsfV4tLoJBKOG/SN48b
	2pNi1njcuf8IOEx/TIYROCpvkgj7pWI83cORjlNg5iqQXiuUaQAkl0nTr0X6YcZ78ZGa
	udDAUJo+ssiRSesro7SXIwB+obKz+SeFnEloItqULicxzcq+RF4zVlfkx2Z5qc7RtnY9
	HGyA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7ClZjqpXztc6Zcqs1wHF7xyXswVRvQ=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:f029:5369:8d3a:5beb]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv16DjYum1
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Wed, 6 Feb 2019 14:45:34 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
To: Christoph Hellwig <hch@lst.de>, Olof Johansson <olof@lixom.net>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org
References: <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
 <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de>
 <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
 <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
 <20190201080456.GA15456@lst.de>
 <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
 <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
 <20190204075616.GA5408@lst.de>
 <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
 <20190204123852.GA10428@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
Date: Wed, 6 Feb 2019 14:45:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190204123852.GA10428@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04 February 2019 at 01:38PM, Christoph Hellwig wrote:
>
> It seems like the pasemi driver fails to set a DMA mask, but seems
> otherwise 64-bit DMA capable.  The old PPC code didn't verify the
> dma mask during the map operations, but the x86-derived generic
> code does.
>
> This patch just sets the DMA mask.
>
> Olof: does this look ok?  The DMA device seems to not directly
> bound by the net driver, but not really used by anything else in tree
> either..
>
> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
> index d21041554507..d98bd447c536 100644
> --- a/drivers/net/ethernet/pasemi/pasemi_mac.c
> +++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
> @@ -1716,6 +1716,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>   		err = -ENODEV;
>   		goto out;
>   	}
> +	dma_set_mask(&mac->dma_pdev->dev, DMA_BIT_MASK(32));
>   
>   	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
>   	if (!mac->iob_pdev) {
>
Hello Christoph,

I patched the source code from the Git 'powerpc-dma.6' with your patch 
today. Unfortunately the P.A. Semi Ethernet doesn't work with the 
patched Git kernel.

After that I tried it with the patch applied over the working setup 
again (powerpc/dma: use the dma_direct mapping routines). Unfortunately 
after compiling
and booting, the P.A. Semi Ethernet doesn't work either.

Cheers,
Christian

