Date: Thu, 14 Sep 2000 20:43:25 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Running out of memory in 1 easy step
Message-ID: <20000914204325.A6015@fred.muc.de>
References: <20000914145904.B18741@liacs.nl> <20000914175633.A7675@fred.muc.de> <20000914180825.B19822@liacs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000914180825.B19822@liacs.nl>; from wichert@soil.nl on Thu, Sep 14, 2000 at 06:08:28PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wichert Akkerman <wichert@soil.nl>
Cc: Andi Kleen <ak@muc.de>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Thu, Sep 14, 2000 at 06:08:28PM +0200, Wichert Akkerman wrote:
> Previously Andi Kleen wrote:
> > There is a hardwired limit of 1024 vmas/process. This is to avoid denial
> > of service attacks with attackers using up all memory with vmas.
> 
> That's trivial to circumvent using multiple processes or even threads which
> makes it a useless and possibly damaging protection imho..

The limit is actually 65536 I misremembered it. 
The main purpose is probably to avoid the counter wrapping. 
When get_unmapped_area failed you likely just ran out of virtual address space.


-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
