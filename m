Date: Fri, 23 Jun 2000 19:41:26 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
In-Reply-To: <20000622215129.D28360@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0006231937540.824-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Jamie Lokier wrote:

>Does ____cacheline_aligned_in_smp guarantee the _size_ of the object is
>aligned, or merely its address?

Only its address. It uses the attribute aligned of gcc.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
