Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F78CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:52:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65DC0222C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:52:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65DC0222C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 023908E0002; Tue, 12 Feb 2019 14:52:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEA488E0001; Tue, 12 Feb 2019 14:52:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB23C8E0002; Tue, 12 Feb 2019 14:52:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 955398E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:52:54 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f202so1025336wme.2
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:52:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8w2RioPPb3fcOgL0lYR0P8fevziE/gYh68Lyxc7JNno=;
        b=FGeVJH2hkccImufnDk2HbYPMDkl+7Jkp5o6yfbNBwALnlPmVAj80Axadh2ypsesgTO
         WRqsgjzBzh+uuWHKY5kJXGoXLXJ5R+JErzRTeJtQg44H2sD06j8X5/ymFxrlWfc3dFPT
         aYDh6hCmQGGIwujllhtB4M6E7LDmvmXen4QAFTC9OTodFdx3qQS8fQKANB39aI/IEczY
         3Rstg6+5wdYHgE2RuRSaG78t4TfDT6hoY5QRGZAF7Ct9cTzvyCsqja61y+sTcmn/Ozcp
         25+FCFL9rVWPQGjUssthPzwcOnilmdAVx0zHmL70ZKHf1noF+Stpv3a7XVuSnDU0N53P
         7XbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAua5RckVgbssTo81f4/CAQfZFtw8eDWqDerglde/ms5jS92AXhM4
	mpxa4W2uXwqLzC1/JKU3bx3kHiHrVec72A9hKI9diC1X/HgiIlTDKLQYzdUFZPiuYkVP5SdUg3D
	AeJVj6DUCjJVQJ91+bVeu+Bv+dMMCHKulI87O6sk+KSdKOrPs+5b/OiJf08ZhzZYamQ==
X-Received: by 2002:a1c:4889:: with SMTP id v131mr409863wma.146.1550001174150;
        Tue, 12 Feb 2019 11:52:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZNRB0ksxn7gWNptnpLfcsr5JclFkr+KNuyyyu1CGDwJP1kuGX/C7WN9qCiv786OjarBf3s
X-Received: by 2002:a1c:4889:: with SMTP id v131mr409824wma.146.1550001173481;
        Tue, 12 Feb 2019 11:52:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550001173; cv=none;
        d=google.com; s=arc-20160816;
        b=F0dTfJS2HaEByvh/kVflyycu/a0ofOm8FGEjTlNa2pbLLwDD9INYL66GXoBn/eoCty
         MJY7K+DoS+R/eCTOh67khKq6DWH3F23bvemJ/tuI/8xbJjmktz6SsRRV7d+R+pQEYAD1
         HMqBKR9s/Q9hqRYo3XtnLH2JxHENa3WERxGuM4QUsTVr8+gNoYgDIu2t1gezqLoJGVSW
         SQTU74jqk/Ww01nwn2TizWw8mpy/nLP6asFGFLIg69y4whVIMTIVyEBjzRPnQUdKkYOQ
         2QuJCt+2sbFUaHJ6nf59f0XeSET4rgv0HWdvuqZDDCz7YNaOsjmhzce98fHzwa/Lki1i
         pZjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8w2RioPPb3fcOgL0lYR0P8fevziE/gYh68Lyxc7JNno=;
        b=d1rav0Xk1MsfGnB3asFv6r4GyWNWzzAPJGqApGK3qTPhvkUfdLDUwFXtz4eBlaUc8T
         iFYF9BVoKVp6RphFbnOip0aeiqGJ1jd8hGDanPLiqnS9FrempSDJaywW2CGNQ6maFARJ
         97/Sbo9PeBWP4vOsaDLKYJinG0lTIlamZ5aKdVH5j6HiIujVsMxLMBJ555FhHE2cuKpE
         uIyqZyqh3abIyww+QCTzQ3wDTKzbWkzQqdRo1hQLTlvP0rZLjAZGhXVmQP7HM3sqHlO5
         h8OrVNJg1Cc0YWwSJEXwjW0NPfyKRNhf26n6NYGq+MnHOJ4pedzAk3QNl2SIN5eCReou
         oDXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y18si6672428wrl.397.2019.02.12.11.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 11:52:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B954868DDC; Tue, 12 Feb 2019 20:52:52 +0100 (CET)
Date: Tue, 12 Feb 2019 20:52:52 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190212195252.GA29370@lst.de>
References: <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de> <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de> <20190211073804.GA15841@lst.de> <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de> <20190212152543.GA24061@lst.de> <47bff9d1-7001-4d92-4ad1-e24215b56555@xenosoft.de> <f57e6d8f-d43f-e9f8-b092-e43f5019f86f@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f57e6d8f-d43f-e9f8-b092-e43f5019f86f@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Great!  I owe you a night worth of beers at a conference or if
you come anywhere near Innsbruck!

