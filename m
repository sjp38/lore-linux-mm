Date: Mon, 25 Feb 2002 22:57:38 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] struct page shrinkage
In-Reply-To: <20020225.174911.82037594.davem@redhat.com>
Message-ID: <Pine.LNX.4.33L.0202252254380.7820-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: marcelo@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2002, David S. Miller wrote:

>    From: Rik van Riel <riel@conectiva.com.br>
>    Date: Mon, 25 Feb 2002 22:47:00 -0300 (BRT)
>
>    Please apply for 2.4.19-pre2.
>
> Please fix the atomic_t assumptions in init_page_count() first.
> You should be using atomic_set(...).

Why ?   You'll see init_page_count() is _only_ used from
free_area_init_core(), when nothing else is using the VM
yet.

This exact same code has been in -rmap for a few months
and went into 2.5 just over a week ago.  It doesn't seem
to give any problems ...

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
