Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7167DC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161AA20863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:26:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="JkwusLut"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161AA20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A097A6B0003; Mon, 25 Mar 2019 06:26:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 990DC6B0005; Mon, 25 Mar 2019 06:26:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859866B000A; Mon, 25 Mar 2019 06:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35C346B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:26:48 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k17so916126wrq.7
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:26:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=i/dGCf71cqBarbVkvLDKse6m1paYOC5pSFEdRoC6Q3c=;
        b=YdkDXvu9bxtsWPSEEJXEZa1PB4xjCIRllymjAm68y09EOM49KyXtPZGedNFpFU+AH+
         HxTRSecCdZP0d3V1dKYGxeMd9CbUrYPIzDiqWR/jywYgh9Rbm21pn2MOmbwuz5yHohvi
         Blv3v9MEXVue4RpcsCf7W1bacpKZUaU1a5N9x8EhYDbu7G+U+BpSHpDp+gs9rKX3Dshd
         a5DIfRPlqXzesPlw3+XxmWJ7+CD0j3s+t9uve1EY9+aPVKTvN1708LPJMue6JXBWm56Q
         xq9/QsVgrr0C6cNBUdtXQEHL60sezVdaPPbfMZu+0D9D9ZeMP9HWiNmL/b/f0ORLg1az
         zZEw==
X-Gm-Message-State: APjAAAVhu/B2cYzWxbUEwp4S8BCXWi8p/iRXGiqlq71xe0Hj+XwX+DPa
	/0d14oAIPFtev38yWtQ7ZZ8aP7d1n12uVQ9BTgQiWSVVDrP/Mpq2cyVq7mOc5ExXIC/p0X/5T2O
	HdE8AtD9DYA/SgElSWQHmcNQPNesZJ8s9pSLKYJYdNUlh6D5SWo1+k5AaP1TYbK5NTQ==
X-Received: by 2002:a1c:1a46:: with SMTP id a67mr4670984wma.21.1553509607721;
        Mon, 25 Mar 2019 03:26:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKgguxdicgSAV1I6KTfKu11uA7khX1cZbfHrAYmvkhWNfc0DKpCiXKVOJheaU2RooQP2hl
X-Received: by 2002:a1c:1a46:: with SMTP id a67mr4670933wma.21.1553509606914;
        Mon, 25 Mar 2019 03:26:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553509606; cv=none;
        d=google.com; s=arc-20160816;
        b=jCU3FwEruTsGxyWOHWN1q+KCG/PvwGXRiSHdssBOLExpLaSMcHyMforNZGpj7d94no
         dbQAtuTWDHjY3L7+mCvARfzzo/CAMSUWve6OYmTLW1RNEDfpqL2bAeStgJji1+zKQwjO
         XGk6O94q/oHy6M1VBAcUwDkVh6OoMIkXVi5Cs+u2myHAyFS2iWoJMbRwYgTC0XNTB6JU
         4bdmc+fFnBlTDi/EyDe+rBuVx/7usTucvTyL6L0wbgCUt2gmpv/KqBHOWoG18O3OfvT1
         3rBlA+uUfA3l4jmSyQCRwhKfm9UMyvj+Zy3NCsCrzKAHX3BG1FlK7Fc+XOnKyXVZj5/w
         RCtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=i/dGCf71cqBarbVkvLDKse6m1paYOC5pSFEdRoC6Q3c=;
        b=zc9mMHqhtiempT1jyuCAZw3wxwU2d6QbNP5yhNP3LMCfxIhWu6r0Fx3eBvfEiuCkha
         JAj38vV1J6C49/Ag9Mb4maCK42/st83YlYMa7LRTyd4m/Jk3dwNyuA/fBNiTIz5LgTpI
         FqsJ95XTuR6OpEu2NaQgnYkB4uqcNefu9OxYYLYRvsYPyPkbi72QXXr3OsRI5waYvrG8
         0jhdTxLMHD2VnZwViGAyhb0z8XIRwJ7j2svlnnztdg6qJNrMGP1kx3QXp7vRMGlZ2XFA
         UHFn7DMcEXGodUHp5vtzT1xqHdxluHJI6lU1vf+JcvdglzlNL5GuWON7vmRsxd0Opd5b
         gTzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=JkwusLut;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id j5si9462370wmh.102.2019.03.25.03.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 03:26:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=JkwusLut;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i/dGCf71cqBarbVkvLDKse6m1paYOC5pSFEdRoC6Q3c=; b=JkwusLutfp/9cnc3arV/XuhPn
	qd1iWBFbPbOcDct049ces1dweEmJYMIKBVP2ZfXAbHtQ2tTsGLz3YbTzklr5JeYaR7uGa5xduETwx
	Xyrlasb/SIWEfm2+QUMG368rLfJyyUatcDoNNnz6Xk4spYrMuFhESZ+jeYQXtgbK8XB2BBfLA6h5v
	BfBIS61lJ8yVwGQzOPOPsdoF3o0RqNHundnnTS0Jmi68wcFz3gdZWIRauwTddtt6KcNgmUfoAGVOZ
	5OqzjnEkNz+T2JbJeD59F56KUlMIr/Z6mwigP35utGmEJq1M8cbLgQtXSBNP1lurYUa45lsnXBDdU
	ZYytzw9Cw==;
Received: from shell.armlinux.org.uk ([2001:4d48:ad52:3201:5054:ff:fe00:4ec]:55208)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1h8MoQ-0001vI-R4; Mon, 25 Mar 2019 10:26:38 +0000
Received: from linux by shell.armlinux.org.uk with local (Exim 4.89)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1h8MoL-00031u-UX; Mon, 25 Mar 2019 10:26:33 +0000
Date: Mon, 25 Mar 2019 10:26:33 +0000
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Peter Chen <hzpeterchen@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, peter.chen@nxp.com,
	fugang.duan@nxp.com, linux-usb@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: Why CMA allocater fails if there is a signal pending?
Message-ID: <20190325102633.v6hkvda6q7462wza@shell.armlinux.org.uk>
References: <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 04:37:09PM +0800, Peter Chen wrote:
> Hi Michal & Marek,
> 
> I meet an issue that the DMA (CMA used) allocation failed if there is a user
> signal, Eg Ctrl+C, it causes the USB xHCI stack fails to resume due to
> dma_alloc_coherent
> failed. It can be easy to reproduce if the user press Ctrl+C at
> suspend/resume test.

It has been possible in the past for cma_alloc() to take seconds or
longer to allocate, depending on the size of the CMA area and the
number of pinned GFP_MOVABLE pages within the CMA area.  Whether that
is true of today's CMA or not, I don't know.

It's probably there to allow such a situation to be recoverable, but
is not a good idea if we're expecting dma_alloc_*() not to fail in
those scenarios.

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

