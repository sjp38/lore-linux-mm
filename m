From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911042208.OAA63453@google.engr.sgi.com>
Subject: Re: The 4GB memory thing
Date: Thu, 4 Nov 1999 14:08:34 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.9911042349510.8880-100000@chiara.csoma.elte.hu> from "Ingo Molnar" at Nov 4, 99 11:50:59 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: nconway.list@ukaea.org.uk, linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 4 Nov 1999, Kanoj Sarcar wrote:
> 
> > assuming its very similar to 2.3 ... where brw_kiovec() refuses to 
> > accept PageHighMem pages. [...]
> 
> (btw, i have removed this limitation already in my tree, now that
> ll_rw_block() accepts highmem pages as well.)
> 
> -- mingo
> 

Ohh! Are you talking about ll_rw_block() in your tree, or in 2.3.25?
If in 2.3.25, where was the bouncing added?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
