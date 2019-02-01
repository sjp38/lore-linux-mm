Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C4A6C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 08:05:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B088A20863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 08:04:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B088A20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19BFE8E0002; Fri,  1 Feb 2019 03:04:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149318E0001; Fri,  1 Feb 2019 03:04:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0602F8E0002; Fri,  1 Feb 2019 03:04:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B73F08E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 03:04:58 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f6so1511759wmj.5
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 00:04:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AZBOLv0ks3qMc8DsnLKA/7i/xbrJS29KmoRt+UjQ9fw=;
        b=IdWXuKZgfYGCMqShJ+PlvIIaPHU40CpJvH4aEQ2fDQh14JADVD+RgqPC3KArfOofGE
         zmwd3ivy1PkE+05zi0X72KK2hmImQW7gL2sbtuCl4LbHf5K0DTpF8A+VqIr27ge98fAT
         YtuTYafVsx9mYlu3Mb7K2ja9S7KWZ+nMbqhXcaRetg3fYt8noansy8NoMogGJzyigacl
         w0t7Fb2S9HbSvyx43eM/a8E14qIiMyQalhO+81KKiU8nS2qjEYV9uTBvI6v/xUfWFKgx
         cnIZiesk/K7Io8o4EhhIRDqfkypKrKw5DhvSe8Pg5cBJlWpXa/x1DK7oiH+a7ycB2b7s
         DXRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAubD3a7ZNTKW8HqG/jKls6HOUJ+aWXmgi8sQh0YHBexm1QkqvbW4
	fJYSoAtV2mXjr3R67S9IYBjocI/X4enZWebUxdw/+RK7x0nnbc8ux0qmE39XDoV4qm5ZFJTXds/
	VWi4dVZPU4jH39bsSWVsXxGAZj2DFxICea1WTDXoZJ2oYYpavIuwf0XPvapQPjBoBDA==
X-Received: by 2002:a05:6000:1144:: with SMTP id d4mr13667522wrx.136.1549008298287;
        Fri, 01 Feb 2019 00:04:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaenvUWgL5yhPMWosblhsteIr1yh5MWtrwCFYOYl6DRSSgZ55WRaZIUDW3W7kOCsEU+UmEC
X-Received: by 2002:a05:6000:1144:: with SMTP id d4mr13667468wrx.136.1549008297517;
        Fri, 01 Feb 2019 00:04:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549008297; cv=none;
        d=google.com; s=arc-20160816;
        b=Ov0yseYU19Luva3GN3mURrImGIIRpjmf7YHyxWQP/mjBQ1sdRCzSnUAOmrpgOo0F7N
         rC7cOQ6kfv3eoSUHIn8x6gQsXMaJ2/GhZktttOJym2tTp2Shd0Zc4swXrr7j9l3K3RWX
         k7VUmct8PKSc2RwRx4eHaMTEBNyxO5PThj3tFvQF77IRrJPf3Zm3v3lTwOQmtMhWmyzo
         fiHmZj4Bf1iuU5p1IwbKIogNwnrcGk1wotX6MR8AlVXZ3riAR3hwCH5TTudjrjupyxxH
         jiIKCM859pWPAkTpXlsLvSuCIu0B4fBOIinh3SqwrnHNiYZrqG0o4MDbtkuAWK78OQlA
         CrtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AZBOLv0ks3qMc8DsnLKA/7i/xbrJS29KmoRt+UjQ9fw=;
        b=v15waBpFth5mTL457wRD5SyK5dMDMUcijzvPV9Kj39zgrZksx7KMkkk4WjkIeeygEw
         xiQZy1QnxRD8Z0T8o9hYI9grkF7LAnmZAUGtOfEgvDi2I9giG+vHLDB4hC319sQjyS3O
         2R0itgZKfoaReyBPBdZwkQrYBi4gWxQpiBbyJ2wv07/USF7ltkrzS4oAHhRfbk4htQGV
         RHpnoajvz7AXfbgZu00IbvI0xl4baIh2lP7ApSi8sDVWoQmocEplWHWRzFmq07jjZv+F
         qRh0PPbVLr8s37hY7kE5/EfKE3AysXRaIZPO6JENrQMtPFn5Eg2PGoEEF5n81E7ghhK1
         Lxew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m63si1134057wmf.145.2019.02.01.00.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 00:04:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id CE91768CEC; Fri,  1 Feb 2019 09:04:56 +0100 (CET)
Date: Fri, 1 Feb 2019 09:04:56 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190201080456.GA15456@lst.de>
References: <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de> <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 01:48:26PM +0100, Christian Zigotzky wrote:
> Hi Christoph,
>
> I compiled kernels for the X5000 and X1000 from your branch 'powerpc-dma.6' 
> today.
>
> Gitweb: 
> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet doesn't 
> work.

Oh.  Can you try with just the next one and then two patches applied
over the working setup?  That is first:

http://git.infradead.org/users/hch/misc.git/commitdiff/b50f42f0fe12965ead395c76bcb6a14f00cdf65b

then also with:

http://git.infradead.org/users/hch/misc.git/commitdiff/21fe52470a483afbb1726741118abef8602dde4d

