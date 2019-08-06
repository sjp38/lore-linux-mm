Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4798C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6689320B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:04:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kwN8iZgG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6689320B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E39676B0006; Tue,  6 Aug 2019 08:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE9E76B0008; Tue,  6 Aug 2019 08:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD86B6B000A; Tue,  6 Aug 2019 08:04:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA2E86B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:04:18 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c207so75373235qkb.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/FPGr6jzHPYMmvLrWMP/4jeZ5wMtWr8MomConqYdxCw=;
        b=eA/g+kLA6YEn24f+HIUmWeirvauxjbODYTEKwZHuVCa95HUR0w+XrfqpM/TQqOr2K2
         gIxJdMZMrQ0bQZf6NRT+QJxOR5A+m+X3KBTD1gdhuhjM7s9pwRYrGeeaEq94oYwXhToK
         cSpLZv+d3Cm/S4iAu0sh4xx+dFCHV19sMv7SLq6Aa/dYPRyDpD1vi0ug7tjbF03fR0B3
         ShFh/pJi95d1CfbAuiTzVaP4Cyb5P8vZtL7lTm82xyGYx/gKLnptw2Pq68cuC21F1+fZ
         UunN4MIntZb0s/5/Ou4VauHwgNH8KJsd+kPfHXoaheJ3qjxFNYoiKSQT42eYu3IOAIz8
         6PCQ==
X-Gm-Message-State: APjAAAVmnsqR3wvyZ5y47gVJqj6m3FTf2QhJl6W5QYerhJCYj5m91+LH
	5cLx7VkiYeV0bH1Dbg2gYAGvWtPfSzRDIUmQ9N7b8p/oPzQsJe4sn1NMaVu/X+mVzH9CVUen9+l
	6T1nILpi3MXjHjjCkPFiQa3/qRkRy8buS8KFcb7hl69FjGfqopxW0yOu5k4QOQwI9SQ==
X-Received: by 2002:a05:620a:12a9:: with SMTP id x9mr2824406qki.279.1565093058463;
        Tue, 06 Aug 2019 05:04:18 -0700 (PDT)
X-Received: by 2002:a05:620a:12a9:: with SMTP id x9mr2824344qki.279.1565093057759;
        Tue, 06 Aug 2019 05:04:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565093057; cv=none;
        d=google.com; s=arc-20160816;
        b=ThD3KxK1n5WToyaVlyrKR117cPrN8/s8gx9U4gLgontpZhv4Qls3+8YE3qvgyH3x9Q
         rszk35Qk1wLVWpPC0frbe4pJUg+NbgqNbztx3eeCPZXYGAwqrMdIX6KzELYUdfcwpBFY
         B1EauS5e0DIbVQHQL3uCSxuNXYXbcCIw1hLEvaR360NxLBvbN088DGVY3HIWcRbjaSyz
         1zNyFxSEol6eO5/mpIy7TiKUUNG1aEA1D1dnKKu5BO5FCL//jlXicZ+gu/iS0KN/Imih
         gadx/vj+sTTFe8uF3JlVpxYPH5k7cdgqduwQqFl/CPH/pDBQGHayioh8wlz835xtjTy8
         nTkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=/FPGr6jzHPYMmvLrWMP/4jeZ5wMtWr8MomConqYdxCw=;
        b=c99EyKvrRfd0IkbOfZPx8UkdgD/7kL+j72/R+w0VSnk6XPggzvAH5x+yFvtkcm3Ep0
         IAIMaw6EmI2al74vtfXM6BpWa6+2MLWbd77Fu/KH0j9cStBWZlv/jhTixUit305CalPJ
         ls3cL/TU6VpBVCrSCGZL4L7DHm9PJ/YBnNuyOzT697sFwFHVnsTMFvVWSz9SSIS4VpK6
         jVoWJzlqlTu04wapVlmr0qMpvAORKMkjG+Ml8N7XTIypOtY7fh/w/mR0OHLYvE3Pl+3Z
         vMXj4Blg2EhYmSfB0pECudpubFpkvuDABqsYJpxzvFxwRRnFULkvcssizZpHK1IKDtRc
         JYrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kwN8iZgG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b34sor113258578qta.71.2019.08.06.05.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 05:04:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kwN8iZgG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=/FPGr6jzHPYMmvLrWMP/4jeZ5wMtWr8MomConqYdxCw=;
        b=kwN8iZgGsA616k+ie7zVtqoKkPJCUoU9iiNH6foaeOBTxgKFKg+cZig/4zEdPfsbAE
         imTkOw+N/gal+1pboal/fWK91KxOgzhhMdL0iTRREJABvKyEt3Ufx9IKidWtLDpA7wlG
         9D0U+Ocv+7+jGN8gmxkVmfJqgoulbE7JQaMbA++nVny+EMylWeaEfpgkD0hSjvguAUdx
         LTme6+JAjIDsU31cell6nZpPIOasOpsE3BLX48Nh53wDpRS1MGS6UPgJlSEriefVBoaW
         X9Q/yQXt7r0a9KNgEj2XwtztzIPh4TLr8mCicotwiPelZo/OQ+sSdt6ODRD0nTuMLItg
         nPCQ==
X-Google-Smtp-Source: APXvYqyl6pRejslnyvYVBtbHRarAvLE8/IwB9kBOqtljVW3kFuK45lKI6xsfV3oqosPPvOz7rhnfwA==
X-Received: by 2002:ac8:252e:: with SMTP id 43mr2606764qtm.61.1565093057443;
        Tue, 06 Aug 2019 05:04:17 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c45sm44553632qte.70.2019.08.06.05.04.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 05:04:16 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1huyCO-0003hy-5t; Tue, 06 Aug 2019 09:04:16 -0300
Date: Tue, 6 Aug 2019 09:04:16 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190806120416.GB11627@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <11b2a930-eae4-522c-4132-3f8a2da05666@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <11b2a930-eae4-522c-4132-3f8a2da05666@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 12:20:45PM +0800, Jason Wang wrote:
> 
> On 2019/8/2 下午8:46, Jason Gunthorpe wrote:
> > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > synchronize_rcu.
> > > 
> > > I start with synchronize_rcu() but both you and Michael raise some
> > > concern.
> > I've also idly wondered if calling synchronize_rcu() under the various
> > mm locks is a deadlock situation.
> 
> 
> Maybe, that's why I suggest to use vhost_work_flush() which is much
> lightweight can can achieve the same function. It can guarantee all previous
> work has been processed after vhost_work_flush() return.

If things are already running in a work, then yes, you can piggyback
on the existing spinlocks inside the workqueue and be Ok

However, if that work is doing any copy_from_user, then the flush
becomes dependent on swap and it won't work again...

> > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > improvement.
> > I think the topic here is correctness not performance improvement> 
 
> But the whole series is to speed up vhost.

So? Starting with a whole bunch of crazy, possibly broken, locking and
claiming a performance win is not reasonable.

> Spinlock is correct but make the whole series meaningless consider it won't
> bring any performance improvement.

You can't invent a faster spinlock by opencoding some wild
scheme. There is nothing special about the usage here, it needs a
blocking lock, plain and simple.

Jason

