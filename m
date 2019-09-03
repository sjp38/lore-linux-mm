Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8CA3C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D69422CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D69422CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00AE86B0003; Tue,  3 Sep 2019 03:32:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFBFE6B0005; Tue,  3 Sep 2019 03:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13B16B0006; Tue,  3 Sep 2019 03:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id BFBE96B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 03:32:22 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 57EB4824CA39
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:32:22 +0000 (UTC)
X-FDA: 75892791324.11.queen55_88ffb63d45d22
X-HE-Tag: queen55_88ffb63d45d22
X-Filterd-Recvd-Size: 10932
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:32:21 +0000 (UTC)
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1295F335D7
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:32:20 +0000 (UTC)
Received: by mail-qt1-f200.google.com with SMTP id i19so17948507qtq.17
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 00:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=YKJ/17m0nY3+PfopzWmNRULBrW/5r9BKa8USWY7P99Y=;
        b=XFBXqF+L+ph+xFBNaUWQX4st6QvhNn0n1ZRDZsIucosVH+UL4gsT7cqTQgdWGZ6Bj7
         JYAFQktWPsTRlm8OlYMtLKc0JciYrci6DLP6CfJF0vZqOqNOPB5fLFzL9+DA7NuEew8r
         d8RzROdCDOGWouo8OTegWOjc3L+h+hm4pAcGEDfDXtO39AwmQKlIrUxBO2EU92nyKJ2A
         XtMmSAf+mYsOd8Ch1r/trdjWjQscevqlWs55CQl8e+YoQfjfcSf9xgyRapGVjaCUN3Mz
         mpDXG9CxLgI5uRKr0aa4vEy6GwVdx9xzT+uoykf+juLoU2uUaOTzgFRs1lBgaJZ1q6kC
         VQ1w==
X-Gm-Message-State: APjAAAVuD5o45gqGiwmazOoZmiAA8/XdDyQfFOHY9ILah56kx8s4HkUt
	YRP7WfEwrBGGLcMh9m/IZtJT7lS5/8G6ZdxEe4iosldJvfoccUqcNtk6RNsnfBt8wmREoSHAXrn
	zEHWYdpjWp7s=
X-Received: by 2002:a05:620a:234:: with SMTP id u20mr10853604qkm.11.1567495939311;
        Tue, 03 Sep 2019 00:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBD33tlOTzZP8VA84/vyopsm4vvDT4u6GJo95GdpFHS9UdnFj15rANJyBZtbYAXvKG/zCLwA==
X-Received: by 2002:a05:620a:234:: with SMTP id u20mr10853568qkm.11.1567495939082;
        Tue, 03 Sep 2019 00:32:19 -0700 (PDT)
Received: from redhat.com (bzq-79-180-62-110.red.bezeqint.net. [79.180.62.110])
        by smtp.gmail.com with ESMTPSA id e7sm7324858qtp.91.2019.09.03.00.32.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 00:32:18 -0700 (PDT)
Date: Tue, 3 Sep 2019 03:32:10 -0400
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
Subject: Re: [PATCH v5 6/6] virtio-balloon: Add support for providing unused
 page reports to host
Message-ID: <20190903032759-mutt-send-email-mst@kernel.org>
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
 <20190812213356.22097.20751.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812213356.22097.20751.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 02:33:56PM -0700, Alexander Duyck wrote:
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
> index 2c19457ab573..52f9eeda1877 100644
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
> +				 virtqueue_get_vring_size(vb->reporting_vq) - 1,
> +				 VIRTIO_BALLOON_VRING_HINTS_MAX);

Hmm why - 1 exactly?
This might end up being 0 in the unusual configuration of vq size 1.
Also, VIRTIO_BALLOON_VRING_HINTS_MAX is a power of 2 but
virtqueue_get_vring_size(vb->reporting_vq) - 1 won't
be if we are using split rings - donnu if that matters.

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

