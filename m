Message-ID: <3C338DAC.EC325F3@earthlink.net>
Date: Wed, 02 Jan 2002 22:46:04 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Maximum physical memory on i386 platform
References: <20020102222026.69416.qmail@web12304.mail.yahoo.com> <3C33B37E.4050604@zytor.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ravi K <kravi26@yahoo.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"H. Peter Anvin" wrote:
> 
> Ravi K wrote:
> 
> > Hi,
> >   The configuration help for HIGHMEM feature on i386
> > platform states that 'Linux can use up to 64 Gigabytes
> > of physical memory on x86 systems'. I see a problem
> > with this:
> >  - page structures needed to support 64GB would take
> > up 1GB memory (64 bytes per page of size 4k)
> 
> 64GB is physical memory, not virtual memory.

And at approx. 64 bytes per strct page in mem_map, that's
1G worth of page structs, which is Ravi's point.

Cheers,

-- Joe
"I should like to close this book by sticking out any part of my neck
 which is not yet exposed, and making a few predictions about how the
 problem of quantum gravity will in the end be solved."
 --- Physicist Lee Smolin, "Three Roads to Quantum Gravity"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
