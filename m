Message-ID: <3965A4E7.C6150BBA@augan.com>
Date: Fri, 07 Jul 2000 11:37:43 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: nice vmm test case
References: <39636E66.CE21C296@ucla.edu> <m2sntn1agu.fsf@boreas.southchinaseas>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

John Fremlin wrote:

> Perhaps, but I think the cause of the problem might well the priority
> argument to the swap_out function. For me, it is always set to around
> 62, so that the swap out loop is executed a ridiculous number of
> times, i.e. until all memory that can be is swapped out (which seems
> to be the behaviour described).

Hmm, for me it looks like that even in a single loop too much is done. A
single loop already tries to put as much as possible into the swap
cache. Two calls of swap_out_mm for the same mm in very short time and
most of the process is on swap and it will only be busy to get it pages
back.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
