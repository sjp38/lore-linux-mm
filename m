Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AD8EA6B01B9
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:46:58 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:47:09 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: kmem_cache_destroy() badness with SLUB
In-Reply-To: <1277688701.4200.159.camel@pasglop>
Message-ID: <alpine.DEB.2.00.1006291046230.16135@router.home>
References: <1277688701.4200.159.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, Benjamin Herrenschmidt wrote:

> So if the slab is created -and- destroyed at, for example, arch_initcall
> time, then we hit a WARN in the kobject code, trying to dispose of a
> non-existing kobject.

Yes dont do that.

> Now, at first sight, just adding the same test to sysfs_slab_remove()
> would do the job... but it all seems very racy to me.

Yes lets leave as is. Dont remove slabs during boot.

> Shouldn't we have a mutex around those guys ?

At boot time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
