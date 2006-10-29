Message-ID: <20061029155354.12118.qmail@web32405.mail.mud.yahoo.com>
Date: Sun, 29 Oct 2006 07:53:54 -0800 (PST)
From: Giridhar Pemmasani <pgiri@yahoo.com>
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
In-Reply-To: <4544C709.6070305@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

--- "Martin J. Bligh" <mbligh@google.com> wrote:

> Thanks for the patch ... but more worrying is how this got broken.
> Wasn't the point of having the -mm tree that patches like this went
> through it for testing, and we avoid breaking mainline? especially
> this late in the -rc cycle.

I don't know how it got into Linus's tree, but the breakage was due to my
earlier patch - sorry.

Giri


 
____________________________________________________________________________________
Get your email and see which of your friends are online - Right on the New Yahoo.com 
(http://www.yahoo.com/preview) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
