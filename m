Date: Fri, 5 Nov 1999 09:21:49 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: The 4GB memory thing
In-Reply-To: <199911042208.OAA63453@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9911050921320.959-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: nconway.list@ukaea.org.uk, linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 1999, Kanoj Sarcar wrote:

> > > assuming its very similar to 2.3 ... where brw_kiovec() refuses to 
> > > accept PageHighMem pages. [...]
> > 
> > (btw, i have removed this limitation already in my tree, now that
> > ll_rw_block() accepts highmem pages as well.)
> 
> Ohh! Are you talking about ll_rw_block() in your tree, or in 2.3.25?
> If in 2.3.25, where was the bouncing added?

my tree.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
