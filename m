Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Tue, 28 Aug 2001 02:08:05 +0200
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010828000128Z16263-32386+166@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 28, 2001 12:28 am, Marcelo Tosatti wrote:
> On Tue, 28 Aug 2001, Daniel Phillips wrote:
> > On August 27, 2001 10:14 pm, Andrew Kay wrote:
> > > I am having some rather serious problems with the memory management (i 
> > > think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots 
> > > of these errors in /var/log/messages.
> Its probably the bounce buffering thingie.
> 
> I'll send a patch to Linus soon.

That's what I thought too, but I thought, why not give him the patch and be 
sure.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
