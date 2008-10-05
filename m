From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 3/4] cpu alloc: The allocator
Date: Mon, 6 Oct 2008 07:10:43 +1000
References: <20080929193500.470295078@quilx.com> <20081003003342.4d592c1f.akpm@linux-foundation.org> <48E614A0.60209@linux-foundation.org>
In-Reply-To: <48E614A0.60209@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810060810.43511.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Friday 03 October 2008 22:48:32 Christoph Lameter wrote:
> Andrew Morton wrote:
> > But I'd have though that it would be possible to only allocate the
> > storage for online CPUs.  That would be a pretty significant win for
> > some system configurations?
>
> We  have tried that but currently the kernel (core and in particular arch
> code) keeps state for all possible cpus in percpu segments. Would require
> more extensive cleanup of numerous arches to do.

It shouldn't be a big win, since possible ~= online for most systems.  And 
having all the per-cpu users register online and offline cpu callbacks is 
error prone and a PITA.

Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
