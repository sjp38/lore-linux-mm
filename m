Message-ID: <48E614A0.60209@linux-foundation.org>
Date: Fri, 03 Oct 2008 07:48:32 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080929193500.470295078@quilx.com>	<20080929193516.278278446@quilx.com> <20081003003342.4d592c1f.akpm@linux-foundation.org>
In-Reply-To: <20081003003342.4d592c1f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> And bitmap_etc().  We have a pretty complete suite there.

ok will use bitops here.

 > Apart from that the interface, intent and implementation seem reasonable.
> 
> But I'd have though that it would be possible to only allocate the
> storage for online CPUs.  That would be a pretty significant win for
> some system configurations?

We  have tried that but currently the kernel (core and in particular arch
code) keeps state for all possible cpus in percpu segments. Would require more
extensive cleanup of numerous arches to do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
