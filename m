Date: Wed, 23 Jan 2002 17:36:35 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] rmap VM, version 12
In-Reply-To: <20020123.112837.112624842.davem@redhat.com>
Message-ID: <Pine.LNX.4.33L.0201231735540.32617-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2002, David S. Miller wrote:

>    If there is some specific magic I'm missing, could you
>    please point me to the code I'm overlooking ? ;)
>
> Look at what get_pgd_slow() in pgalloc.h does, this is the
> case where it isn't going to the cache and it is really allocating the
> memory.

> Hmmm... maybe the "we can fault on kernel mappings" thing takes
> care of this because kernel PMDs can only appear, not go away.

OK, so only the _pgd_ quicklist is questionable and the
_pte_ quicklist is fine ?

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
