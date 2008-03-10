Date: Mon, 10 Mar 2008 12:20:10 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: what to patch
Message-Id: <20080310122010.a2170c9c.randy.dunlap@oracle.com>
In-Reply-To: <20080310120902.5f25b9f9.akpm@linux-foundation.org>
References: <alpine.DEB.1.00.0803071720460.4611@chino.kir.corp.google.com>
	<20080310120902.5f25b9f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Mar 2008 12:09:02 -0700 Andrew Morton wrote:

> I get a significant-looking reject from this.  Can you please redo and
> resend?
> 
> 
> I put my current rollup (against -rc5) at
> http://userweb.kernel.org/~akpm/dr.gz and the broken-out tree is, as always
> at http://userweb.kernel.org/~akpm/mmotm/
> 
> It would be better for you to get set up for using mmotm - it is my usual
> way of publishing the -mm queue between releases.

Speaking of what to patch, I'm looking at making a big set of
kernel-docbook changes/fixes/additions to the mm/ subdir.
Should I make patches to mainline or -mm (or mmotm) or what?

mm/ seems to have a *lot* of patches. ;)

Thanks,
---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
