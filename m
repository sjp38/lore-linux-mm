Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B23116B0006
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:41:28 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 31so5403829wru.0
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:41:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d6si4245872wre.377.2018.01.25.14.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 14:41:27 -0800 (PST)
Date: Thu, 25 Jan 2018 14:41:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v25 1/2 RESEND] mm: support reporting free page blocks
Message-Id: <20180125144124.7e9f6e2156b1b940b07aecfc@linux-foundation.org>
In-Reply-To: <1516873107-34950-1-git-send-email-wei.w.wang@intel.com>
References: <1516873107-34950-1-git-send-email-wei.w.wang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Thu, 25 Jan 2018 17:38:27 +0800 Wei Wang <wei.w.wang@intel.com> wrote:

> This patch adds support to walk through the free page blocks in the
> system and report them via a callback function. Some page blocks may
> leave the free list after zone->lock is released, so it is the caller's
> responsibility to either detect or prevent the use of such pages.
> 
> One use example of this patch is to accelerate live migration by skipping
> the transfer of free pages reported from the guest. A popular method used
> by the hypervisor to track which part of memory is written during live
> migration is to write-protect all the guest memory. So, those pages that
> are reported as free pages but are written after the report function
> returns will be captured by the hypervisor, and they will be added to the
> next round of memory transfer.

It would be useful if we had some quantitative testing results, so we
can see the real-world benefits from this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
