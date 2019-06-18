Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4735CC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09BA520663
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EbwbRCaT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09BA520663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9757D8E0006; Mon, 17 Jun 2019 20:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 925B18E0005; Mon, 17 Jun 2019 20:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CF18E0006; Mon, 17 Jun 2019 20:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 648498E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:45:11 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p34so10955555qtp.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xyVcNd9oooqBQ01pz08myANSFTdx0SwnrW4fjYnawJM=;
        b=jHGQ8QRiOGmDeSr98SlO3pQja3MLoV5N+ZqbIoJv87OgpAQbzCqlzT5VMfmw8CJHoP
         EaHE6IE3DnBV1SI1jC63JYzREUrdSfLHE9xfG17z9Fd76h9G5RH7yx5S4vuK6BTwKffJ
         Y9RrjVuCoBBA04U+ZeGiYr2HI/BygsRL9v2d23zfM/9p44xVUCDGMt9del9Voamz56jn
         pWJENR/2zpCVnEqI1+71w+hviJQFSwXjgT6f/0+lA9PrwlnBqBumVCNSM3bbdNcUIpta
         YSBXeRyLLijA/XH46ZMMI5bdE/jEJ+lA5d0oFgQ6T37a0vs9wF2E+UqbjkHeb8AvmjGN
         i2Ig==
X-Gm-Message-State: APjAAAWBLQXayDP9sVcfueiH94nHj2bb0GPwsgGI6XRf/6tBRDzaS6L5
	YpqE+5qWT5AtsqAYDYvMhKMSMgArP2rFnMC4D0v2F1CQ3B09zhM4pD+lfdWkNHeE2riWO7eCH4P
	b5l7PDCl9nf00C1uSx393ZRr+5ClDtp/vK8Mhqv9FTRm9sGn43QATQzSlc5NxfCZvJA==
X-Received: by 2002:ac8:7c7:: with SMTP id m7mr92099834qth.28.1560818711174;
        Mon, 17 Jun 2019 17:45:11 -0700 (PDT)
X-Received: by 2002:ac8:7c7:: with SMTP id m7mr92099813qth.28.1560818710700;
        Mon, 17 Jun 2019 17:45:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818710; cv=none;
        d=google.com; s=arc-20160816;
        b=b71NVaaLVyELSAUDfzzBNWDfcSFTJJW5h+05bIoYDaI+njWvgH/oRWcf2vyl5NO3G/
         JKzompNJsIG/ZHNSacA18BbN/Xo3RiU/lNMBVxjd5cMSzErvAqvVM1qX8+wm8H6Fjicg
         YuWPap4boWT7BGqwzjNyoH8BKxDBivoDiC9FWJTQCKBvOOjA31h3obJL3IT8b/GWWt7d
         LEY2wlB87qOInHtURfdNfrOQGEj/Jrs3YznlyUagrlCYuT0TDYmBTLtuBhdVIzF3UET+
         kzoiAO6br4aWUn0KZHiM4mHseehKaHqoZR9L8IGZFXhJGHOM5KQeFkToucz37H80Uh/3
         nbAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xyVcNd9oooqBQ01pz08myANSFTdx0SwnrW4fjYnawJM=;
        b=J62asutl31IRr8jT73mnvmUA8GTW2ynWCihrs2HTDd2usu72qSlljTvhN0BVBPpsoh
         Z6Xm25eXf9NneLhUXmUD2/IukwNgxLjNpaqi9y0jZ85Xvs1wFpc2TC9EtHqSsQgHVCT3
         oF6xGDTAK9GEnfPKJp3vpO3KSVTG2YCPcnL6fB16w8u03ECHFzIenRhJmJ4MmJrVlA0I
         UzRqlGzyGD7GlAQGODpcdA6W1z0XlbkpB32SPgMIRDo2QL3Y5BkmCdsGlbVY//RNfyVS
         +nTKATibLPRBnK4Yxi+mXFRikl8Y4p209LdGOh4CWTHfhsUBOQKvu2E3XK3ZLBkM9fQt
         YRtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EbwbRCaT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p58sor18609482qtb.8.2019.06.17.17.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 17:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EbwbRCaT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xyVcNd9oooqBQ01pz08myANSFTdx0SwnrW4fjYnawJM=;
        b=EbwbRCaTtFd2OjM2jNOG+48iONnisGaulMgt8GBSlGmHHmNOKbiX/pQ5UIlGAp8yUz
         vNA1zIvWXYK1S4TWgK+86NqYoCUVC/0ZevX6IRfWzWSNvQ8g+Og+/8wxKQstLAZ+revM
         VL5EZh1MRj6Ew8rlA3u8Y12VqUKY0LSaNX6vUqI1xIiehSserEbesl80q+pA69T5mmHc
         9ILTNBce92/Mo7e4Kup6uNkn8cC7R1Ht2U5myxg80c8SBX/Bf59IAzM3jiTwz6+ORmYB
         TG1ZP8xw47a6bZF6oV577gILRTEpeuB3t1687rIrkCR/XgY0ASSrboWRYKGE3cjxdvtm
         1zGA==
X-Google-Smtp-Source: APXvYqwWPeoiWiUq38eemfOuoOnFZtRLG1ij33tWBeptCPrHnF05gR5s5sk1ou0VyceV16bnn7ukkQ==
X-Received: by 2002:ac8:2763:: with SMTP id h32mr99156393qth.350.1560818710425;
        Mon, 17 Jun 2019 17:45:10 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id z57sm9460981qta.62.2019.06.17.17.45.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 17:45:09 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hd2FJ-0000ob-FF; Mon, 17 Jun 2019 21:45:09 -0300
Date: Mon, 17 Jun 2019 21:45:09 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190618004509.GE30762@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
 <20190615142106.GK17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615142106.GK17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:21:06AM -0700, Christoph Hellwig wrote:
> On Thu, Jun 13, 2019 at 09:44:49PM -0300, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > hmm_release() is called exactly once per hmm. ops->release() cannot
> > accidentally trigger any action that would recurse back onto
> > hmm->mirrors_sem.
> 
> In linux-next amdgpu actually calls hmm_mirror_unregister from its
> release function.  That whole release function looks rather sketchy,
> but we probably need to sort that out first.

Does it? I see this:

static void amdgpu_hmm_mirror_release(struct hmm_mirror *mirror)
{
        struct amdgpu_mn *amn = container_of(mirror, struct amdgpu_mn, mirror);

        INIT_WORK(&amn->work, amdgpu_mn_destroy);
        schedule_work(&amn->work);
}

static struct hmm_mirror_ops amdgpu_hmm_mirror_ops[] = {
        [AMDGPU_MN_TYPE_GFX] = {
                .sync_cpu_device_pagetables = amdgpu_mn_sync_pagetables_gfx,
                .release = amdgpu_hmm_mirror_release
        },
        [AMDGPU_MN_TYPE_HSA] = {
                .sync_cpu_device_pagetables = amdgpu_mn_sync_pagetables_hsa,
                .release = amdgpu_hmm_mirror_release
        },
};


Am I looking at the wrong thing? Looks like it calls it through a work
queue should should be OK..

Though very strange that amdgpu only destroys the mirror via release,
that cannot be right.

Jason

