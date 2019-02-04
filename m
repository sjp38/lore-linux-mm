Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7CB5C282CB
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:14:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 943912081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:14:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="o2hcn/kh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 943912081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 305F98E0040; Mon,  4 Feb 2019 07:14:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B4798E001C; Mon,  4 Feb 2019 07:14:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17D248E0040; Mon,  4 Feb 2019 07:14:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B626F8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 07:14:03 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id p12so4405233wrt.17
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 04:14:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=XR2rLJAYU/hZNgFiDPi9cMSS22UeqMZYvAHXe2JGgQg=;
        b=U/SAO9hdsZkE4Ezxv3kGZ1l6S1en3AysRAizKpcvZtRZYnHS5l5O1nej8ltfW7bGWX
         nMqzh/k8OHE8amSY1ulIrfu/zJobZBsGcFAlNRZxG8Q0vNNp53qppbN4JPiPJX8SpE/T
         JkNleJRZP0SHd6EAvFwWfKjmoKUPZ7aLfHufzDVV0oqJOMOahSKbUnN6i1AISR/yuMjP
         WQUxD6+KlV0OBNbI+LhQ73X8xGopEm6zo0Jg66EXoUVB0rodzZe7XNy6LDdJBcqw220V
         U9GLQQG6yIU8LidK4zH0VaMWsaIdVdPnnSFQJ3DKdEYy7TJb+onRVLZjYi44UtQcNzqx
         ko/w==
X-Gm-Message-State: AHQUAuZ6KcpNpF2/+iivj0eoqpSIcHV+CksFo89Ys8d7o67OLEdv9wSD
	iBUY1b6Lpd/Rj2rJEYXq6yBpw457rYdHD7ks/KzyCzNNy7sn3nGt0fF69DQT0vDPXbV4s0DXA1S
	d5nklObtz8uTzFYq98m1qH+b0N6ttd+gZpRsepXMAWq/qfwCeVQdKhc9vnVvV9ppNNg==
X-Received: by 2002:a1c:e18a:: with SMTP id y132mr14099589wmg.48.1549282443234;
        Mon, 04 Feb 2019 04:14:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVZsHdogVJ2Jnq55EWtUCOePVNyTdmTo9jiF1tTlFY5mCoyO+mgSVxyscNOClu1gcOtocQ
X-Received: by 2002:a1c:e18a:: with SMTP id y132mr14099523wmg.48.1549282442252;
        Mon, 04 Feb 2019 04:14:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549282442; cv=none;
        d=google.com; s=arc-20160816;
        b=o7LMtMd1Epvi7Q91jtEG1SG+hNfeJSzKg1AYyii57lbdLF/i9ii4e2w6OptUotvxj9
         nyDOs3+keWaUgHzDnBhESLbyIF5F71w58pMYs2UuASklPH+i8jmhThjQSZ41FgJEMlNj
         Flyj6/9iVqzaC/DEHfRNvTFRGdR4aCjgOORBhL4kVXBdqAnpvDaO+/XgpvZ/D6Vz7hEq
         72sxrbhfZKcmHwp+Sgc+d26Fn4R99ZiNKhLnlwiovbwizVB1bEveIlTpChZ0n8XSEmS7
         6EyefJcFwcQW+KO0tTWVGcGZUnAUA1F0T/3dKJjHgpBp6SDRNKqmOSNdxwSyNWQN3b4S
         Lucg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=XR2rLJAYU/hZNgFiDPi9cMSS22UeqMZYvAHXe2JGgQg=;
        b=EUwZEecllNcgZqzxDx7mGoIH1fBf/QGKQuTckc/yQis56Rt0FkDQPYM0Eoosu4AAeu
         ucaAFqODqWHRjAJLvLARboVCMaoHpGyLEV+rBDg7Ii4gS1OfleTYNAELW3Uq3OjFBox7
         gfIIgD8upFUuiS0eWx9n1qB6sgaGzWmnqBtRDLXmqeyyhDhfPE5nmaejFyTs+xZn390s
         0+z66xufyTRR9iVKE9MtDWNe0zYa8NFlcxN+7ivbuptK/bR0KGIHUZU1+NUiuvhS2D1Y
         geWW91LEu2Cn8+FFJwp9DS90ZEt/G3cdyVBO4vZg5iJ2HZ7s/ojTvZ2mkH55F87aD6kp
         S8VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="o2hcn/kh";
       spf=neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::11])
        by mx.google.com with ESMTPS id y7si12744143wru.306.2019.02.04.04.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 04:14:02 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::11;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b="o2hcn/kh";
       spf=neutral (google.com: 2a01:238:20a:202:5301::11 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549282441;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:From:References:Cc:To:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=XR2rLJAYU/hZNgFiDPi9cMSS22UeqMZYvAHXe2JGgQg=;
	b=o2hcn/khFih5nkJVKJvp2obd/Suu0o55f/oiHmKcxvq+FpHM5RCi03Fp/+sR+mQTYz
	Vs1Q5acGF1HeZkC0L+CTYX8orxQrIxI0se9OzOZAX+I2WaHsA7OFRhXaymzBQG+G1iQF
	Z9oQ98ao9FbSLR1fYxgmbTmk+WphwISFupqDxGUg8dDwXmKIPV+hbA868JZajMgAwLwc
	HK0pdnLUQFt1XfOt+cxzLleOEIJlT5BYhKtV1V7RA2J/JKb/Z0PkCMRSwoeXB202tapn
	36ZDH0NbKmiovSmaemfseZZzk8o2ylTAkEXxbO9bfvlyQ/DXJoK/GEOZ3jk1UaQkg74G
	MXEA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CkN2lxaMsNEtm2M+aQCzX/y4aXO"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:2d84:d264:dc2:6095]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv14CDsgJt
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Mon, 4 Feb 2019 13:13:54 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <20190128162256.GA11737@lst.de>
 <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
 <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
 <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de>
 <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
 <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
 <20190201080456.GA15456@lst.de>
 <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
 <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
 <20190204075616.GA5408@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
Date: Mon, 4 Feb 2019 13:13:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190204075616.GA5408@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04 February 2019 at 08:56AM, Christoph Hellwig wrote:
> On Sun, Feb 03, 2019 at 05:49:02PM +0100, Christian Zigotzky wrote:
>> OK, next step: b50f42f0fe12965ead395c76bcb6a14f00cdf65b (powerpc/dma: use
>> the dma_direct mapping routines)
>>
>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>
>> git checkout b50f42f0fe12965ead395c76bcb6a14f00cdf65b
>>
>> Results: The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet
>> doesn't work.
> Are there any interesting messages in the boot log?  Can you send me
> the dmesg?
>
Here you are: http://www.xenosoft.de/dmesg_X1000_with_DMA_updates.txt

-- Christian

