Date: Wed, 26 Jul 2006 13:37:42 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
In-Reply-To: <20060726101340.GE9592@osiris.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI>
References: <20060722110601.GA9572@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.64.0607220748160.13737@schroedinger.engr.sgi.com>
 <20060722162607.GA10550@osiris.ibm.com> <Pine.LNX.4.64.0607221241130.14513@schroedinger.engr.sgi.com>
 <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com>
 <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI>
 <20060726101340.GE9592@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jul 2006, Heiko Carstens wrote:
> It's enough to fix the ARCH_SLAB_MINALIGN problem. But it does _not_ fix the
> ARCH_KMALLOC_MINALIGN problem. s390 currently only uses ARCH_KMALLOC_MINALIGN
> since that should be good enough and it doesn't disable as much debugging
> as ARCH_SLAB_MINALIGN does.
> What exactly isn't clear from the description of the first patch? Or why do
> you consider it bogus?

Now I am confused. What do you mean by "doesn't disable as much debugging 
as ARCH_SLAB_MINALIGN does"? AFAICT, the SLAB_RED_ZONE and SLAB_STORE_USER 
options _require_ BYTES_PER_WORD alignment, so if s390 requires 8 
byte alignment, you can't have them debugging anyhow...

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
