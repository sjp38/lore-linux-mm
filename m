Date: Fri, 23 Jun 2000 19:52:24 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-ID: <20000623195224.A30689@pcep-jamie.cern.ch>
References: <20000622215129.D28360@pcep-jamie.cern.ch> <Pine.LNX.4.21.0006231937540.824-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0006231937540.824-100000@inspiron.random>; from andrea@suse.de on Fri, Jun 23, 2000 at 07:41:26PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Thu, 22 Jun 2000, Jamie Lokier wrote:
> 
> >Does ____cacheline_aligned_in_smp guarantee the _size_ of the object is
> >aligned, or merely its address?
> 
> Only its address. It uses the attribute aligned of gcc.

Quite.  So __cacheline_aligned_in_smp is not sufficient to ensure the
array doesn't share cache lines with another variable.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
