Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C5B8C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:18:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 002BE21917
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:18:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 002BE21917
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A4618E0087; Fri,  8 Feb 2019 04:18:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87A488E0083; Fri,  8 Feb 2019 04:18:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 744C18E0087; Fri,  8 Feb 2019 04:18:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC168E0083
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 04:18:21 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b186so560221wmc.8
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 01:18:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NKkYaLqxEHTYYJVteG3GvyOs8/0LVYeHC4bV8ajl1ak=;
        b=DVwxbf3NRdm8wN1XWVcUTyK3Zvy8HA4ieebEo2ZuZXTLDDULL9OvhpauxOmf4XoMVf
         1IVdBM8ScN4T0+9B3cLgItW7rc9n8BUKP/vi/MxC2f3J2D/7Gwgwdd2tthnpJ8eKpOIl
         B/G3PuDxCqyp642GtfqS58w9D3jZxsyiZGvcXJt/huOd62GPKUgy5/6Fke1zSrlwrulv
         vmyMPlweUjXopddC1PmmCIKprlmU4eTLUA6ywpczukh0oJY8S7F8hj9m60+q6wC75oLA
         fP1KuP9MCk0AdDO5bVAiclL2KKkNiBBQNrDgaBOYT8tJtMEg0VGbwiRzPGXAirx7NXPZ
         YDDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYVU1holCA49jc3XbazPHhPT8OL1ciC4XTRqYoq4ZouUMn66hC5
	QSs1zeOf9O9JLEaVyC5qbu2VkeBdlDIirheTvqsqRZ0palgYGKqwSM6ThZa8CtU3MEEKPQ2sjK3
	ryODXoXIm27SP3Nkc7YJ8vlvZ5AISXuoecVTeeTASIM6jOJbMaGgWSbUCy6gz7ooKnA==
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr10544273wmc.43.1549617500746;
        Fri, 08 Feb 2019 01:18:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZEWApCiK1vL9LKFyT9K84k7Z5B3Qt5z4owLoz6GgbQm5Hbd4/Oxk+MkjZgPSS2OuZNnFVU
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr10544199wmc.43.1549617499473;
        Fri, 08 Feb 2019 01:18:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549617499; cv=none;
        d=google.com; s=arc-20160816;
        b=s5YgQ5jOGQW4DogO8Ufx+0iZRyN++8UObU6Hg+/gldyTdlFh/caD59Ohoqi5RF4oeX
         TY0UKf4R1IiRhhJYDNxtZhIWHD/A3WOzL4i0R/c+C8bifvGUq55Py76RudkEtHEmHPGe
         bq9LfS7QyLWwC3kH7bk6bvpGbG2PkGxy1zEDZRw7kKsYW8XbY599kRUdQJwoKnkhHVWt
         mCnfX66+g/VxzMu3QrOw7uQFQ7w/ygo70ebDYNWLz+Ofw22p+FaQ5mfJs34VbvGPs6ku
         jPsyBWuHfcTgplEFWF41A3PtEBBew7/6ynf4Jt7WPU1FfWeOMs74zqN1aEi304L6oh6w
         dTeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NKkYaLqxEHTYYJVteG3GvyOs8/0LVYeHC4bV8ajl1ak=;
        b=qSoFLnK8KQjk48h/y/y+bc3tzRb3Xg0HNZeTC+sTRykJH/TAsIrMhagzSjlHPoUG9Y
         xA9VHRCgH38vq/e3ee7hZYBX3e2/kOuHeKCNhK7TfUJcJ5+1B1pmL0ATCiYHMh+1xH7U
         RLIhm86hE33h20N3lDUqxhqF55RexhSlRePKH0s7vBOFWNj2VsfV4fSGxpU8nb5fUXr1
         uti6O2EQSQQPSYpCjaCddJBZxz5MHnxHHtUSOzSgbF1ZLuSF2IB4kIvZXUO3Psf9uXAo
         WlkDhWSEUuXT4ijUfHEaO7vAMkL7EzgM5gd8aG0lEYu45GNqFXyJkyizGwF6n39ggHod
         hCNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c1si1525333wrv.117.2019.02.08.01.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 01:18:19 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B126568D93; Fri,  8 Feb 2019 10:18:18 +0100 (CET)
Date: Fri, 8 Feb 2019 10:18:18 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190208091818.GA23491@lst.de>
References: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 10:01:46AM +0100, Christian Zigotzky wrote:
> Hi Christoph,
>
> Your new patch fixes the problems with the P.A. Semi Ethernet! :-)

Thanks a lot once again for testing!

Now can you test with this patch and the whole series?

I've updated the powerpc-dma.6 branch to include this fix.

