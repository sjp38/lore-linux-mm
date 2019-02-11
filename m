Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47B9EC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B2C1222A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B2C1222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9000A8E0143; Mon, 11 Feb 2019 14:25:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AF038E0134; Mon, 11 Feb 2019 14:25:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79EC28E0143; Mon, 11 Feb 2019 14:25:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51C9E8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:25:03 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id s4so55654qts.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:25:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=zE1Ol7a3GppKMtEDRVuBxnEUwh6Dn7Ves8xXxbBZo0Q=;
        b=FvgDX59NwRp8dnOYvrrVJdrOgp2yqBoYb6V5c62zMi5yg+jdpzx3Xf409ZVQo7aN6H
         ffJPRcVE3fj6WoXiVnAbQJbwTWcOypb3/fLcu8VHEPpuSTb+m6kng352T/PFLtId7srN
         h4b9GbLi8MypaMjAj7NfEkm0D4ZGnZ/0QXgnQjIcvh+N3tcxfDzOvkyT+E9Gwt2KdMM1
         ydLoycBAxlJ1r1qHcsE1M1kvrZbMlPC4V6ycRLkcxx+iO/0GjCcPXfQq3tTlXtg0XL1L
         hLBLigPdLYcTe9p3xGThws3DA52Lt6rWaz5/Unb7dlKS54Dwvt5Z/07w/is6s8Cq89kj
         gp1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuasehhqZL9phtIG049I9FQ5KUjxSgtHzj3g5biOFBdewuUKwfQn
	iTKXPke/mFSbY1FF8sfJJhotFjY7E4EnMKiXSD8zU9V87IHJjUmbeREG8WSbZQoYQAkkxBLm8ku
	ifAvsV55l6HalTjDI2PtRaJhpKmfwkPQF/QWjf6POiGwy+H8zwECEhWi8z8D39s2Nlg==
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr19636158qta.48.1549913103100;
        Mon, 11 Feb 2019 11:25:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZRZLGtOK0KyR6MvzoRdt1CumhFd1fee7/CJr4NcDoO7SUz49YNEF+lcXTtXJ9yu5c475y
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr19636113qta.48.1549913102485;
        Mon, 11 Feb 2019 11:25:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913102; cv=none;
        d=google.com; s=arc-20160816;
        b=CvQatzWmPyHze0OuMRkjTjjmpAd565t0iFDv/9+8Pz1jKLiEeQuQoPwEccn9e+X7I8
         X0EPb7+qMU7PhtC5WWK9Ihdi3MPWZcDVnbPi0dzyyvO+bgxIwDGn+gaRDoP03bz/ui72
         szB96f0t28DeelQMV64Cde5oreLV98Ovswk4EloSutzEtHqMjItIf0h74+D08CjEFK9u
         pvbjgKkda4122o76D28r1J9afX3pusRTXYbqoAlLrzKPvrcaGLr4mpMBGL2SaSgSIOQ6
         60AE0mEqH5+zXhsvSeZB9D3xuworQP2kOXgxzhmCYWWjVoOfrUB+SADnqu0rFh7TxfGz
         ajJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=zE1Ol7a3GppKMtEDRVuBxnEUwh6Dn7Ves8xXxbBZo0Q=;
        b=eg4E6PiFYcN7LWhz/+2vpSR1/HYU7TR5/T6DZVxdCQYC4P45203tBefUrV7jHOgRew
         M1hi+49o69ry7F8CsiZjzakW1Az9KgMJWeDT8WrzCRvcMGdEOyKTNk54mRk7Aky/r3hI
         hK2xWb0yNB13LmpB1tI131TFOzg9UbgEgLObtDuCRE14x/f0l1gWZQR4TUZsfJCK/4/g
         8KpeaCCO15kQ6cK/NILj8R7tfRiGvmM4yQfRtIFv5TaHzhXcRTJxy2x50bbShsvF6ex2
         91g+W2ZXa7EI7GEyG+fDjJYDwUt8F5egs79kxS4GG6vb9Gti0ODz5szb8ZNNMsiBky8b
         RdKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si204280qta.88.2019.02.11.11.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:25:02 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EFDC57E9E1;
	Mon, 11 Feb 2019 19:25:00 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id F3C31611D1;
	Mon, 11 Feb 2019 19:24:58 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:24:58 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
	hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
	akpm@linux-foundation.org
Subject: Re: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
Message-ID: <20190211141811-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181546.12095.81356.stgit@localhost.localdomain>
 <20190209194108-mutt-send-email-mst@kernel.org>
 <39c915a7-e317-db01-0286-579230f37da2@intel.com>
 <20190211124203-mutt-send-email-mst@kernel.org>
 <58e57acd628f2d6535fc45a028af50855158fda6.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58e57acd628f2d6535fc45a028af50855158fda6.camel@linux.intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 11 Feb 2019 19:25:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:30:10AM -0800, Alexander Duyck wrote:
> On Mon, 2019-02-11 at 12:48 -0500, Michael S. Tsirkin wrote:
> > On Mon, Feb 11, 2019 at 09:41:19AM -0800, Dave Hansen wrote:
> > > On 2/9/19 4:44 PM, Michael S. Tsirkin wrote:
> > > > So the policy should not leak into host/guest interface.
> > > > Instead it is better to just keep the pages pinned and
> > > > ignore the hint for now.
> > > 
> > > It does seems a bit silly to have guests forever hinting about freed
> > > memory when the host never has a hope of doing anything about it.
> > > 
> > > Is that part fixable?
> > 
> > 
> > Yes just not with existing IOMMU APIs.
> > 
> > It's in the paragraph just above that you cut out:
> > 	Yes right now assignment is not smart enough but generally
> > 	you can protect the unused page in the IOMMU and that's it,
> > 	it's safe.
> > 
> > So e.g.
> > 	extern int iommu_remap(struct iommu_domain *domain, unsigned long iova,
> > 				     phys_addr_t paddr, size_t size, int prot);
> > 
> > 
> > I can elaborate if you like but generally we would need an API that
> > allows you to atomically update a mapping for a specific page without
> > perturbing the mapping for other pages.
> > 
> 
> I still don't see how this would solve anything unless you have the
> guest somehow hinting on what pages it is providing to the devices. 
>
> You would have to have the host invalidating the pages when the hint is
> provided, and have a new hint tied to arch_alloc_page that would
> rebuild the IOMMU mapping when a page is allocated.
> 
> I'm pretty certain that the added cost of that would make the hinting
> pretty pointless as my experience has been that the IOMMU is too much
> of a bottleneck to have multiple CPUs trying to create and invalidate
> mappings simultaneously.

I agree it's a concern.

Another option would involve passing these hints in the DMA API.

How about the option of removing the device by hotplug when
host needs overcommit? That would involve either buffering
on host, or requesting free pages after device is removed
along the lines of existing balloon code. That btw seems to
be an argument for making this hinting part of balloon.


-- 
MST

