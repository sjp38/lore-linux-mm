Date: Mon, 18 Jun 2001 11:24:43 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [docPATCH] mm.h documentation
In-Reply-To: <20010618093546.A9415@osc.edu>
Message-ID: <Pine.LNX.4.33.0106181123170.17350-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pete Wyckoff <pw@osc.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2001, Pete Wyckoff wrote:

> Minor nit.
>
> The field offset was renamed to index some time ago, but I can't
> figure out if the usage changed.  Can you fix the comment and educate
> us?

Offset was used to indicate the offset in bytes of the page in the object
page cache.  Index is the index of the page, ie in pages, not bytes.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
