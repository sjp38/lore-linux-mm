Date: Wed, 10 Jul 2002 19:28:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020711022820.GX25360@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au> <20020710222210.GU25360@holomorphy.com> <3D2CD3D3.B43E0E1F@zip.com.au> <20020711015102.GV25360@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020711015102.GV25360@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2002 at 06:51:02PM -0700, William Lee Irwin III wrote:
> I'm not entirely sure, but I do have ideas of what I think would
> exercise specific (sub)functions of the VM.

I thought of another:

(4) A group of memory dirtying processes dirties memory at a rate
	exceeding the I/O bandwidth of the system.

	The VM's goal is to do "thrash control" for dirty memory
	generation by basically picking a subset of the dirty
	memory generators fitting within its I/O budget, letting
	them run for a while, and then putting them all to sleep
	after that and moving on to a different subset of the
	dirty memory generators, and so alternating between them.

	The measurable criteria would be foremost the variance in dirtying
	rates of the processes over their lifetimes, and secondarily
	dirtying throughput. The pass/fail criteria would be the ability
	to recognize the situation and stay within the "I/O budget".

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
