Received: from pincoya.inf.utfsm.cl (root@pincoya.inf.utfsm.cl [200.1.19.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA03568
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 16:30:39 -0400
Message-Id: <199904052024.QAA29035@pincoya.inf.utfsm.cl>
Subject: Re: [patch] arca-vm-2.2.5 
In-reply-to: Your message of "Mon, 05 Apr 1999 14:23:03 +0100."
             <Pine.SCO.3.94.990405122223.26431B-100000@tyne.london.sco.com>
Date: Mon, 05 Apr 1999 16:24:47 -0400
From: Horst von Brand <vonbrand@inf.utfsm.cl>
Sender: owner-linux-mm@kvack.org
To: Mark Hemment <markhe@sco.COM>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Hemment <markhe@sco.COM> said:

[...]

>   One worthwhile improvement to the page-hash is to reduce the need to
> re-check the hash after a blocking operation (ie. page allocation).
>   Changing the page-hash from an array of page ptrs to an array of;
> 	typedef struct page_hash_s {
> 		struct page	*ph_page;
> 		unsigned int	 ph_cookie;
> 	} page_hash_t;
> 
>   	page_hash_t page_hash[PAGE_HASH_TABLE];
> 
>   Whenever a new page is linked into a hash line, the ph_cookie for that
> line is incremented.

If you link new pages in at the start (would make sense, IMHO, since they
will probably be used soon) you can just use the pointer as cookie.
-- 
Dr. Horst H. von Brand                       mailto:vonbrand@inf.utfsm.cl
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
