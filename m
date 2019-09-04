Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A1E2C3A5AA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3934B2339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:17:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3934B2339D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0296C6B0003; Wed,  4 Sep 2019 15:17:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1D656B0006; Wed,  4 Sep 2019 15:17:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E33556B0007; Wed,  4 Sep 2019 15:17:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id C1D676B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:17:41 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 58466180AD7C3
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:17:41 +0000 (UTC)
X-FDA: 75898197522.09.snow94_602aab65b6327
X-HE-Tag: snow94_602aab65b6327
X-Filterd-Recvd-Size: 10888
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:17:40 +0000 (UTC)
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B7E0CC0035AC
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:17:39 +0000 (UTC)
Received: by mail-qt1-f199.google.com with SMTP id e2so23977699qtm.19
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 12:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=NLpKeAwvZauzvcOfJSaBzm71bWfF1nQX4VNdTFWyNbM=;
        b=edCmlu1Bfs8QiUZFRNKsim3GqxRyVFAkVdat/zhXsYEMY/L4SRL7JGbri2A7pMjbx/
         Rris/7JRMQoWTNfI23hXMjk7sz8AbFPvmumwZhPhDSfPP2aynikLRbrcVHSYtCXK/zIZ
         MsoKRfpgHuJN7pFnKsut0qVW50R69t6AUbpgL//C5hcJRj5LgBt8kyYPU8K3pVzR9VX0
         uUfxzQeud7ydOzKnmBpH/0wMua49d2GTfJfhKhCJdOprQL6p61XPO3Wsept2ebRRWvl6
         apAZyiawXotcLpop9AOn9mjLIOT+oxgC2UL6XqhSjS29G8nIcTuvkDhATG7axCR2Uy67
         maBw==
X-Gm-Message-State: APjAAAVcmbyZDTHpOuPHZOvlsIPTGWLLDfQkCPFCbbFMn7iE+/JPIBJ8
	bEOe1FdVYVxtfb/hLiGhRdxvZxXPPvI8xmPxiGBEx78siDvMWI751HE1dxMF5rVgJF+6lZO7vBO
	UaJo0YWI9Uok=
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr3225422qkg.322.1567624659001;
        Wed, 04 Sep 2019 12:17:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWjJJxTtJMCodNG6EuPoW8uo1j4PC6B+gOb6eq6oLuZsuTw8KZFD0YucnQew4oSYn37D6/mQ==
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr3225401qkg.322.1567624658823;
        Wed, 04 Sep 2019 12:17:38 -0700 (PDT)
Received: from redhat.com (bzq-79-176-40-226.red.bezeqint.net. [79.176.40.226])
        by smtp.gmail.com with ESMTPSA id d13sm5728359qkj.18.2019.09.04.12.17.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 12:17:37 -0700 (PDT)
Date: Wed, 4 Sep 2019 15:17:30 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org,
	osalvador@suse.de, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v7 6/6] virtio-balloon: Add support for providing unused
 page reports to host
Message-ID: <20190904151506-mutt-send-email-mst@kernel.org>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
 <20190904151102.13848.65770.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904151102.13848.65770.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 08:11:02AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Add support for the page reporting feature provided by virtio-balloon.
> Reporting differs from the regular balloon functionality in that is is
> much less durable than a standard memory balloon. Instead of creating a
> list of pages that cannot be accessed the pages are only inaccessible
> while they are being indicated to the virtio interface. Once the
> interface has acknowledged them they are placed back into their respective
> free lists and are once again accessible by the guest system.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  drivers/virtio/Kconfig              |    1 +
>  drivers/virtio/virtio_balloon.c     |   65 +++++++++++++++++++++++++++++++++++
>  include/uapi/linux/virtio_balloon.h |    1 +
>  3 files changed, 67 insertions(+)
> 
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 078615cf2afc..4b2dd8259ff5 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
>  	select MEMORY_BALLOON
> +	select PAGE_REPORTING
>  	---help---
>  	 This driver supports increasing and decreasing the amount
>  	 of memory within a KVM guest.
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 2c19457ab573..0b400bb382c0 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -19,6 +19,7 @@
>  #include <linux/mount.h>
>  #include <linux/magic.h>
>  #include <linux/pseudo_fs.h>
> +#include <linux/page_reporting.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -37,6 +38,9 @@
>  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
>  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
>  
> +/*  limit on the number of pages that can be on the reporting vq */
> +#define VIRTIO_BALLOON_VRING_HINTS_MAX	16
> +
>  #ifdef CONFIG_BALLOON_COMPACTION
>  static struct vfsmount *balloon_mnt;
>  #endif
> @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
>  	VIRTIO_BALLOON_VQ_DEFLATE,
>  	VIRTIO_BALLOON_VQ_STATS,
>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> +	VIRTIO_BALLOON_VQ_REPORTING,
>  	VIRTIO_BALLOON_VQ_MAX
>  };
>  
> @@ -113,6 +118,10 @@ struct virtio_balloon {
>  
>  	/* To register a shrinker to shrink memory upon memory pressure */
>  	struct shrinker shrinker;
> +
> +	/* Unused page reporting device */
> +	struct virtqueue *reporting_vq;
> +	struct page_reporting_dev_info ph_dev_info;
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -152,6 +161,32 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  
>  }
>  
> +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> +				    unsigned int nents)
> +{
> +	struct virtio_balloon *vb =
> +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> +	struct virtqueue *vq = vb->reporting_vq;
> +	unsigned int unused, err;
> +
> +	/* We should always be able to add these buffers to an empty queue. */
> +	err = virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> +				  GFP_NOWAIT | __GFP_NOWARN);
> +
> +	/*
> +	 * In the extremely unlikely case that something has changed and we
> +	 * are able to trigger an error we will simply display a warning
> +	 * and exit without actually processing the pages.
> +	 */
> +	if (WARN_ON(err))
> +		return;
> +
> +	virtqueue_kick(vq);
> +
> +	/* When host has read buffer, this completes via balloon_ack */
> +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> +}
> +

So just to make sure I understand, this always passes a single
buf to the vq and then waits until that completes, correct?
Thus there are never outstanding bufs on the vq and this
is why we don't need e.g. any cleanup.



>  static void set_page_pfns(struct virtio_balloon *vb,
>  			  __virtio32 pfns[], struct page *page)
>  {
> @@ -476,6 +511,7 @@ static int init_vqs(struct virtio_balloon *vb)
>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	names[VIRTIO_BALLOON_VQ_REPORTING] = NULL;
>  
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> @@ -487,11 +523,19 @@ static int init_vqs(struct virtio_balloon *vb)
>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>  	}
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> +		names[VIRTIO_BALLOON_VQ_REPORTING] = "reporting_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_REPORTING] = balloon_ack;
> +	}
> +
>  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>  					 vqs, callbacks, names, NULL, NULL);
>  	if (err)
>  		return err;
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
> +		vb->reporting_vq = vqs[VIRTIO_BALLOON_VQ_REPORTING];
> +
>  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
>  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> @@ -931,12 +975,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		if (err)
>  			goto out_del_balloon_wq;
>  	}
> +
> +	vb->ph_dev_info.report = virtballoon_unused_page_report;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> +		unsigned int capacity;
> +
> +		capacity = min_t(unsigned int,
> +				 virtqueue_get_vring_size(vb->reporting_vq),
> +				 VIRTIO_BALLOON_VRING_HINTS_MAX);
> +		vb->ph_dev_info.capacity = capacity;
> +
> +		err = page_reporting_startup(&vb->ph_dev_info);
> +		if (err)
> +			goto out_unregister_shrinker;
> +	}
> +
>  	virtio_device_ready(vdev);
>  
>  	if (towards_target(vb))
>  		virtballoon_changed(vdev);
>  	return 0;
>  
> +out_unregister_shrinker:
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> +		virtio_balloon_unregister_shrinker(vb);
>  out_del_balloon_wq:
>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
>  		destroy_workqueue(vb->balloon_wq);
> @@ -965,6 +1027,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb = vdev->priv;
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
> +		page_reporting_shutdown(&vb->ph_dev_info);
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		virtio_balloon_unregister_shrinker(vb);
>  	spin_lock_irq(&vb->stop_update_lock);
> @@ -1034,6 +1098,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>  	VIRTIO_BALLOON_F_PAGE_POISON,
> +	VIRTIO_BALLOON_F_REPORTING,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index a1966cd7b677..19974392d324 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -36,6 +36,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12

