Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E144C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:05:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE4C82184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:05:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UsXVcz/0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE4C82184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 684F76B0007; Thu,  8 Aug 2019 09:05:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636246B0008; Thu,  8 Aug 2019 09:05:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 523CB6B000A; Thu,  8 Aug 2019 09:05:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 315D96B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 09:05:28 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l14so82209775qke.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 06:05:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=9m6QChW1Hz/Ce2TOg5A9I+Mvna5Z6uz7U57CNrS3DMc=;
        b=jSMUl+2oK++yaVwZWQK7YDWm3+GRQ9HmupLJcI2asY4tFydeUSfdukHGoSk7NxFk/B
         xCjMrDWFA4Rpxdy1NZVHzDiioVKsbzWgmaee17O9sQvXJDfHIJ+DDm/QoJ4ivbqxzlmZ
         jfqReD2elm0/XnIazEkaWdAEp/HojHHM5WyyPU0YRhKrDiHSBFmRfJ3Uh7B04sQKJcm0
         EBsrQRVre5lvjpq6tHxcTffimiKDSN3gyssyHFW5l0If4GQTa2bU5Xh7d06QaCOvmcB7
         GoQA47QGNLaBZzZTyYGA4EAR2ZSmq5zJ0iuDbncgANZxSFustyHx99heIVfKDoQLpq6o
         nNwA==
X-Gm-Message-State: APjAAAVCWzsVBQwkGIGOEIerv1EtqHaEMHsRsfhpCJVvsf8zzhfBgN7T
	DZslB858dWidDN1kvpUpQ/sV9Yar3M88J2mKsfIsRToZSXcfKDIAwV2lpXfSPW3tx1emrH//4AZ
	7fK43P416PnXjhAKtSbwsJAuin3VPDqFxi4yrCNSnNGPbP+Mc6LFTVVyd9uQ4VTo34g==
X-Received: by 2002:a05:620a:11ba:: with SMTP id c26mr12038024qkk.201.1565269527977;
        Thu, 08 Aug 2019 06:05:27 -0700 (PDT)
X-Received: by 2002:a05:620a:11ba:: with SMTP id c26mr12037982qkk.201.1565269527455;
        Thu, 08 Aug 2019 06:05:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565269527; cv=none;
        d=google.com; s=arc-20160816;
        b=cCkSzHylfokxSlcPtfSE0OsXnwbbB0rSauh/GzvIUyT0JM6NCw2RvQHEAtTIKrAVQp
         /vvs9h78hUYJbDYvjsGVhmsxoTGbr1aIHeqWX3RcPdOzGqO10jjMOrbsntkFlKi5qxlI
         F46NmogLRW4P/Mwadbik3d5lQYblQ2MEAQ/Ep9GhUSSBoH2Mw4OAMtRP475G8XvlRBof
         5PHhbTCP9eE/NT7d4kCBycKLcvzZV/dJKm67/mnixKLiUUesl1mpKLNl4YsvF5GecAWr
         spaDcZ+5sKhTtHWhZZyrG+LAU+cYWaVSnLyrDfbYBVt3GuCBHX3Fa//vCnpmNEI9qLAd
         NV0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=9m6QChW1Hz/Ce2TOg5A9I+Mvna5Z6uz7U57CNrS3DMc=;
        b=0RfMlpYwBfxb27GKpxuGXbcYdtt3iUZuJRcpEvHgs+bJuXGTpmN1n/Lw7LGuxF5vjr
         sE7lUPJIiPUXxK1mIuOlyOajvo+mQ+Txz+znVtMI/Xe0V7l3S1krV4Au+YSbJ5r+wmRa
         EWpnMui3EEVVyjDe2ts5BpGFj622sLz+O19yNWyQJbf6IhdvNYr5eG/akcRX+jK3YrVS
         eAtPGg/vRUKst71Ux3PTfL9V6Kg5BjWicgBncjNQmc6YPq0F9O1A/FUWI2xwArXiPAJ3
         f4VMAs0eW6byWrikSAfc6afbXTewT8KaV24o9QFmx5WiiiEoGKseGV+yxZvUjs4Gx4CU
         tM7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="UsXVcz/0";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor5147032qto.38.2019.08.08.06.05.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 06:05:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="UsXVcz/0";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=9m6QChW1Hz/Ce2TOg5A9I+Mvna5Z6uz7U57CNrS3DMc=;
        b=UsXVcz/0fx+mbrQVrDfthdHqx/TQAG6mZCOjIrVyOeqqQ52UZpnPAoCRoyaHnv8XhS
         myAYX36Qc07br0W255vMKbULw2ztt1SK9LCxY6t+qNSGUH8lgf/3KrkhNmVLhnuXPk75
         8NKhNYfOP0paEoLotKXkfyPj6WC9fRZDjL/390dyyF/8bhzq6seIlrIR7AftrabVSUCt
         9CsyV03odYVVSHvklvyseXwr4U05s7IrXQRwta90NNKp3g9VPyivRSNNHC+ZMXAvgadj
         C7aT5FJ9sAlB+caYQhcUKnsovzehTBq/uSqC2bLHwecFVaJ/O/Uv9sooTvOk7mSYFNNc
         0qyQ==
X-Google-Smtp-Source: APXvYqxk+1+rmZi904v8k29c8RjsPTgNO19TH+tlNz6F8hGZWv6LBYxggtUeflQkroZ7XbRUiUsHTA==
X-Received: by 2002:aed:3ed8:: with SMTP id o24mr12601256qtf.252.1565269526793;
        Thu, 08 Aug 2019 06:05:26 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id b1sm15328088qkk.8.2019.08.08.06.05.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 06:05:26 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hvi6f-0003Ih-LV; Thu, 08 Aug 2019 10:05:25 -0300
Date: Thu, 8 Aug 2019 10:05:25 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V4 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190808130525.GA1989@ziepe.ca>
References: <20190807070617.23716-1-jasowang@redhat.com>
 <20190807070617.23716-8-jasowang@redhat.com>
 <20190807120738.GB1557@ziepe.ca>
 <ba5f375f-435a-91fd-7fca-bfab0915594b@redhat.com>
 <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 08:54:54PM +0800, Jason Wang wrote:

> I don't have any objection to convert  to spinlock() but just want to
> know if any case that the above smp_mb() + counter looks good to you?

This email is horribly mangled, but I don't think mixing smb_mb() and
smp_load_acquire() would be considerd a best-practice, and using
smp_store_release() instead would be the wrong barrier.

spinlock does seem to be the only existing locking primitive that does
what is needed here.

Jason

