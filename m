Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA2E78E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:23:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i124so4449285pgc.2
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:23:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z63si46713619pfz.132.2019.01.09.08.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Jan 2019 08:23:33 -0800 (PST)
Date: Wed, 9 Jan 2019 08:23:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
Message-ID: <20190109162332.GL6310@bombadil.infradead.org>
References: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com

On Wed, Jan 09, 2019 at 09:49:17PM +0530, Souptick Joarder wrote:
> convert to use vm_fault_t type as return type for
> fault handler.

I think you'll also need to convert hmm_devmem_fault().  And that's
going to lead to some more spots.

(It's important to note that this is the patch working as designed.  It's
throwing up warnings where code *hasn't* been converted to vm_fault_t yet
but should have been).
