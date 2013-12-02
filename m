Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADDA6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:55:51 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so12597860qeb.27
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:55:50 -0800 (PST)
Received: from a9-50.smtp-out.amazonses.com (a9-50.smtp-out.amazonses.com. [54.240.9.50])
        by mx.google.com with ESMTP id j1si44156211qer.115.2013.12.02.13.55.49
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 13:55:50 -0800 (PST)
Date: Mon, 2 Dec 2013 21:55:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: active obj WARN when cleaning up
In-Reply-To: <20131202212235.GA1297@kroah.com>
Message-ID: <00000142b54f6694-c51e81b1-f1a2-483b-a1ce-a2d4cb6b155c-000000@email.amazonses.com>
References: <20131127134015.GA6011@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de> <20131127233415.GB19270@kroah.com> <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com> <20131202164039.GA19937@kroah.com>
 <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com> <20131202172615.GA4722@kroah.com> <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com> <20131202190814.GA2267@kroah.com>
 <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com> <20131202212235.GA1297@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2 Dec 2013, Greg KH wrote:

> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> That looks good, if you fix the indentation issue :)

Huh?

> > Index: linux/include/linux/slub_def.h
> > ===================================================================
> > --- linux.orig/include/linux/slub_def.h	2013-12-02 13:31:07.395905824 -0600
> > +++ linux/include/linux/slub_def.h	2013-12-02 13:31:07.385906101 -0600
> > @@ -98,4 +98,8 @@ struct kmem_cache {
> >  	struct kmem_cache_node *node[MAX_NUMNODES];
> >  };
> >
> > +#ifdef CONFIG_SYSFS
> > +#define SLAB_SUPPORTS_SYSFS
>
> Why even define this?  Why not just use CONFIG_SYSFS?

Because not all slab allocators currently support SYSFS and there is the
need to have different code now in slab_common.c depending on the
configuration of the allocator.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
