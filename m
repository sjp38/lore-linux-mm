Date: Sat, 7 Apr 2001 21:39:36 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: (struct page *)->list
In-Reply-To: <OFF7EEC8B0.74CE8D02-ON85256A27.0079C289@pok.ibm.com>
Message-ID: <Pine.LNX.3.96.1010407213805.29335A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 7 Apr 2001, Bulent Abali wrote:

> The question is if I unhook the page->list field after
> page=alloc_page() and add page->list to my private linked list
> will that cause a problem elsewhere in the kernel?

This isn't portable between 2.2 and 2.4.  Treating struct page as an
opaque type is the recommended strategy.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
