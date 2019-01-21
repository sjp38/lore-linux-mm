Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1CDE8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:51:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so22394902qte.0
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:51:51 -0800 (PST)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id z12si875305qtq.2.2019.01.21.13.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 13:51:47 -0800 (PST)
Date: Mon, 21 Jan 2019 21:51:47 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] mm: make mm->pinned_vm an atomic64 counter
In-Reply-To: <20190121174220.10583-2-dave@stgolabs.net>
Message-ID: <010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@email.amazonses.com>
References: <20190121174220.10583-1-dave@stgolabs.net> <20190121174220.10583-2-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Mon, 21 Jan 2019, Davidlohr Bueso wrote
> Taking a sleeping lock to _only_ increment a variable is quite the
> overkill, and pretty much all users do this. Furthermore, some drivers
> (ie: infiniband and scif) that need pinned semantics can go to quite
> some trouble to actually delay via workqueue (un)accounting for pinned
> pages when not possible to acquire it.

Reviewed-by: Christoph Lameter <cl@linux.com>
