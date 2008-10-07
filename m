Message-ID: <48EB63D5.8090202@linux-foundation.org>
Date: Tue, 07 Oct 2008 08:27:49 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080929193500.470295078@quilx.com> <20081003003342.4d592c1f.akpm@linux-foundation.org> <48E614A0.60209@linux-foundation.org> <200810060810.43511.rusty@rustcorp.com.au>
In-Reply-To: <200810060810.43511.rusty@rustcorp.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Rusty Russell wrote:

> It shouldn't be a big win, since possible ~= online for most systems.  And 
> having all the per-cpu users register online and offline cpu callbacks is 
> error prone and a PITA.

That also has the nice consequence that moving the allocators (page allocator
/ slub) to the use of cpu_alloc will avoid the online and offline callbacks
(the main focus of these is getting rid of large pointer arrays there and
simplifying bootstrap etc).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
