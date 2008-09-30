Subject: Re: [PATCH] slub: reduce total stack usage of slab_err & object_err
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <48E2480A.9090003@linux-foundation.org>
References: <1222787736.2995.24.camel@castor.localdomain>
	 <48E2480A.9090003@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 10:49:45 -0500
Message-Id: <1222789785.23159.27.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, penberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-30 at 10:38 -0500, Christoph Lameter wrote:
> Richard Kennedy wrote:
> > reduce the total stack usage of slab_err & object_err.
> > 
> > Introduce a new function to display a simple slab bug message, and call
> > this when vprintk is not needed.
> 
> You could simply get rid of the 100 byte buffer by using vprintk? Same method
> could be used elsewhere in the kernel and does not require additional
> functions. Compiles, untestted.

I'm fixing a bunch of these in the kernel right now.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
