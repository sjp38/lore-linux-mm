Date: Mon, 18 Jun 2001 09:35:46 -0400
From: Pete Wyckoff <pw@osc.edu>
Subject: Re: [docPATCH] mm.h documentation
Message-ID: <20010618093546.A9415@osc.edu>
References: <Pine.LNX.4.33.0106162309010.17512-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0106162309010.17512-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Sat, Jun 16, 2001 at 11:12:19PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

riel@conectiva.com.br said:
>  typedef struct page {
[..]
> +	unsigned long index;		/* Our offset within mapping. */

[..]
> + * A page may belong to an inode's memory mapping. In this case,
> + * page->mapping is the pointer to the inode, and page->offset is the
> + * file offset of the page (not necessarily a multiple of PAGE_SIZE).

Minor nit.

The field offset was renamed to index some time ago, but I can't
figure out if the usage changed.  Can you fix the comment and educate
us?

		-- Pete
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
