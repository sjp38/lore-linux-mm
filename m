Date: Thu, 11 May 2000 15:22:15 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005111519590.819-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 11 May 2000, Juan J. Quintela wrote:
> 
> Linus, I agree with you here, but we do a get_page 5 lines before, I
> think that if I do a get_page I should do a put_page to liberate it. 

No, "get_page()" really means "increment the usage count by one", and the
problem is that it is obviously completely neutral wrt the actual size of
the page.

What we _could_ do is to just for clarity have

	#define page_cache_get()	get_page()

and then pair up every "page_cache_get()" with "page_cache_release()".
Which makes sense to me. So if you feel strongly about this issue..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
