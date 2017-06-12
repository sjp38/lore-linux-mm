Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4093A6B02FD
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:07:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t126so53371653pgc.9
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:07:18 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n17si12652880pgd.388.2017.06.12.07.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 07:07:17 -0700 (PDT)
Subject: Re: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <db8cc3d1-50fc-2412-af2f-1070dda38be3@intel.com>
Date: Mon, 12 Jun 2017 07:07:15 -0700
MIME-Version: 1.0
In-Reply-To: <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/09/2017 03:41 AM, Wei Wang wrote:
> +	for_each_populated_zone(zone) {
> +		for (order = MAX_ORDER - 1; order > 0; order--) {
> +			for (migratetype = 0; migratetype < MIGRATE_TYPES;
> +			     migratetype++) {
> +				do {
> +					ret = report_unused_page_block(zone,
> +						order, migratetype, &page);
> +					if (!ret) {
> +						pfn = (u64)page_to_pfn(page);
> +						add_one_chunk(vb, vq,
> +						PAGE_CHNUK_UNUSED_PAGE,
> +						pfn << VIRTIO_BALLOON_PFN_SHIFT,
> +						(u64)(1 << order) *
> +						VIRTIO_BALLOON_PAGES_PER_PAGE);
> +					}
> +				} while (!ret);
> +			}
> +		}
> +	}

This is pretty unreadable.    Please add some indentation.  If you go
over 80 cols, then you might need to break this up into a separate
function.  But, either way, it can't be left like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
