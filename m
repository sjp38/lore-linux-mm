Date: Thu, 13 Apr 2000 23:36:57 +0200
Message-Id: <200004132136.XAA01065@agnes.bagneux.maison>
From: JF Martinez <jfm2@club-internet.fr>
In-reply-to: <Pine.LNX.3.96.1000413172501.13371A-100000@kanga.kvack.org>
	(blah@kvack.org)
Subject: Re: A question about pages in stacks
References: <Pine.LNX.3.96.1000413172501.13371A-100000@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: blah@kvack.org
Cc: jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > Let's imagine that when looking for a pege the kerneml a page who has
> > been part of a stack frame but since then the stack has shrunk so it
> > is no longer in it.  Will the kernel save it to disk or will it
> > recognize it as a page who despite what the dirty bit could say  is
> > in fact free and does not need to be saved?
> 
> It will have to be flushed to swap.  Stack shrinkage must be explicitely
> performed, preferably using madvise.  To this end, they could use a hint
> from the kernel about the actual size of the stack (see the stack
> discussions that have come up over the past week or two). 
> 
> 		-ben
> 

Will I be flamed if I consider this as a weakness in Linux?  While the
hardware will notify the kernel only about increasings in the stack
segment the fact is a page who is in the stack segment but on the
wrong side of the bottom of the stack is in fact a free page a nd does
not need to be written to disk.  Unless that it is considered that
checking for these "false dirty" pages is so slow that it will absorb
the benefits got from the reduced number of disk writings.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
