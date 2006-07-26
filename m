Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.7/8.13.7) with ESMTP id k6QAsLQ3111424
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 10:54:21 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6QAvcR2065314
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 12:57:38 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6QAsKo8019084
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 12:54:21 +0200
Date: Wed, 26 Jul 2006 12:52:04 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
Message-ID: <20060726105204.GF9592@osiris.boeblingen.de.ibm.com>
References: <Pine.LNX.4.64.0607220748160.13737@schroedinger.engr.sgi.com> <20060722162607.GA10550@osiris.ibm.com> <Pine.LNX.4.64.0607221241130.14513@schroedinger.engr.sgi.com> <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com> <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI> <20060726101340.GE9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 26, 2006 at 01:37:42PM +0300, Pekka J Enberg wrote:
> On Wed, 26 Jul 2006, Heiko Carstens wrote:
> > It's enough to fix the ARCH_SLAB_MINALIGN problem. But it does _not_ fix the
> > ARCH_KMALLOC_MINALIGN problem. s390 currently only uses ARCH_KMALLOC_MINALIGN
> > since that should be good enough and it doesn't disable as much debugging
> > as ARCH_SLAB_MINALIGN does.
> > What exactly isn't clear from the description of the first patch? Or why do
> > you consider it bogus?
> 
> Now I am confused. What do you mean by "doesn't disable as much debugging 
> as ARCH_SLAB_MINALIGN does"? AFAICT, the SLAB_RED_ZONE and SLAB_STORE_USER 
> options _require_ BYTES_PER_WORD alignment, so if s390 requires 8 
> byte alignment, you can't have them debugging anyhow...

We only specify ARCH_KMALLOC_MINALIGN, since that aligns only the kmalloc
caches, but it doesn't disable debugging on other caches that are created
via kmem_cache_create() where an alignment of e.g. 0 is specified.

The point of the first patch is: why should the slab cache be allowed to chose
an aligment that is less than what the caller specified? This does very likely
break things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
