From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14951.58719.533776.944814@pizda.ninka.net>
Date: Thu, 18 Jan 2001 22:57:35 -0800 (PST)
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.31.0101181253540.31432-100000@localhost.localdomain>
References: <Pine.LNX.4.31.0101181253540.31432-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:
 > In order to find the vma and the mm_struct each pte belongs to,
 > we can use the ->mapping and ->index fields in the page_struct
 > of the page table, with the ->mapping pointing to the mm_struct
 > and the ->index containing the offset within the mm_struct

Anonymous pages have no page->mapping, how can this work?

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
