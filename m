Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F03C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 315A42239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:17:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KClY5whB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 315A42239F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB8CB8E0007; Tue, 23 Jul 2019 13:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A69618E0002; Tue, 23 Jul 2019 13:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 930B48E0007; Tue, 23 Jul 2019 13:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72E2F8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:17:34 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o11so30476676qtq.10
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QqrUJzkPpAaDRvvKsmPrqxCm6oyy05uDqHmCovyhL70=;
        b=ny0e3ianx4B6JB+rjpaehqlm3l1EfcxujzWDYdq3oojjqNmEbaKeZPQIKOhxRzLX3b
         BAkA6aeggwjZyUhJ1KTygp590Sgowizcrp8fax81J1jQXKUHv4sUwyjG/0LoUuUXfLAG
         iX7kNfKRGhxEPXAx295tTuiPeGACpPx7dHz0JvIJmOIinuRy1478oGbaMEnsMc6VgmTw
         1jMK/xX19zUamE3a7TibWfusA+7fd2Ipvx1IXSjx302A2tm+fJO/osAgrivBtVsxru4L
         tCuFf8W+rAD+UeaztVWjYDUpfD1xWIbwa6DpAjZEKDzSEueuWBNjTYFYstnSsKxlNLPt
         hxwA==
X-Gm-Message-State: APjAAAWVW8p3++JZpM4l96Xt2ybaNczfAptg1nXCjj4bcwK86ICQn66p
	SpXoxRmgGgfJseM+CrJTfjjzqUHNM3qPhLks7SXkZfJ060zXvGZ74nkE6L+LEZxflLJ1JOPyKJR
	D+TOqBl7fZAXr5qluMl995KFTO+qo0vS4LKI1xlim50HDf695t2bQusIEe0UorFsNYQ==
X-Received: by 2002:a0c:983b:: with SMTP id c56mr57220029qvd.131.1563902254167;
        Tue, 23 Jul 2019 10:17:34 -0700 (PDT)
X-Received: by 2002:a0c:983b:: with SMTP id c56mr57220006qvd.131.1563902253610;
        Tue, 23 Jul 2019 10:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563902253; cv=none;
        d=google.com; s=arc-20160816;
        b=Zae8OpFy6dycnr+tZAY4zifWigrK3gy/tkxOM+S+OpK6NY5lfY8Ynrc9ueA/TT+T7C
         z6KDHQmaPd3CYZqVmsbMzfRxgs82TnLE0RvDqvM5dTA/FLV5NknomNm+43mZLYIOWS+z
         RJPYUzqul793ga+oEjfmB9FARJhYwEuNXeTNB+U4uUu7Yr1HIComJmYdU6rT3qUOstRy
         lHHnXgof1v1dD5vKCGhJVa+5F3vqUOIdZkgdzm571yv/8/M/qYiR7nvrqhyx0OWXDcXF
         UKwCJvot6qhjzkhgPt9UAXX2GTtu5/repNDBTMWXF7E+B/nzLfSjAYrtqAn6I8tOPTar
         FlDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QqrUJzkPpAaDRvvKsmPrqxCm6oyy05uDqHmCovyhL70=;
        b=T31dBJCw4RuxQVVQK92Gg+nzHEwU7C0L9k9P4jmpBIC/m26cd1NKjufJSZ1NNx0A8n
         6eTd/NCRSAbQ69MNNOoTg6Af9hG7BfRCsd6yFaRlz7wOED2plxhFg/t2rQXsRLu7xh11
         CXZ/ISjx2A0qbP3llzF174cW8vXkZtyGMvtqmYQ27uhjUcYFfNN3ZD1Ziky+huPwbiTM
         bQ4JOOfzW7V30SB/r6t4GiY1m3/5k2Qnj+8IyTWJIiwlk1H8MJwswmG7G1KzZDb7VEfr
         5R62+DLCUsQfCGVoH+A3lZMTi6YTFIMXa8zrRLb/qH4F0LwFMYbpztEi/XbzX1K++ILJ
         EYAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KClY5whB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1sor21872657vsp.122.2019.07.23.10.17.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KClY5whB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QqrUJzkPpAaDRvvKsmPrqxCm6oyy05uDqHmCovyhL70=;
        b=KClY5whBhZJkA8IHSLzSHzX+WVj0t87uGT0lzsUub/COP4/3SMvz4Iet5QPzraFXgF
         3H5sIXzzJFzGpd9sIfkxKMU0QO4M2bcDm0G+Tf39YMzAJvr0jbNxuRcY7ooqKTXsAWgH
         /tofHFhod7aDMEbGJKL6+i0RWw2prFK/Z4DJ6IZYxw+ZrvIyV2lPSgSvI1ubA+ize+sf
         ljiHEYoC3nR0bUaWqY/zvkbdhaQFxXvwycHLfBlxo6jBsBWETWn9TDMISL99sGP0pZng
         cvD04P8wscxYGTWuyLPSEz5GL4VPipUGVTAGOpCofseTd/SoqMw3MQ4eC8DD0yCVjXMt
         0xNg==
X-Google-Smtp-Source: APXvYqy/BnQGomP9bfEv9fcbGXC5naUZNkETCjo5R1Jblm92pT8i/VM8xtUGyS2NeeXimmoMCnZGHQ==
X-Received: by 2002:a67:db89:: with SMTP id f9mr45182090vsk.150.1563902253192;
        Tue, 23 Jul 2019 10:17:33 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i12sm9556385vsr.17.2019.07.23.10.17.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 10:17:32 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpyPr-0002YL-Ko; Tue, 23 Jul 2019 14:17:31 -0300
Date: Tue, 23 Jul 2019 14:17:31 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 4/6] nouveau: unlock mmap_sem on all errors from
 nouveau_range_fault
Message-ID: <20190723171731.GD15357@ziepe.ca>
References: <20190722094426.18563-1-hch@lst.de>
 <20190722094426.18563-5-hch@lst.de>
 <20190723151824.GL15331@mellanox.com>
 <20190723163048.GD1655@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723163048.GD1655@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 06:30:48PM +0200, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 03:18:28PM +0000, Jason Gunthorpe wrote:
> > Hum..
> > 
> > The caller does this:
> > 
> > again:
> > 		ret = nouveau_range_fault(&svmm->mirror, &range);
> > 		if (ret == 0) {
> > 			mutex_lock(&svmm->mutex);
> > 			if (!nouveau_range_done(&range)) {
> > 				mutex_unlock(&svmm->mutex);
> > 				goto again;
> > 
> > And we can't call nouveau_range_fault() -> hmm_range_fault() without
> > holding the mmap_sem, so we can't allow nouveau_range_fault to unlock
> > it.
> 
> Goto again can only happen if nouveau_range_fault was successful,
> in which case we did not drop mmap_sem.

Oh, right we switch from success = number of pages to success =0..

However the reason this looks so weird to me is that the locking
pattern isn't being followed, any result of hmm_range_fault should be
ignored until we enter the svmm->mutex and check if there was a
colliding invalidation.

So the 'goto again' *should* be possible even if range_fault failed.

But that is not for this patch..

> >  	ret = hmm_range_fault(range, true);
> >  	if (ret <= 0) {
> >  		if (ret == 0)
> >  			ret = -EBUSY;
> > -		up_read(&range->vma->vm_mm->mmap_sem);
> >  		hmm_range_unregister(range);
> 
> This would hold mmap_sem over hmm_range_unregister, which can lead
> to deadlock if we call exit_mmap and then acquire mmap_sem again.

That reminds me, this code is also leaking hmm_range_unregister() in
the success path, right?

I think the right way to structure this is to move the goto again and
related into the nouveau_range_fault() so the whole retry algorithm is
sensibly self contained.

Jason

