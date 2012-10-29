Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 04DCF6B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:51:27 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4743649pbb.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:51:27 -0700 (PDT)
Date: Mon, 29 Oct 2012 08:51:22 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: change a method freeing a chunk for consistency.
Message-ID: <20121029155122.GM5171@htj.dyndns.org>
References: <1351519198-5075-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351519198-5075-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Mon, Oct 29, 2012 at 10:59:58PM +0900, Joonsoo Kim wrote:
> commit 099a19d9('allow limited allocation before slab is online') changes a method
> allocating a chunk from kzalloc to pcpu_mem_alloc.
> But, it missed changing matched free operation.
> It may not be a problem for now, but fix it for consistency.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>

Applied to percpu/for-3.8 w/ commit message updated.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
