Date: Wed, 8 May 2002 15:50:06 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020508225006.GN15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020508224255.GM15756@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>, Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2002 at 03:42:55PM -0700, William Lee Irwin III wrote:
> It makes only 3 assumptions:
> (1) memory is contiguous
> (2) memory starts from 0
> (3) mem_map is in 1:1 order-preserving correspondence with phys pages

(4) memory is direct-mapped.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
