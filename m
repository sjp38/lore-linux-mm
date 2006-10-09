Date: Mon, 9 Oct 2006 10:12:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory page alloc minor cleanups
In-Reply-To: <20061009045051.2ad989b9.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0610091011480.27355@schroedinger.engr.sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
 <Pine.LNX.4.64.0610090407440.25336@schroedinger.engr.sgi.com>
 <20061009045051.2ad989b9.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2006, Paul Jackson wrote:

> That's odd.  The copy of Christoph's Ack that I got directly
> had the one line body:
> 
>   Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> but the copy that I got via the linux-mm email list just
> had the standard linux-mm email list footer in its
> body, and not the above Acked line from Christoph.
> 
> Something in the path this message took through linux-mm
> stripped off Christoph's Acked-by line.

Yes we had this before. One needs to add some text or a blank line so that 
linux-mm does not eat it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
