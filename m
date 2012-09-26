Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 0AC136B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 02:34:49 -0400 (EDT)
Date: Wed, 26 Sep 2012 09:34:37 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm/slab: Fix kmem_cache_alloc_node_trace() declaration
Message-ID: <20120926063437.GZ4587@mwanda>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
 <1348571229-844-2-git-send-email-elezegarcia@gmail.com>
 <alpine.DEB.2.00.1209252115000.28360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209252115000.28360@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, kernel-janitors@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Pekka Enberg <penberg@kernel.org>

On Tue, Sep 25, 2012 at 09:18:02PM -0700, David Rientjes wrote:
> On Tue, 25 Sep 2012, Ezequiel Garcia wrote:
> 
> > The bug was introduced in commit 4052147c0afa
> > "mm, slab: Match SLAB and SLUB kmem_cache_alloc_xxx_trace() prototype".
> > 
> 
> This isn't a candidate for kernel-janitors@vger.kernel.org, these are 
> patches that are one of Pekka's branches and would never make it to Linus' 
> tree in this form.

kernel-janitors got CC'd because it was a compile problem.  It stops
us from sending duplicate messages to people.  It's surprising how
annoyed people get about duplicates instead of just ignoring the
second messages like sane individuals would.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
