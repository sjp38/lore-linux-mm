Message-ID: <38986CC0.EA285023@colorfullife.com>
Date: Wed, 02 Feb 2000 18:43:28 +0100
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: 2.3.42: Strange memory corruption
References: <Pine.LNX.4.10.10002021439170.462-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Patrick Mau <patrick@oscar.prima.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> This looks a bit like there might be a race with the
> pagetable mapping or read()ing of the file. It would
> explain the three `suspicious' segfaults I've seen in
> the last few days...
> 

The TLB flush code contains various races if IPI's are sent between
switch_mm() and switch_to(). I and Ingo have written patches that fix
these problems, and we are waiting for Linus' reply.

I've posted my patch and a longer description to linux-kernel last
Friday "[PATCH] new tlb flush code".

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
