Date: Wed, 23 Jan 2002 17:05:13 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] rmap VM, version 12
In-Reply-To: <OFB07135FF.E6C5BE7E-ON88256B4A.0068CB3F@boulder.ibm.com>
Message-ID: <Pine.LNX.4.33L.0201231704430.32617-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <badari@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2002, Badari Pulavarty wrote:

> Does this explain why my SMP box does not boot with rmap12 ? It works fine
> with rmap11c.
>
> Machine: 4x  500MHz Pentium Pro with 3GB RAM
>
> When I tried to boot 2.4.17+rmap12, last message I see is
>
> uncompressing linux ...
> booting ..

At this point we're not even near using pagetables yet,
so I guess this is something else ...

(I'm not 100% sure, though)

kind regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
