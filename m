Date: Tue, 2 May 2000 13:43:36 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <yttg0s13gjx.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005021342380.11153-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>


On 2 May 2000, Juan J. Quintela wrote:
> Hi
>         several people have reported Oops in __free_pages_ok, after a
> BUG() in page_alloc.h.  This happens in 2.3.99-pre[67].  The BUGs are:

I'd like ot know what the back-trace for those reports are? 

I'm not against getting rid of the PageSwapEntry logic (it's complication
for not very much gain), but I'd like to understand this more..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
