Date: Thu, 24 Jan 2002 04:46:57 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH *] rmap VM, version 12
Message-ID: <20020124044657.E20533@athlon.random>
References: <20020123.104438.71552152.davem@redhat.com> <Pine.LNX.4.33L.0201231650450.32617-100000@imladris.surriel.com> <20020123.110624.93021436.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020123.110624.93021436.davem@redhat.com>; from davem@redhat.com on Wed, Jan 23, 2002 at 11:06:24AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2002 at 11:06:24AM -0800, David S. Miller wrote:
>    On Wed, 23 Jan 2002, David S. Miller wrote:
>    
>    > The problem is that when vmalloc() or whatever kernel mappings change
>    > you have to update all the quicklist page tables to match.
>    
>    Actually, this is just using the pte_free_fast() and
>    {get,free}_pgd_fast() functions on non-pae machines.
>    
> Rofl, you can't just do that.  The page tables cache caches the kernel
> mappings and if you don't update them properly on SMP you die.

the cache we're talking about here cannot cache anything, whatever is in
this cache must contain no information at all, otherwise the kernel
would crash anyway immediatly. Such code was disabled for no good reason
and there was nothing to fix there.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
