Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60608C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 07:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A329217D6
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 07:56:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A329217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C03598E0039; Mon,  4 Feb 2019 02:56:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB26E8E001C; Mon,  4 Feb 2019 02:56:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF0E88E0039; Mon,  4 Feb 2019 02:56:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF398E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 02:56:19 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id a11so5299542wmh.2
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 23:56:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cjcFFuoQjrurZkYJiHSUB1V1BrlZ0B8oMNM3sO9Bn2c=;
        b=ti83bwBO1ewQVhgeIM+leWMXLqZm/Kl1gjsu3TRlHs1v3qfXDd1cvLdl0If7x3gydl
         guEPEJiLu2kCIRPk/fuK5q5LFgkNLQA60BpzK7R6tLz4C6+H7wfcZTAIrqsPXyUXAmBU
         LnCh/ZtJmAtQ5Jc4o2FRmEWg3J9LRcD8mWeZ6Ohhv44t6aESBk4MLDxyz0N/7rHAyods
         Pn+ceG6ADCFjwmhmERmJZO9rhSZ/DeGLypRan0f/nlCdWDvWw9Au4Z7fY+P2GG1rli7g
         u4OJiR7Y9Z1sf5snaBBgeUW5XLK13G4Gb4gAv6Dy8cmlgvuagy4dbAUR6k1pu3TR1ZWX
         Im/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuZVNPTu2IAbWQsy7iCRoOKpTvBQEUOqKUaIghBsHjzjFTWEPwpL
	6WkUCyecgYgie+cdMSY720PDbfzJazOLhwokHbdEmUmvfGTjpGC9RQKpR4L9oQuThx5JAzogX/K
	3qkeDOgT5TWQ0AkExYlF/s/0IlLtefdFqaBEbYWqxyX7Ik91SAzrxHH0krJ0P7ZuUuA==
X-Received: by 2002:a1c:f509:: with SMTP id t9mr12887323wmh.76.1549266978820;
        Sun, 03 Feb 2019 23:56:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYBjAyIBNIBE+pvzTrMPg9jaaNa1V0vg5xWt1MbQCgMzwt9QS74QsPjnWJhFKNXxnzb0AR8
X-Received: by 2002:a1c:f509:: with SMTP id t9mr12887273wmh.76.1549266977869;
        Sun, 03 Feb 2019 23:56:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549266977; cv=none;
        d=google.com; s=arc-20160816;
        b=DV6uh368fDSL/JI5fSr5XwAFvwLNnMEzRwMZggxqcAOfQIReb0LWtXPSVrW8wqEiJ2
         jrYoLt4B8k64bYH1nvJFt0msx7Fqfv4H8Rezbj6C1Bwbwjw7WCnBgOjED2fkFgRUvZ4f
         RuntsyLx8ixMTcR3lhl3LiEl6/uwltvYHgnW1zIclZ6JJ8gKUKxOAePr5wu225Z3y3R3
         g8OtGEnu0+lNtNHyo0zSYYMvQx05wzf0Iw5FWbkifZoVvo96qChbwsB+ybbGbQv3hHAg
         CRLwCopIJ/HsJ/80bxDe3XYaCo3pQl9hBTUfmVxDbnT94xK7msBcNk8Rke6t9rx/bjYT
         hpeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cjcFFuoQjrurZkYJiHSUB1V1BrlZ0B8oMNM3sO9Bn2c=;
        b=kB5Erb897HSHYltQejEwxCUfVk7yTslsqvzSm9Vv/A2ucAXFxAOrBjB5X2Vz40degp
         UOC4EQduOtt/lPlHIfNA53HNWpnUyfLd3pJhOA8AIRnrbI78ta0kgD4D5jN5d1T7mQsT
         SFt7Q2ok4EgOSOWSOdf1s7W+8T70O5A6SRX9mKeitkGKz6tkhABhNrH3hYvkLRFNZ70V
         6Qfk9fwNtjnVGUNcVzt7BnCjxYFHgQgutKAazkQ+Sqbzh6Y1UT8EZu9cC7nO20iKy5OY
         smvBvg9PWeuZ+ENDM2GSy29f43UsKN+tvUg1OwXqhsOZjDkQYZvsUL2d21ayw2rGqBI9
         h53w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s9si9913963wrm.42.2019.02.03.23.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 23:56:17 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5CDBD68D93; Mon,  4 Feb 2019 08:56:16 +0100 (CET)
Date: Mon, 4 Feb 2019 08:56:16 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190204075616.GA5408@lst.de>
References: <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de> <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de> <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 03, 2019 at 05:49:02PM +0100, Christian Zigotzky wrote:
> OK, next step: b50f42f0fe12965ead395c76bcb6a14f00cdf65b (powerpc/dma: use 
> the dma_direct mapping routines)
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> git checkout b50f42f0fe12965ead395c76bcb6a14f00cdf65b
>
> Results: The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet 
> doesn't work.

Are there any interesting messages in the boot log?  Can you send me
the dmesg?

