Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 919D5C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C22D2190B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:32:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="i+kTKK/N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C22D2190B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E12228E0002; Tue, 12 Feb 2019 14:32:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC09D8E0001; Tue, 12 Feb 2019 14:32:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD7A08E0002; Tue, 12 Feb 2019 14:32:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79E128E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:32:07 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z4so1397253wrq.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:32:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=srsW5XV2evoYsiR+WjtWPqDx2l+Rpp40ZvD9oBayhVk=;
        b=gU2wORBd3DKBohzzMNnLuSqc2Hq9ZrCBwYIwDBLT6rzHSt5nOQvx3Uv7+1tjTOSuyC
         qpha9Sa5DvcapHp8W2pd4j+d0oCBO4TXwNHhFLVon0N+0q0Ri+aNu1jZJ/r3wCm2W7xY
         6m8MKboihk/OUgQtBLtmMYoI9L7e4E68vduhoWj7DJSam2OxmsNNlHBPD/LdTegPULuo
         1XGdHrOkEMQjNiqHZ4m3galsFhrygZq2Q3eGP5no7ySl39UzlAFbucxJPohVO2hTp3DH
         x48pf5NALCnbiWnC9J1BjAz54OGE5K8kjA24JYWsxF1mO2tDoZqoUZIIJaSenla951nA
         DXKA==
X-Gm-Message-State: AHQUAubKNRT+3pBb4fxsUdjcTOHgjYEPrSUdD1r8NdJtClM49dRey5MY
	VknF6rsdlba2RPDnzUeSRaQk4IR+jXX33tUlGKivUuY6lnpw0XiXxQ83CikomzLP7sFomN6p6Qv
	pDN3YGR4WX53Y0xLvqaXZ7BuGgucehiHuBz/KA0+EYEgRK7gtulzUVaX5metvt9WPaw==
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr316772wmh.119.1549999926900;
        Tue, 12 Feb 2019 11:32:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ/T6EMRqzAjft4uvvpgbm7NGPRZFF6lhUO5RxYxPAJsR7XdazMgLFF6fTzziKGyi7Cl1k0
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr316719wmh.119.1549999925819;
        Tue, 12 Feb 2019 11:32:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549999925; cv=none;
        d=google.com; s=arc-20160816;
        b=nCrftCqXQeMdP1KKQlH13eyaF7jnK8H9YkjEIyx5zv+5+MMcziJhQ08cEPEe8wwKqM
         I6/20yeUeRz1sD0N6GnQkLgxnwBmLmwpdQzSjdMd9NDk4nDur78YwIYTMgjJIrVJMoGY
         Btv92469iwRoq5fwAmaPcVYPgCONhkh9guSyfIj4IazEkSPlnjVwIDw5CFOe7zbeplR/
         ageLQWGwDX5aVDiZyr52CBlEVrwOyCk3Qw7kh9Lv7/YIF2LH5/qWXCIl2ujex1meggvl
         6cWTVK+ieAhvd0OKv9nYgNpnP9jglpThzWPJa9gaJWbqi2vI+OUYCmOgrTmugh9yvmL0
         pWaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=srsW5XV2evoYsiR+WjtWPqDx2l+Rpp40ZvD9oBayhVk=;
        b=Y/G2XtFSUkNyARrhE4BInH2zVK/Pw83qUZE4xOgRCfP/LiqRGmXQ1qNt7vCTcM3+Iq
         nBh/fyj+AEUsHWmo9j+2WM5LAz/0ik7/aihgHYCdSD6R15LiAEbCsWSHE16UdrsOAo1q
         tV3yT95JSPC5/rFKWETIdZRGg8mmwVyTwJokjY3U9HfwiwLgFTCLpSR+x4W9HeE1vadN
         WsihpJEIzPFkP53vOpze+lVj+uxzG+93s9/JLtLisMjSE/jciuZhEr3P/N21/boTA979
         2I6dY21t16cJEwKPAshBKzxtXInnBSILivptEbFygwOM8HlMXbSk+BlhEKzrcSqvgnze
         BI+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="i+kTKK/N";
       spf=neutral (google.com: 2a01:238:20a:202:5301::12 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::12])
        by mx.google.com with ESMTPS id n9si2736015wmh.76.2019.02.12.11.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 11:32:05 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::12 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="i+kTKK/N";
       spf=neutral (google.com: 2a01:238:20a:202:5301::12 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549999925;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:From:References:Cc:To:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=srsW5XV2evoYsiR+WjtWPqDx2l+Rpp40ZvD9oBayhVk=;
	b=i+kTKK/NxzBcr5nZukur/KsIlAkAZOcho67dt/fUk3fJtTIRp97XJfX19Kb7VCEKvK
	X0pXps/5/6LTWlrvID0SPQXv4yz9WYRWdTt7ysm/oTz+mng2Sgh3CozqZb2h/WoNzae3
	66tQzktG0DCrK01CWNoMpUwsec4VJzg7DkWdWGLdYv4wsk4qfGoTxtLvQVAIsuSwBm9p
	6Aw3+oqXrRtqobkW9hkfx0/dk7y4xky8P+9U2myNPzlM+Weoe7VGR+8A6igQvlWwCwut
	7M04ixdj8D9NK8NpmHJ9A4bhDdmXZ5zqzVVmhR4Gf8oZMQT/zIrep9VONYa1qA13670w
	EPiA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CldjiKRzWNYwK19ivDpIsfNmMN15w=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:b071:4d43:dec6:a483]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1CJVuRuI
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Tue, 12 Feb 2019 20:31:56 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <20190204123852.GA10428@lst.de>
 <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
 <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
 <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
 <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
 <20190208091818.GA23491@lst.de>
 <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
 <20190211073804.GA15841@lst.de>
 <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de>
 <20190212152543.GA24061@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <47bff9d1-7001-4d92-4ad1-e24215b56555@xenosoft.de>
Date: Tue, 12 Feb 2019 20:31:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212152543.GA24061@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12 February 2019 at 4:25PM, Christoph Hellwig wrote:
> On Tue, Feb 12, 2019 at 01:42:56PM +0100, Christian Zigotzky wrote:
>> On 11 February 2019 at 08:38AM, Christoph Hellwig wrote:
>>> On Sun, Feb 10, 2019 at 01:00:20PM +0100, Christian Zigotzky wrote:
>>>> I tested the whole series today. The kernels boot and the P.A. Semi
>>>> Ethernet works! :-) Thanks a lot!
>>>>
>>>> I also tested it in a virtual e5500 QEMU machine today. Unfortunately the
>>>> kernel crashes.
>>> This looks like a patch I fixed in mainline a while ago, but which
>>> the powerpc tree didn't have yet.
>>>
>>> I've cherry picked this commit
>>> ("swiotlb: clear io_tlb_start and io_tlb_end in swiotlb_exit")
>>>
>>> and added it to the powerpc-dma.6 tree, please retry with that one.
>>>
>> Hello Christoph,
>>
>> Have you added it to the powerpc-dma.6 tree yet? The last commit was 4 days
>> ago.
> I added it, but forgot to push it out.  It is there now, sorry:
>
> http://git.infradead.org/users/hch/misc.git/commitdiff/2cf0745b7420af4a3e871d5a970a45662dfae69c
>
Hi Christoph

Many thanks! Your Git kernel works in a virtual e5500 machine now! :-)

I think we have reached the end of testing! All things are working with 
your DMA updates.

I am looking forward to test your DMA changes in the next merge window 
again. :-)

Cheers
Christian

