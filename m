Date: Fri, 12 May 2000 00:22:29 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005120019030.9733-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 11 May 2000, Juan J. Quintela wrote:

> Linus, I agree with you here, but we do a get_page 5 lines before, I
> think that if I do a get_page I should do a put_page to liberate it. 

get_page() is different - it elevates the page count of a page of
_arbitrary order_. put_page() on the other hand does a __free_page()
[unconditional order 0]. This is a speciality of the Buddy allocator (you
can get a reference to a page through it's pointer without knowing the
order of the page, but you cannot free it without knowing the order), and
it's bad naming (i believe that particular naming is my fault).

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
