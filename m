Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21FDAC282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:15:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE1B42080D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:15:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE1B42080D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8528E00C2; Wed,  6 Feb 2019 10:15:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 751018E00B1; Wed,  6 Feb 2019 10:15:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 640A48E00C2; Wed,  6 Feb 2019 10:15:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20F148E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 10:15:08 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h16so1569634wrp.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:15:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xNi3wYWX3XQ135uT0Lkj2vOo3RcKb73cHHue4rq298A=;
        b=MzZDrGmGmv2DZYrQW9QTnq70JnHfYYzEfg63OGt10GtEq73hG1FJkTcqciRCd2esAm
         hAKih421VWVAcOdOEI0Fw7/xMu3bAuUvRxdI3U2YSdDGoEsAYzFOBAuH/81yLInXi025
         OQ6DvAFY72L1KzVM45WhlRapO13Fddb/MKchMPROszDSxUmGK15ns7wqIQ4ZPPFxL5kp
         57nv8C+xyjZ2PYRFaI/28FhIAdVdKhqRmYHDB/yKPutj/tFomxVemC5jeGS1SE/igUw8
         Jh3SH9EG///wh9gOUwhjYH7Loc5Dq3zRSzI+vNvMIi9uNxK7ZtDFvaLoTKgQunC50o2y
         yNQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuaxuCvS0pNsD9SZLyunH7Zv3wWPXFiC0bH7oJlErs7CPdHH/TWw
	Gb7eXUr6NhBfM2DeADjWMu7UoDCrqCboSQ2JcdE7N3ihYomFmXHoejQqZaOXL3/aQWcgB6/5V95
	qF2xFyjmfcEv2K+xgIdAstg61OaP6MXpcqLIkrhMotIUhsVxL7r5DRhvf4T1zcMOCnQ==
X-Received: by 2002:a1c:4d12:: with SMTP id o18mr3693413wmh.71.1549466107651;
        Wed, 06 Feb 2019 07:15:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0frQcJbNZApaMMnr/WTA80HHs0/YHuLpVbPb4x0YZxUw9KTd7oiGExjYlWKeHiJz0DLby
X-Received: by 2002:a1c:4d12:: with SMTP id o18mr3693357wmh.71.1549466106786;
        Wed, 06 Feb 2019 07:15:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549466106; cv=none;
        d=google.com; s=arc-20160816;
        b=koTN7F7wsgESlNMMpizB0bIGYFrAqv5iAecVA6gxdO6FRopGmPzlroWCEE8yDxy1d5
         k0r38zw9gwbGAKemSvUUPIabuaBOMoc5+NRShMfPGl0A1a1+1Z0dVtU9YrVyhRieVGiH
         LFjyKreP+58K3FBkm+akLFfQx7LqWbKtEwsqQccxv3AaTKhywJTOJw5HZlNueWwNQXg5
         o2YVuFYnZFmfOuGpVFVffeJ5jfOfNRLZVz/29zjumO6Z+/XCAZdY43dJ6/lMAQYqRWPW
         QxJOAd6K9akClhGJ/aV1XfZPxwGaO2xWHy6lxjxf1gptWAupJSqBwSqYbgkEZhBPy1VQ
         vdPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xNi3wYWX3XQ135uT0Lkj2vOo3RcKb73cHHue4rq298A=;
        b=nItdNIBaQgJXg9z/pCu+2XtXTmPWY1QoZoH9uLN2xcwAU+JHXW58hTCEp+IoXZtNLA
         gtLsLAP5kexoyYO7lJ4crDPo8VkbJxGAPDtQlrJf2F8Xnqr0tRpJp3oAa5tMZgaqAG4d
         whHs5v6/vPo9wy0M84xdDOHh+6pcTSMKsR3rckJ5J+ASHSuB4v+uY18hc21F5BrpGiny
         2owsLltiqPFYK9INaAf4wzYh99ay7mALanMjnRMLVxoz7YIb6EaDGB9yLOZyjcOkEMxQ
         XpnjnTyrBPzDBEgOoj/gr1HxhSid3lGU13MJc8H6ZSRIkI+Lgh/tLOT7xqt4q0b5e8LJ
         4bDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r16si17990458wrp.189.2019.02.06.07.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 07:15:06 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 111A568D93; Wed,  6 Feb 2019 16:15:06 +0100 (CET)
Date: Wed, 6 Feb 2019 16:15:05 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, Olof Johansson <olof@lixom.net>,
	linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190206151505.GA31065@lst.de>
References: <20190129163415.GA14529@lst.de> <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de> <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 02:45:34PM +0100, Christian Zigotzky wrote:
> I patched the source code from the Git 'powerpc-dma.6' with your patch 
> today. Unfortunately the P.A. Semi Ethernet doesn't work with the patched 
> Git kernel.
>
> After that I tried it with the patch applied over the working setup again 
> (powerpc/dma: use the dma_direct mapping routines). Unfortunately after 
> compiling
> and booting, the P.A. Semi Ethernet doesn't work either.

The last good one was 29e7e2287e196f48fe5d2a6e017617723ea979bf
("dma-direct: we might need GFP_DMA for 32-bit dma masks"), if I
remember correctly.  powerpc/dma: use the dma_direct mapping routines
was the one that you said makes the pasemi ethernet stop working.

Can you post the dmesg from the failing runs?

