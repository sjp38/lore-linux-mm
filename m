Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E3DCC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A759B20844
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:57:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ap0SmPcZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A759B20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F5786B0005; Tue, 13 Aug 2019 07:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A61E6B0006; Tue, 13 Aug 2019 07:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 095AA6B0007; Tue, 13 Aug 2019 07:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id DB6AE6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:57:09 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7F6CB52AB
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:57:09 +0000 (UTC)
X-FDA: 75817253778.10.leg64_3e7333573fd00
X-HE-Tag: leg64_3e7333573fd00
X-Filterd-Recvd-Size: 4101
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:57:09 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id t12so17416594qtp.9
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:57:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RPb0NU5H2rzwjdvr45r58ZWni2Zoy4JljRGSpgnMMr4=;
        b=ap0SmPcZPZ6NNFvNyFkpypRbg36yi8bdsTd4/F6gQQqPPgiM5IjDvTKZEGGxca8l8F
         u5EQEn7sEyhGruMuB7cjg3kUgzh9Cv/quO6ECF3rbawY4hb6Yw2dyN9iU6PgCvTDOCh0
         xsYZVNW0ajla3uTLaTh6ZCITFtrsONP4+81D6sumJLjqzxf2snBDmJYrwx6qXccYld+H
         swJwSMjlc5QmHizDCiZoTu8O5ptOxdiKgiKAZ9i3JGi/jhbj1siIrzDAKpRTStg72MQw
         /hWyMVuaK40viEpVJr1GXiLhMU2L4bLITv7lm7rfgwRXFHTHOxuSU5tATEjLqz3Rmkx9
         LONQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=RPb0NU5H2rzwjdvr45r58ZWni2Zoy4JljRGSpgnMMr4=;
        b=Qy2Zni45pM6FNSgZM1yBLGYskzXdcOzH938hhWZVyPYXnxpHPNod6G18Ell109tOA7
         JkzwD1HaJKhaBGvJ3c31f9P9lnd0/l91qXaNreVFbZ2o1VrFP/8BJuYRrF3cJ2EHUcGF
         f4q9nWWUXIcvSn1P377RNhnQiCj8qfbxgXY+Pvnjv6yw2eZYsCM/FmukslhVTrIUH4sU
         7nEQJcPRU8N+Kp13FyVsYulsnnD8yDsO8yidRmW+GQszCcj8ZEpWv489hOuLNTdLcEHK
         hFYeQGNfWBbAzCUZJMuLS6HxUNySZsetjiwzoYqQYGGY42Jp/dkCN3tOPaADEF+1Ogce
         uCmA==
X-Gm-Message-State: APjAAAWmK4sxb/ayzWUd4Z2dH1mZ6om3+4XRRO29yILIMeg2XpIvPryq
	wjvW35NYFZtHcxHElEHCT96FRw==
X-Google-Smtp-Source: APXvYqyQLbr3IuoVdbXppS/ZGOesGhtgbHcYTwB9ezrUQfPYFcx2A9k+2h1mf3jK0ev1zMtBSQ9gpg==
X-Received: by 2002:a0c:f193:: with SMTP id m19mr33863324qvl.20.1565697428498;
        Tue, 13 Aug 2019 04:57:08 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r4sm69930362qta.93.2019.08.13.04.57.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Aug 2019 04:57:07 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxVQJ-0007sn-HH; Tue, 13 Aug 2019 08:57:07 -0300
Date: Tue, 13 Aug 2019 08:57:07 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190813115707.GC29508@ziepe.ca>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <20190812130252.GE24457@ziepe.ca>
 <9a9641fe-b48f-f32a-eecc-af9c2f4fbe0e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a9641fe-b48f-f32a-eecc-af9c2f4fbe0e@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 04:31:07PM +0800, Jason Wang wrote:

> What kind of issues do you see? Spinlock is to synchronize GUP with MMU
> notifier in this series.

A GUP that can't sleep can't pagefault which makes it a really weird
pattern

> Btw, back to the original question. May I know why synchronize_rcu() is not
> suitable? Consider:

We already went over this. You'd need to determine it doesn't somehow
deadlock the mm on reclaim paths. Maybe it is OK, the rcq_gq_wq is
marked WQ_MEM_RECLAIM at least..

I also think Michael was concerned about the latency spikes a long RCU
delay would cause.

Jason

