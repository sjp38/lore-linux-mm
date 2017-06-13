Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 132566B02B4
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 13:59:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g78so80926666pfg.4
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 10:59:10 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m11si482484pln.280.2017.06.13.10.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 10:59:09 -0700 (PDT)
Subject: Re: [PATCH v11 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-4-git-send-email-wei.w.wang@intel.com>
 <20170613200049-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fb67359c-3d19-f67f-ec47-3cf868b8d9e8@intel.com>
Date: Tue, 13 Jun 2017 10:59:07 -0700
MIME-Version: 1.0
In-Reply-To: <20170613200049-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Matthew Wilcox <willy@infradead.org>

On 06/13/2017 10:56 AM, Michael S. Tsirkin wrote:
>> +/* The size of one page_bmap used to record inflated/deflated pages. */
>> +#define VIRTIO_BALLOON_PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
> At this size, you probably want alloc_pages to avoid kmalloc
> overhead.

For slub, at least, kmalloc() just calls alloc_pages() basically
directly.  There's virtually no overhead.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
