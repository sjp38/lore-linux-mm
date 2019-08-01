Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDEAEC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:15:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F1FB20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:15:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Xxvi13uM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F1FB20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F41168E001A; Thu,  1 Aug 2019 10:15:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECA8F8E0001; Thu,  1 Aug 2019 10:15:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D91928E001A; Thu,  1 Aug 2019 10:15:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B80FA8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:15:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e32so64667055qtc.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:15:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=is8PyxvRhNytWxsxvai2fZ7Vunv6qUm5JlLk3gubz8A=;
        b=dpSfT5Dg6QDZwva5fSF3PBWaP3NL3ejRttYkqp7r0ry1pxak5t+MxtxCWlz8gnidvC
         gSCPE5C/CHpr7hcoR5ahxP/5ysSnhH/qfPLOHcY18VPMw5CKDa+Iqpa7ViT+OnHeewd3
         +VQcjiKKX0H8KFNa04Mqdo6UD3UaB1tjIyhT4kSPl3/NM1X7B0iOjNlizyUrX0r6rL4h
         lCzELk1Z+PblAxuL0BMa0yu1pMmAy3YsREdwIRxLM9EaYYxiF5KPrzSYxiOYFC/lAgWN
         tDr09Pd9aOwgRkL3050c1k3hI8T01GooyfcK2xkecrr7THvEN1kG14cGqx8sXL4WPdaQ
         8KkA==
X-Gm-Message-State: APjAAAUiN3Wpd9JuDfmE+DQO7qvkyFMaSX7RXNmfyGXTFeWQSrDKSwui
	OOGgPH4GVe6tSlMQVAgO7oRShCKALsy8xLaSvF7KIdY2KM9dxF/OAtsQA98XDBMSqazQV8k6KIv
	7Pd/1BiHGKUFMaP8xXVJBkmCAk5XCEJpC1pCZH0OYSGIb2T2iUrommSIt1PEPeLhipA==
X-Received: by 2002:ae9:df81:: with SMTP id t123mr26285717qkf.372.1564668915437;
        Thu, 01 Aug 2019 07:15:15 -0700 (PDT)
X-Received: by 2002:ae9:df81:: with SMTP id t123mr26285629qkf.372.1564668914595;
        Thu, 01 Aug 2019 07:15:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564668914; cv=none;
        d=google.com; s=arc-20160816;
        b=CE1rHnPXOKErzFaj1iSMLBBJe+E+PMdHDN8mRmLow+YOksYZoBpZ6o4tO8UOipg8BM
         1FwYYO1ZO8Vc8jRZG4Tb0x4BaO900aP35dDfZgdFq9bSu11JTYglN4YMbSuhsHdft/eW
         tqUVg0ed/7uH5u721oETwjLhqHvr/IJCFZGfHahCbI7vSGM6A+GgjvJoyqiRMcTZLZ4p
         +mmRikNlh1+cFOIMQ2i5iYKu5PSLdg7M2tJS9d6GrUCe7aV8An1HylqXpc8HUn1BH7qE
         75Us7+NHoflQrfsCWc6/R+pYj1aKDDGzi9Tx18WJu/zfGz/FGE5Gf2hBCoq67Pp54PAt
         hw8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=is8PyxvRhNytWxsxvai2fZ7Vunv6qUm5JlLk3gubz8A=;
        b=P+WSMi86EcDGG84HwjtW7xSoXilEMME+aCw9gvx3m0qOpYVScz52Zkl2NFw13ZhaDc
         sY2sT8E9JRUDyfrPuT8Z4JN26z2OaTlc4DnYnsnB0IynZcyYm+FAngIhVlCSPqFmZGsO
         aVvLmnjRjDlpuPH0LQyvGpIk5RVEL8gYyMWdyk4kRsfU5sINXupvaTLTtO8V0RhjToSl
         U7DhuRjYwq3Rss3cwc0JBm6ZdcMi3ZuXQBr3glxjLOYB+GzFK3oleW16GXWTjzKyrMk1
         yA2PTgqnrizcNaqRJv0C0X3edV7Wec4xm4GkKqxj7ihbUJqB0M6CCcmvtq46EzFNdTi8
         KDPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Xxvi13uM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17sor92727191qtp.16.2019.08.01.07.15.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 07:15:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Xxvi13uM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=is8PyxvRhNytWxsxvai2fZ7Vunv6qUm5JlLk3gubz8A=;
        b=Xxvi13uMIuNd1i7qKKgkImlPAjK1xDFLxSCWyTWQlSWc0W0RYQ1MIbkdfqnYLZG9yu
         5JI71oibP9i2ddPwTU9YBExPCU3Dlsj9Hb5dtaQ5jQpFVrZe095cwJxIxT6yDBH5wF1p
         wCJApD147HK5V4ZzkFqufCd3njndvpO/gboYNoDeFKB07FcDW1Fik2Hzi8KFbGkqeU8B
         FnLAkMgm4iKJeXTHx5eicQowVzuFCmxijHVptaHIDUKgEIgd9VbBsMKuWbYIgOQnQmmN
         1oNq+b5+5oWwfawyEFBafayDt06Az4m3upS8lvLUrhifXOq6NRLkSxQqkth2e/4StwnK
         u5vw==
X-Google-Smtp-Source: APXvYqzpRyNA15Vg4dJPptP9AquA0hd08+YvFQ9QkFLiFtu1omZ5ju/uevoFFYsI/1tqgZOzWDDXnw==
X-Received: by 2002:ac8:1a7d:: with SMTP id q58mr88042253qtk.310.1564668914103;
        Thu, 01 Aug 2019 07:15:14 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e125sm29217763qkd.120.2019.08.01.07.15.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Aug 2019 07:15:13 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1htBrN-00082a-0Q; Thu, 01 Aug 2019 11:15:13 -0300
Date: Thu, 1 Aug 2019 11:15:12 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190801141512.GB23899@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 01:02:18PM +0800, Jason Wang wrote:
> 
> On 2019/8/1 上午3:30, Jason Gunthorpe wrote:
> > On Wed, Jul 31, 2019 at 09:28:20PM +0800, Jason Wang wrote:
> > > On 2019/7/31 下午8:39, Jason Gunthorpe wrote:
> > > > On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
> > > > > We used to use RCU to synchronize MMU notifier with worker. This leads
> > > > > calling synchronize_rcu() in invalidate_range_start(). But on a busy
> > > > > system, there would be many factors that may slow down the
> > > > > synchronize_rcu() which makes it unsuitable to be called in MMU
> > > > > notifier.
> > > > > 
> > > > > A solution is SRCU but its overhead is obvious with the expensive full
> > > > > memory barrier. Another choice is to use seqlock, but it doesn't
> > > > > provide a synchronization method between readers and writers. The last
> > > > > choice is to use vq mutex, but it need to deal with the worst case
> > > > > that MMU notifier must be blocked and wait for the finish of swap in.
> > > > > 
> > > > > So this patch switches use a counter to track whether or not the map
> > > > > was used. The counter was increased when vq try to start or finish
> > > > > uses the map. This means, when it was even, we're sure there's no
> > > > > readers and MMU notifier is synchronized. When it was odd, it means
> > > > > there's a reader we need to wait it to be even again then we are
> > > > > synchronized.
> > > > You just described a seqlock.
> > > 
> > > Kind of, see my explanation below.
> > > 
> > > 
> > > > We've been talking about providing this as some core service from mmu
> > > > notifiers because nearly every use of this API needs it.
> > > 
> > > That would be very helpful.
> > > 
> > > 
> > > > IMHO this gets the whole thing backwards, the common pattern is to
> > > > protect the 'shadow pte' data with a seqlock (usually open coded),
> > > > such that the mmu notififer side has the write side of that lock and
> > > > the read side is consumed by the thread accessing or updating the SPTE.
> > > 
> > > Yes, I've considered something like that. But the problem is, mmu notifier
> > > (writer) need to wait for the vhost worker to finish the read before it can
> > > do things like setting dirty pages and unmapping page.  It looks to me
> > > seqlock doesn't provide things like this.
> > The seqlock is usually used to prevent a 2nd thread from accessing the
> > VA while it is being changed by the mm. ie you use something seqlocky
> > instead of the ugly mmu_notifier_unregister/register cycle.
> 
> 
> Yes, so we have two mappings:
> 
> [1] vring address to VA
> [2] VA to PA
> 
> And have several readers and writers
> 
> 1) set_vring_num_addr(): writer of both [1] and [2]
> 2) MMU notifier: reader of [1] writer of [2]
> 3) GUP: reader of [1] writer of [2]
> 4) memory accessors: reader of [1] and [2]
> 
> Fortunately, 1) 3) and 4) have already synchronized through vq->mutex. We
> only need to deal with synchronization between 2) and each of the reset:
> Sync between 1) and 2): For mapping [1], I do
> mmu_notifier_unregister/register. This help to avoid holding any lock to do
> overlap check.

I suspect you could have done this with a RCU technique instead of
register/unregister.

> Sync between 2) and 4): For mapping [1], both are readers, no need any
> synchronization. For mapping [2], synchronize through RCU (or something
> simliar to seqlock).

You can't really use a seqlock, seqlocks are collision-retry locks,
and the semantic here is that invalidate_range_start *MUST* not
continue until thread doing #4 above is guarenteed no longer touching
the memory.

This must be a proper barrier, like a spinlock, mutex, or
synchronize_rcu.

And, again, you can't re-invent a spinlock with open coding and get
something better.

Jason

