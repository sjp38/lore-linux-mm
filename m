Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 392DCC282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA04320821
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:43:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="MZSHs2A0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA04320821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 979D58E0012; Tue, 12 Feb 2019 07:43:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9269B8E0011; Tue, 12 Feb 2019 07:43:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83D398E0012; Tue, 12 Feb 2019 07:43:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F20F8E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:43:04 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id b12so989553wme.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:43:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=eKLC3wnjS0ITavNG6BmsDxnHT4lHbHcc+BrIvQ3BRho=;
        b=GCrouXl6jjfzbD1uti/66oGn0gsDQAC0B4GoYC9dB4setXxKZ6jvPI7bFCRxU0FF2J
         yrClPI/F3HQ9LClbOr/3tZPqlXSijJlrZMqhK9E41iBOxMyPJLpiqy+R4LA4swZEkvtz
         VhZZZHZh2Xq8JGOykekYfG0mmk4q5ArxmbrxVVBrt7+L80VJi1z4x9hBXF857Q6VkToW
         ur5IYXWwu4foUMjdBJLuY5dRusKY1ptN6kfITSXIrm0EzeiDSS16X6YqpHqY3tOi/XAL
         zE2dWgqyFfyBLWUxn9Ypog/pCEebcJ9pzaIhRBUbVC3LU57fX/VkXm3ISa9gTkCFaaeq
         pKgA==
X-Gm-Message-State: AHQUAuZZ4SfjkxgKYq+E4D7/gx7wgp6jqgmDFpjTeQa9hrYy5O8EFMuU
	z4qJSB5P5NZPNqOEfeCp85+xq6AJAIBLBUYU9KHYGPEEjdUQWgWLMV3QX9Shzv+WPExh/staK4N
	mrAeOXq77DQyeLYFc4XgmAXrjP7LF5ns5AmMk8mTdvWYNiZcD4Z75JUMiy4Igmi6Gug==
X-Received: by 2002:a1c:1d15:: with SMTP id d21mr832039wmd.132.1549975383735;
        Tue, 12 Feb 2019 04:43:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYpmKPu7gu2jS52KTE6u/k16txYtJS3e826ZWatRHYg6O2vK/Fne/c9MKeFhG5T3phggKIc
X-Received: by 2002:a1c:1d15:: with SMTP id d21mr831992wmd.132.1549975382894;
        Tue, 12 Feb 2019 04:43:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549975382; cv=none;
        d=google.com; s=arc-20160816;
        b=ci8lFueAJH+VcuYeYtpUuDGTl6OO+hYWPLx/ZISc5yX/slY6/1x89uoU9QVOD+WcCd
         TOVr0gtDQ0WhmzIGuA1uHwRkVQvmHDC3IPwgb6kYRndNh4I9ix10rv3PDVpm5PJUDxvD
         omvHtjRmNwA5+E0g+iZ3uZMsemAiw/aSyvpXs3y1jCIJakxFVc2ib9wQ2E48Y9AOhBgY
         YhxE0dDIvTTW8wKBiljR/y3DAeNsAtj0i41A6/Dfh2TssZ+F2uefLQOVOcjiWjORFqjM
         FZWf9Evz0verSsmTKCYUKY1bj2n9CVsfWPG+RJXywu/gCSnnS0sk+aFhsen3d/Jz4CJG
         HDGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=eKLC3wnjS0ITavNG6BmsDxnHT4lHbHcc+BrIvQ3BRho=;
        b=Xr+Ule87ca1qnqEgv/L1y6z6GEYNW0xPTGqPG5gqUnS3QwUyfuDi7UVWbc0zvkS/V7
         DZdCHPWYkv7hHe5gXKAftEsny1LaAO3E4lygpo+Df7ySwwD474UEGSQDFFOJRkRf8/Qu
         WDirWnmOgvaEbFr5p7hOYp/doSGJe0R8BY8phVp9DEcSOvSlMn8el58qxT/9OE5sFanw
         4CUt+6Jc1XpPOmvgjg6pHmJQyGfFEwYftkEriAoahiLsMA0ZK/z47NNNDxWJqo4+p3IA
         gqawkkQjQfYBn5ykVnwSfUdgRGiDz9gy5C7DTNLy0j+T9bawoclfk37NqdhV2TiN0e9X
         YJgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=MZSHs2A0;
       spf=neutral (google.com: 2a01:238:20a:202:5301::7 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id h3si2804130wru.441.2019.02.12.04.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 04:43:02 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::7 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::7;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=MZSHs2A0;
       spf=neutral (google.com: 2a01:238:20a:202:5301::7 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549975382;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:From:References:Cc:To:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=eKLC3wnjS0ITavNG6BmsDxnHT4lHbHcc+BrIvQ3BRho=;
	b=MZSHs2A0hXJ99fRotaUQDz744j/MuVn1GiC3i5Jq2//OR0uuzdtoFOb3nrButG4WW1
	pgTvrDQLlwqFJfirPf8rDI4OVrTo/utST3bbgtr3Hd82Ok/X3J7Pvf4q+PuRNYTcNbdA
	KzeJ9JEJ7imt58AM7sHGg+/LweMJSQJh6kgYDXWq1TPa+UYx4ySqDNyDWx/yNCqq6GiV
	aj523UIzb5qO0dPDXOAiDRvpBZmca9OO5oxrjlERDd86Zg7YkmFiv2LiFjlKiLOMwVe4
	D7uafxXwaDRrZym389gtqRPpL7O0EL0o+HlqeZWMakFZlCxRHl00xklfuzdLpXu9Myu/
	fEBg==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7ClcioYo/H7zE+E9pbb1CjeE951P"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:c4b:ac82:e1cc:51e0]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1CCguPCQ
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Tue, 12 Feb 2019 13:42:56 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <20190204075616.GA5408@lst.de>
 <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
 <20190204123852.GA10428@lst.de>
 <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
 <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
 <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
 <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
 <20190208091818.GA23491@lst.de>
 <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
 <20190211073804.GA15841@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de>
Date: Tue, 12 Feb 2019 13:42:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211073804.GA15841@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11 February 2019 at 08:38AM, Christoph Hellwig wrote:
> On Sun, Feb 10, 2019 at 01:00:20PM +0100, Christian Zigotzky wrote:
>> I tested the whole series today. The kernels boot and the P.A. Semi
>> Ethernet works! :-) Thanks a lot!
>>
>> I also tested it in a virtual e5500 QEMU machine today. Unfortunately the
>> kernel crashes.
> This looks like a patch I fixed in mainline a while ago, but which
> the powerpc tree didn't have yet.
>
> I've cherry picked this commit
> ("swiotlb: clear io_tlb_start and io_tlb_end in swiotlb_exit")
>
> and added it to the powerpc-dma.6 tree, please retry with that one.
>
Hello Christoph,

Have you added it to the powerpc-dma.6 tree yet? The last commit was 4 
days ago.

Thanks,
Christian

