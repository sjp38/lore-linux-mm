Date: Thu, 14 Sep 2000 17:56:33 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Running out of memory in 1 easy step
Message-ID: <20000914175633.A7675@fred.muc.de>
References: <20000914145904.B18741@liacs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000914145904.B18741@liacs.nl>; from wichert@soil.nl on Thu, Sep 14, 2000 at 03:00:20PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wichert Akkerman <wichert@soil.nl>
Cc: linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Thu, Sep 14, 2000 at 03:00:20PM +0200, Wichert Akkerman wrote:
> 
> I have a small test program that consistently can't allocate more
> memory using mmap after 458878 allocations, no matter how much memory
> I allocate per call (tried with 8, 80, 800 and 4000 bytes per call):
> mmap returns ENOMEM. The machine has plenty memory available (2Gb
> and no other processes are running except standard daemons) so there
> should be enough memory.

There is a hardwired limit of 1024 vmas/process. This is to avoid denial
of service attacks with attackers using up all memory with vmas.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
