Subject: Re: [PATCH *] rmap VM, version 12
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.33L.0201231650450.32617-100000@imladris.surriel.com>
References: <Pine.LNX.4.33L.0201231650450.32617-100000@imladris.surriel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Jan 2002 14:15:04 -0500
Message-Id: <1011813305.28682.14.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-01-23 at 13:57, Rik van Riel wrote:

> Actually, this is just using the pte_free_fast() and
> {get,free}_pgd_fast() functions on non-pae machines.
> 
> I think this should be safe, unless there is a way
> we could pagefault from inside interrupts (but I don't
> think we do that).
> 
> OTOH, the -preempt people will want to add preemption
> protection from the fiddling with the local pte freelist ;)

If you are using the stock mechanisms in include/asm/pgalloc.h they are
already made preempt-safe by the patch. ;)

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
