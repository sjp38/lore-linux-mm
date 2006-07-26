Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k6QBTFnW130556
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 11:29:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6QBUtnF125256
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 12:30:55 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6QBTEgt008140
	for <linux-mm@kvack.org>; Wed, 26 Jul 2006 12:29:15 +0100
Date: Wed, 26 Jul 2006 13:26:58 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
Message-ID: <20060726112658.GG9592@osiris.boeblingen.de.ibm.com>
References: <Pine.LNX.4.64.0607221241130.14513@schroedinger.engr.sgi.com> <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com> <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI> <20060726101340.GE9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI> <20060726105204.GF9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 26, 2006 at 02:16:06PM +0300, Pekka J Enberg wrote:
> On Wed, 26 Jul 2006, Heiko Carstens wrote:
> > We only specify ARCH_KMALLOC_MINALIGN, since that aligns only the kmalloc
> > caches, but it doesn't disable debugging on other caches that are created
> > via kmem_cache_create() where an alignment of e.g. 0 is specified.
> > 
> > The point of the first patch is: why should the slab cache be allowed to chose
> > an aligment that is less than what the caller specified? This does very likely
> > break things.
> 
> Ah, yes, you are absolutely right. We need to respect caller mandated 
> alignment too. How about this?

Works fine and looks much better than my two patches. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
