Message-ID: <20010323171716.28420@colin.muc.de>
Date: Fri, 23 Mar 2001 17:17:16 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Adding just a pinch of icache/dcache pressure...
References: <20010323015358Z129164-406+3041@vger.kernel.org> <Pine.LNX.4.21.0103230403370.29682-100000@imladris.rielhome.conectiva> <20010323122815.A6428@win.tue.nl> <m1hf0k1qvi.fsf@frodo.biederman.org> <3ABB6833.183E9188@mandrakesoft.com> <20010323111056.A9332@cs.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20010323111056.A9332@cs.cmu.edu>; from Jan Harkes on Fri, Mar 23, 2001 at 05:10:56PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Harkes <jaharkes@cs.cmu.edu>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 23, 2001 at 05:10:56PM +0100, Jan Harkes wrote:
> btw. There definitely is a network receive buffer leak somewhere in
> either the 3c905C path or higher up in the network layers (2.4.0 or
> 2.4.1). The normal path does not leak anything.


What do you mean with "normal path" ? 

And are you sure it was a leak? TCP can buffer quite a bit of skbs, but it 
should be bounded based on the number of sockets. 


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
