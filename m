Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD0FAC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 848F120869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:34:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 848F120869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 106988E0002; Tue, 29 Jan 2019 11:34:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08CB18E0001; Tue, 29 Jan 2019 11:34:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E98838E0002; Tue, 29 Jan 2019 11:34:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAC18E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:34:17 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id m4so8245312wrr.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:34:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uH61313TFD91ho+K49QjrdMKVfDQiOi5MsFqQ/a27oQ=;
        b=eo81cmKjO7ubSWPHX7dVeGCwn4Txe7Qmq2UmuQhYQ9Ppabzr6gH6VxLA04Vr1kysyD
         E/lSgykUrFJgcG77Q0TeOvqQd8/NDj5+RoGe+Jt66257c7/UOPB6o6onXtuSH6pWn0l8
         t5CuaEBtD4I8hetRXFuji3pC/ZPPFYF4lZ65zaQ2kKoXpgwNH0pkeYFnL+J7Dlg+DVbc
         VpL8lpCG1DXuUiId/BJ9CPp5xTtAz317xHK3Y1nUAR1WKG0Z6+sNZvUbbQsZPmSv45Wr
         zDixU72swCX1wiZNpwXJP4Q2qC0sSSlVKgk26Dc7mRgytZKV8tu/ybnVKKgn8+1jLxgm
         HOdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukck3CtXC3bHsQVQsXHBHYrYuUGPxukCSNG+KToOuhUEUwio1iYn
	hoZ9yFwC5ncPvP9A4YhOYw7shzDP3Gm+kyKS+dFjjwVk5/fsrNa9oSaDv6RBxNPqVQNGFrjJUit
	vZtvZvh1ePL4I4+Am8Mf8flKWr+xvNWS2qDev+5TsAGuwgdNmh7jnFFN1+cSruYWaug==
X-Received: by 2002:a5d:45d0:: with SMTP id b16mr25426586wrs.86.1548779657188;
        Tue, 29 Jan 2019 08:34:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4h/xO3UvU3ZhBFAnc0aqJsUcZ/t6gp/nMbRT9ibogfIyRjla9GUQUIjEFcO+3Bwx5heT1F
X-Received: by 2002:a5d:45d0:: with SMTP id b16mr25426511wrs.86.1548779655929;
        Tue, 29 Jan 2019 08:34:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548779655; cv=none;
        d=google.com; s=arc-20160816;
        b=wyC+nhC1KT2IXPjQm3USlusjZKarUvctRC21El44sQTG4J7OQrbLie6AYzEEF3wa4l
         QaOoaWogtCFLMXLHJJPej2+7g9KvEl+j23gLeAX2iPG94Tu2wjbCSnZwGKr/8ZPjwwYl
         Q0QsrxbqJgiqn8ONOMBXPc+WiBy8QGL8nIgXlET36kPc88rlIXW5EQW41lqHHFqbBvUK
         5yQ2J/UCRa/3V8WfuO6byWzuwb7ZHiwg9icxa+V1Y2HjJxWhpSGXbjAirPGeiLgLTyx5
         kIG3uY3D4+RFy2V2HhajvAeQ3jIb5x85RLPvqM8muXwhxupOgn21FOI+NwZnoHkNVwFP
         Lbkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uH61313TFD91ho+K49QjrdMKVfDQiOi5MsFqQ/a27oQ=;
        b=IhPQtbZZIQt/rLAwwNeZf1WA/4mrRzDoFyKGcUYGXKFTDjFYf+l3aSuhY9Gupr40IY
         PzmNQe3Cwdyy1G+phU8Z1ZRZWHkeOeRgU14Oe9nT3qct0uDadaHe68bP66GBlzCRWjd8
         N+/LxzEa7BBacDbOQbjxGhnfFUocLtdbmkZ1Ae0LbHBkC+mKfZ2mY+raWU8IkTcdQWMQ
         OltvZ+BPFReNcQuBPokXiUgag9PfGgqNqfIhI7tQqqn/ziFh2qkHZg6NGnxgdIh6jjIY
         Mb3WyzKAqo1FjEtVVf+coP9+dec4s8VI5MR3cVbFSvXO4SD8+a1L2WYN4pygc6dWpPrN
         nqXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z4si2259381wme.21.2019.01.29.08.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:34:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 65E9768CEC; Tue, 29 Jan 2019 17:34:15 +0100 (CET)
Date: Tue, 29 Jan 2019 17:34:15 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190129163415.GA14529@lst.de>
References: <20190119140452.GA25198@lst.de> <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de> <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de> <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129161411.GA14022@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 05:14:11PM +0100, Christoph Hellwig wrote:
> On Tue, Jan 29, 2019 at 04:03:32PM +0100, Christian Zigotzky wrote:
> > Hi Christoph,
> >
> > I compiled kernels for the X5000 and X1000 from your new branch 
> > 'powerpc-dma.6-debug.2' today. The kernels boot and the P.A. Semi Ethernet 
> > works!
> 
> Thanks for testing!  I'll prepare a new series that adds the other
> patches on top of this one.

And that was easier than I thought - we just had a few patches left
in powerpc-dma.6, so I've rebased that branch on top of
powerpc-dma.6-debug.2:

    git://git.infradead.org/users/hch/misc.git powerpc-dma.6

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6

I hope the other patches are simple enough, so just testing the full
branch checkout should be fine for now.

