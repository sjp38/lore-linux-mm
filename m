Date: Mon, 25 Feb 2002 18:54:12 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] struct page shrinkage
Message-ID: <20020226025412.GP3511@holomorphy.com>
References: <20020225.174911.82037594.davem@redhat.com> <Pine.LNX.4.33L.0202252254380.7820-100000@imladris.surriel.com> <20020225.180122.120462472.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020225.180122.120462472.davem@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, marcelo@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2002 at 06:01:22PM -0800, David S. Miller wrote:
> Rik, not every architecture has a "counter" member of
> atomic_t, that is the problem.  This is a hard bug, please
> fix it.  It is an opaque type, accessing its' implementation
> directly is therefore illegal in the strongest way possible.

> From: Rik van Riel <riel@conectiva.com.br>
> This exact same code has been in -rmap for a few months
> and went into 2.5 just over a week ago.  It doesn't seem
> to give any problems ...

On Mon, Feb 25, 2002 at 06:01:22PM -0800, David S. Miller wrote:
> Because I haven't pushed my sparc64 changesets yet, I'm doing
> that tonight.

I think I'm to blame for init_page_count(). My bad.

A small bit of analysis seemed to reveal that atomicity wasn't needed
in free_area_init_core(). Apparently the solution I suggested here was
non-portable. Perhaps a better way will crop up later.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
