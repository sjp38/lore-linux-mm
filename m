Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
Date: Fri, 23 Mar 2001 22:35:21 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.31.0103231424230.766-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 23, 2001 02:27:12 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14ga9U-0005aa-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>

> If you don't want to sleep, you need to use one of the wrappers for
> "__find_page_nolock()". Something like "find_get_page()", which only
> "gets" the page.

 * a rather lightweight function, finding and getting a reference to a
 * hashed page atomically, waiting for it if it's locked.

__find_get_page has I think a misleading comment ?

> The naming actually does make sense in this area.

Yep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
