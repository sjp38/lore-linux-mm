Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9C676B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:16:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so731075pfr.3
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 00:16:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b1si349188pgq.241.2017.10.17.00.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 00:16:40 -0700 (PDT)
Date: Tue, 17 Oct 2017 00:16:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Message-ID: <20171017071633.GA9207@infradead.org>
References: <20171012155027.3277-1-pagupta@redhat.com>
 <20171012155027.3277-3-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012155027.3277-3-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com

I think this driver is at entirely the wrong level.

If you want to expose pmem to a guest with flushing assist do it
as pmem, and not a block driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
