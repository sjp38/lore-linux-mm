Subject: Re: [PATCH]Fix: Init page count for all pages during higher order allocs
References: <20020429202446.A2326@in.ibm.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 29 Apr 2002 11:40:21 -0600
In-Reply-To: <20020429202446.A2326@in.ibm.com>
Message-ID: <m1r8ky1jzu.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: suparna@in.ibm.com
Cc: linux-kernel@vger.kernel.org, marcelo@brutus.conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Suparna Bhattacharya <suparna@in.ibm.com> writes:

> The call to set_page_count(page, 1) in page_alloc.c appears to happen 
> only for the first page, for order 1 and higher allocations.
> This leaves the count for the rest of the pages in that block 
> uninitialised.

Actually it should be zero.

This is deliberate because high order pages should not be referenced by
their partial pages.  It might make sense to add a PG_large flag and
then in the immediately following struct page add a pointer to the next
page, so you can identify these pages by inspection.  Doing something
similar to the PG_skip flag.

Beyond that I get nervous, that people will treat it as endorsement of
doing a high order continuous allocation and then fragmenting the page.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
