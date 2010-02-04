Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A1F246B0071
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 19:08:10 -0500 (EST)
Date: Thu, 4 Feb 2010 09:07:56 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC] slub: ARCH_SLAB_MINALIGN defaults to 8 on x86_32. is this too big?
Message-ID: <20100204000755.GA451@linux-sh.org>
References: <1265206946.2118.57.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1265206946.2118.57.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03, 2010 at 02:22:26PM +0000, Richard Kennedy wrote:
> Can I define a ARCH_SLAB_MINALIGN in x86_64 to sizeof(void *) ? 
> or would it be ok to change the default in slub.c to sizeof(void *) ?
> 
Note that this is precisely what ARCH_SLAB_MINALIGN was introduced to
avoid (BYTES_PER_WORD alignment used to be the default for slab, before
ARCH_SLAB_MINALIGN was introduced). Consider the case of 64-bit platforms
using a 32-bit ABI, the native alignment remains 64-bit while sizeof(void
*) == 4. There are a number of (mainly embedded) architectures that
support these sorts of configurations in-tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
