Subject: Re: [RFC][DATA] re "ongoing vm suckage"
From: Michael Rothwell <rothwell@holly-springs.nc.us>
In-Reply-To: <Pine.LNX.4.33.0108040952460.1203-100000@penguin.transmeta.com>
References: <Pine.LNX.4.33.0108040952460.1203-100000@penguin.transmeta.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 05 Aug 2001 00:19:43 -0400
Message-Id: <996985193.982.7.camel@gromit>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Mike Black <mblack@csihq.com>, Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On 04 Aug 2001 10:08:56 -0700, Linus Torvalds wrote:
> 
> On Sat, 4 Aug 2001, Mike Black wrote:
> >
> > I'm testing 2.4.8-pre4 -- MUCH better interactivity behavior now.
> 
> Good.. However.. [...]  before we get too happy about the interactive thing, let's
> remember that sometimes interactivity comes at the expense of throughput,
> and maybe if we fix the throughput we'll be back where we started.

Could there be both interactive and throughput optimizations, and a way
to choose one or the other at run-time? Or even just at compile time? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
