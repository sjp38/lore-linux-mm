Date: Wed, 23 Jan 2002 17:20:35 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] rmap VM, version 12
In-Reply-To: <OFD53A5C76.36FD7F7A-ON88256B4A.0069B25C@boulder.ibm.com>
Message-ID: <Pine.LNX.4.33L.0201231718080.32617-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <badari@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2002, Badari Pulavarty wrote:

> I just tried to boot 2.4.17+rmap12 turning off HIGHMEM and it booted
> just fine. So it has to do with some HIGHMEM change happend between
> rmap11c and rmap12.
>
> Does this help ?

Yes.  Time for a very very big DOH, the kind of
DOH that would make Homer Simpson blush ...

I think you're seeing a divide by zero on line
947 of page_alloc.c ... which also explains why
the highmem emulation patch wasn't a big success
here. ;)

I'll release an rmap-12a within the hour.

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
