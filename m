Date: Thu, 20 Apr 2000 22:54:35 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [rtf] [patch] 2.3.99-pre6-3 overly swappy
In-Reply-To: <ytt4s8wb8rd.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0004202247170.9178-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On 21 Apr 2000, Juan J. Quintela wrote:

>    I have tried to mix the two, yours and him, and no way, the system
>    begins working OK, but in some moments, the system begins to trash
>    (very heavily).  Indeed I boot the machine with mem=64MB (normally
>    with 256MB), the same precesses for testing and the machine dies
>    in the middle of the trashing (no keyboard, no mouse, no response)
>    and the disk sound very loud.

Ahh, I'd expect this to be the case.  We're both going after the same
problem, by tuning the aggressiveness of the different parts of the vm
code.  Note that the patch I posted earlier is completely broken on
machines that don't have the majority of their memory above 16MB, but it's
atleast giving us a hint about what direction we need to go in.

One of the things that really needs fixing is the allocator's way of
choosing which zone to pressure for memory: most allocators don't care if
it's dma/not memory but the call to try_to_free_pages specifies a zone --
which may be the wrong one. :(

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
