Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EC04C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:57:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA52B20815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:57:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="urnzw8Vm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA52B20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43E7B6B0006; Mon, 20 May 2019 01:57:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EF676B0007; Mon, 20 May 2019 01:57:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DE926B000A; Mon, 20 May 2019 01:57:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8A136B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:57:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u7so9198458pfh.17
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:57:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=n/yIzKd81+TM+3UvGV1Qf2W8qzlZxmI5yFYDnHihTSo=;
        b=NYg01Vr/5ChYvkqqtHDsg/AIBEIJbNqiFfVgtPKJ3oph9DITzxXkdi72X1jHWnXG1J
         2SHZ9+3bKmnTPyU/2lIys8osBgXdVO6YSEXsb7HwDqKCohOeFeMx+Jw8cqJuE0bNdH6I
         T2NqEhdHPprduNH0ckK4QYgx5QH6GDpm2ahlsx12V0KKTRo2rPaq/p8ioxCJLA90whft
         /vQOkqGdHzCfls5MLyirt+C7VlkT9oJ7zzwOwIbVch3r7QElB6YnWmaLDgrAxyy4UKwf
         OTuiCIp9sN1rJr+fCSUQLxFyyNYL5K4tAapRLJmApdDUSdMQQAklB0bcKvwR7mCkrcCI
         4r1Q==
X-Gm-Message-State: APjAAAW6KyHhVEda/S4HA6Z9vYBSE/KYkSd1qO1vfsCggpHQ3XX62RGv
	qqQEx43o3BZiigTiMXr0Bac00Qpri1/5wFqqIu3Taq6q++wEh1KBjdGXy+VS+YRVjDFJpj04TUx
	BQh9qyn0Wfm1mpDigJQVulamB+xQI5TXSuABN0+YEjYv+cIQTxvu7U9OabqgW9x0Mjg==
X-Received: by 2002:a17:902:201:: with SMTP id 1mr29033685plc.263.1558331822520;
        Sun, 19 May 2019 22:57:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ4czuuHAOT58DcUp6tSJIwjqlz5QqSvpPt5pDPBXBejH7ocil8+7H++n3E8Q8xkvV5Son
X-Received: by 2002:a17:902:201:: with SMTP id 1mr29033644plc.263.1558331821949;
        Sun, 19 May 2019 22:57:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331821; cv=none;
        d=google.com; s=arc-20160816;
        b=I2sW0ssEy6X2MhJAMqtz5vbogv/Opp6BKRDkBr+Kq96V99FnCs4s1l6gfNOciVuwFt
         i5Hkdk6RRVUANdb6eMM5IMM2J8naTLv/Twq27QlAPdNBs+l90FTLZv10AF9VwXgKOq0d
         M9DRWmia8Nm7Sg2QLbbpcNdvNLcfbqOA7QD/4VF/jrU7mloo7kpccbwgdOluRV9reSLq
         XgnvFfHp3hNoh3QrMmMl7HbgdX6IametF1iWQ6c6DcE1bIPdxigbYRtI/jwjh4+66XSi
         uKm6TzvBhMSIDgKZGLvIE1I6gSKu9DEMZbTK2Dvu55yvOVm7myP9HONbS+a5H6m8XKZ5
         CabQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=n/yIzKd81+TM+3UvGV1Qf2W8qzlZxmI5yFYDnHihTSo=;
        b=rzbm9Uu1WfHKj68Umf6vKoRsZ6imGiUmHp+tlyH68b7edGUxgZGz8QwSjxvDb4CM58
         VK+HEs3rczL3AgUWsvl14RtImV1KnFoUbjNoMUULsVjSCWyS/obn8bKg2ods20vGXDLG
         m6Z0yV9D8uB5FZkq3YgX4ml12MTLacJAOkRPSfk9RTd0S/wmPnIULAPPbVOO1JcNCLUZ
         xk7Wa0vttJ5K577KFoCTT4EEbH5EuM9TnlJ+ngbrpiWOSsoGMr6JV/YYhW8y5I1mTERD
         MrDo2pie/5rC1hRd9xLw1sK0X4ZyPmO+DQRvZdGrT5U/WDN/U2P2Ae+KxeryLUHczTLv
         jjww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=urnzw8Vm;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 77si17274910pgb.237.2019.05.19.22.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:57:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=urnzw8Vm;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=n/yIzKd81+TM+3UvGV1Qf2W8qzlZxmI5yFYDnHihTSo=; b=urnzw8VmiMP9TugzAfLgp6yc7
	dfmBhTiVp1UyVNGQyqHS1Nnn4tFxpWfNDOjlhG3NMqQ3E4wFTCes/z0TWLH1SfqsWpD5/akz+DBX/
	oHbWkpIrbZP24i2cUziddSM5kBml+LER0VrkrORsAxP71POf02NXO+DhU5vbIZJFNG9kbJ5aV7TEL
	YCG9fYcgSfdhXvp1Wj2JL25KemMRrINp4Rmms//Dv1Iw5ebeBX5Tsc/k2CzUtT0G+iCSf9LYn1qfl
	jXOt5kQpf7Iwn84rir0nFGULr6aU1NNTbqKi+ZA0YY3lh0okwoFeQ6Ngq+VbJVUoWRVYvs0RWtiut
	g1CGMTSvQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbI9-0005Xy-GO; Mon, 20 May 2019 05:56:57 +0000
Date: Sun, 19 May 2019 22:56:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jaewon Kim <jaewon31.kim@gmail.com>
Cc: gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	ytk.lee@samsung.com
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190520055657.GA31866@infradead.org>
References: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Folks, you can't just pass arbitary GFP_ flags to dma allocation
routines, beause very often they are not just wrappers around
the page allocator.

So no, you can't just fine grained control the flags, but the
existing code is just as buggy.

Please switch to use memalloc_noio_save() instead.

