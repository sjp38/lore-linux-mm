Date: Thu, 24 Jan 2002 04:50:55 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH *] rmap VM, version 12
Message-ID: <20020124045055.F20533@athlon.random>
References: <20020123.112837.112624842.davem@redhat.com> <Pine.LNX.4.33L.0201231735540.32617-100000@imladris.surriel.com> <20020123.121857.18310310.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020123.121857.18310310.davem@redhat.com>; from davem@redhat.com on Wed, Jan 23, 2002 at 12:18:57PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2002 at 12:18:57PM -0800, David S. Miller wrote:
>    
>    OK, so only the _pgd_ quicklist is questionable and the
>    _pte_ quicklist is fine ?
> 
> That is my understanding.

pgd cache is fine too, the page fault will update the pgd using
swapper_pg_dir accordingly if needed. The swapper_pg_dir will only fault
in new pmd, it will never deallocate them (vfree only invalidates the
pte and free the pages), so it's safe. If vfree would deallocate them
just a simple context switch would break, no matter of the pgd cache.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
