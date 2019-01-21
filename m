Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 500F38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:53:25 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id p79so20469494qki.15
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:53:25 -0800 (PST)
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id o89si3159903qvo.208.2019.01.21.13.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 13:53:24 -0800 (PST)
Date: Mon, 21 Jan 2019 21:53:24 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
In-Reply-To: <20190121174220.10583-7-dave@stgolabs.net>
Message-ID: <01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@email.amazonses.com>
References: <20190121174220.10583-1-dave@stgolabs.net> <20190121174220.10583-7-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Mon, 21 Jan 2019, Davidlohr Bueso wrote:

> ib_umem_get() uses gup_longterm() and relies on the lock to
> stabilze the vma_list, so we cannot really get rid of mmap_sem
> altogether, but now that the counter is atomic, we can get of
> some complexity that mmap_sem brings with only pinned_vm.

Reviewd-by: Christoph Lameter <cl@linux.com>
