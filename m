Date: Mon, 25 Sep 2000 14:35:23 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000925143523.B19257@hq.fsmlabs.com>
References: <20000925140419.A18243@hq.fsmlabs.com> <E13den0-0005YM-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E13den0-0005YM-00@the-village.bc.nu>; from Alan Cox on Mon, Sep 25, 2000 at 09:23:48PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: yodaiken@fsmlabs.com, "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 09:23:48PM +0100, Alan Cox wrote:
> > my prediction is that if you show me an example of 
> > DoS vulnerability,  I can show you fix that does not require bean counting.
> > Am I wrong?
> 
> I think so. Page tables are a good example

I'm not too sure of what you have in mind, but if it is
     "process creates vast virtual space to generate many page table
      entries -- using mmap"
the answer is, virtual address space quotas and mmap should kill 
the process on low mem for page tables.

> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/

-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
