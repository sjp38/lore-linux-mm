Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23829C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC10221907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:59:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC10221907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A36A6B02F2; Wed, 18 Sep 2019 13:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 654E66B02F4; Wed, 18 Sep 2019 13:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56B096B02F5; Wed, 18 Sep 2019 13:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35B326B02F2
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:59:08 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CF58B181AC9AE
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:59:07 +0000 (UTC)
X-FDA: 75948802734.23.land53_4f9ff07f56b17
X-HE-Tag: land53_4f9ff07f56b17
X-Filterd-Recvd-Size: 6128
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:59:07 +0000 (UTC)
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ED58837E79
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:59:05 +0000 (UTC)
Received: by mail-qt1-f200.google.com with SMTP id w9so932973qto.9
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:59:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=95uHNXLpbAw8Te8P7uq0ffZGCmMKa4Edsq7nRG4mv4c=;
        b=JkdePIBmdHvvZdv+MNgX9bb4kVId6xwfwgUGCk03jG/z6Qm2H+ZTi9/memT2hWoIQo
         nB+X7cSue8D14vvtZnStlRZIHOAkijnFjwWfgmUpLtEYyQhfbHS3eOG2MRjZ5aZQi3sE
         2fbLT2gIHkdOHGEbxv/nT23qcxtwaDhsBLJiPSCjv0fRi8pswPPodQ6C4USsdX8FzBz7
         bgk3Vy5d6TmfCKOdvOM0JtxYQPZOX2TU/oVprzcUnCXvtcK+EA//CYgzEcnqcXJXORnO
         Z5PxXVyqTedL/rrlbcN/KO2uxUBV8r8nXeYK1pabQfnwWQW9r3pSSgmIfSQ9fHi69fyY
         GWAQ==
X-Gm-Message-State: APjAAAWD4dm3n1U4y0Lj5Mmr4hxvvUoXi9+5GNP64fKTKdZeyzA/tPaR
	SDZ/9H03f5i0DRYbisIiIxpJjATDr9FtrsAVnEJBf43Ko++OpY5sT9ya+11jNhm0wkIEXbJ8qtI
	nPHViVMOO650=
X-Received: by 2002:ac8:7b2a:: with SMTP id l10mr5571335qtu.115.1568829545296;
        Wed, 18 Sep 2019 10:59:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp4kWwOScH3+FsPGYP96mLuwlTyG0LsIAHV0yLqSSN4DKzmnPp2MGayN7dp76k/rTEPpJp8A==
X-Received: by 2002:ac8:7b2a:: with SMTP id l10mr5571319qtu.115.1568829545135;
        Wed, 18 Sep 2019 10:59:05 -0700 (PDT)
Received: from redhat.com (bzq-79-176-40-226.red.bezeqint.net. [79.176.40.226])
        by smtp.gmail.com with ESMTPSA id q126sm3855323qkf.47.2019.09.18.10.58.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Sep 2019 10:59:04 -0700 (PDT)
Date: Wed, 18 Sep 2019 13:58:55 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org,
	vbabka@suse.cz, akpm@linux-foundation.org,
	mgorman@techsingularity.net, linux-arm-kernel@lists.infradead.org,
	osalvador@suse.de, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	konrad.wilk@oracle.com, nitesh@redhat.com, riel@surriel.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v10 5/6] virtio-balloon: Pull page poisoning config out
 of free page hinting
Message-ID: <20190918135833-mutt-send-email-mst@kernel.org>
References: <20190918175109.23474.67039.stgit@localhost.localdomain>
 <20190918175305.23474.34783.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918175305.23474.34783.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 10:53:05AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Currently the page poisoning setting wasn't being enabled unless free page
> hinting was enabled. However we will need the page poisoning tracking logic
> as well for unused page reporting. As such pull it out and make it a
> separate bit of config in the probe function.
> 
> In addition we can actually wrap the code in a check for NO_SANITY. If we
> don't care what is actually in the page we can just default to 0 and leave
> it there.
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

I think this one can go in directly. Do you want me to merge it now?

> ---
>  drivers/virtio/virtio_balloon.c |   22 +++++++++++++++-------
>  1 file changed, 15 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 226fbb995fb0..501a8d0ebf86 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> -	__u32 poison_val;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -909,11 +908,18 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  						  VIRTIO_BALLOON_CMD_ID_STOP);
>  		spin_lock_init(&vb->free_page_list_lock);
>  		INIT_LIST_HEAD(&vb->free_page_list);
> -		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> -			memset(&poison_val, PAGE_POISON, sizeof(poison_val));
> -			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> -				      poison_val, &poison_val);
> -		}
> +	}
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> +		__u32 poison_val;
> +
> +		/*
> +		 * Let the hypervisor know that we are expecting a
> +		 * specific value to be written back in unused pages.
> +		 */
> +		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
> +
> +		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> +			      poison_val, &poison_val);
>  	}
>  	/*
>  	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
> @@ -1014,7 +1020,9 @@ static int virtballoon_restore(struct virtio_device *vdev)
>  
>  static int virtballoon_validate(struct virtio_device *vdev)
>  {
> -	if (!page_poisoning_enabled())
> +	/* Tell the host whether we care about poisoned pages. */
> +	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
> +	    !page_poisoning_enabled())
>  		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
>  
>  	__virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);

