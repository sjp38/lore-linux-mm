Date: Fri, 23 Mar 2001 14:37:21 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
In-Reply-To: <E14ga9U-0005aa-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.31.0103231435000.766-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>


On Fri, 23 Mar 2001, Alan Cox wrote:
>
> __find_get_page has I think a misleading comment ?

Ehh..

I only said the _naming_ makes sense. [ Wild hand-waving ]

I suspect that what happened was that we split off the functions (one to
just get the page, one to lock it), and the comment that was associated
with the original "find_page()" never got removed, and just happens to sit
above one of the helper functions now - the one that didn't lock.

I'll fix the comment.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
