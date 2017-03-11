Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6FD6B0469
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 09:09:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 67so212073161pfg.0
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 06:09:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l70si6274242pgd.86.2017.03.11.06.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 06:09:52 -0800 (PST)
Date: Sat, 11 Mar 2017 06:09:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Message-ID: <20170311140946.GA1860@bombadil.infradead.org>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org>
 <58C28FF8.5040403@intel.com>
 <20170310175349-mutt-send-email-mst@kernel.org>
 <20170310171143.GA16328@bombadil.infradead.org>
 <58C3E6A3.1000000@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58C3E6A3.1000000@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Sat, Mar 11, 2017 at 07:59:31PM +0800, Wei Wang wrote:
> I'm thinking what if the guest needs to transfer these much physically
> continuous
> memory to host: 1GB+2MB+64KB+32KB+16KB+4KB.
> Is it going to use Six 64-bit chunks? Would it be simpler if we just
> use the 128-bit chunk format (we can drop the previous normal 64-bit
> format)?

Is that a likely thing for the guest to need to do though?  Freeing a
1GB page is much more liikely, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
