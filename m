Date: Tue, 7 May 2002 14:21:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020507212123.GZ15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva> <E175Ary-0000Th-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <E175Ary-0000Th-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2002 at 09:43:29PM +0200, Daniel Phillips wrote:
> The most obvious place to start are the page table walking operations, of
> which there are a half-dozen instances or so.  Bill started to do some
> work on this, but that ran aground somehow.  I think you might run into
> the argument 'not broken yet, so don't fix yet'.  Still, it would be
> worth experimenting with strategies.
> Personally, I'd consider such work a diversion from the more important task
> of getting rmap implemented.

There are a couple of things I should probably say about my prior efforts.

The plan back then was to hide the pagetable structure from generic code
altogether and allow architecture-specific code to export a procedural
interface totally insulating the core from the structure of pagetables.
This was largely motivated by the notion that the optimal pagetable
structure could be chosen on a per-architecture basis. Linus himself
informed me that there was evidence to the contrary regarding
architecture-specific optimal pagetable structures, and so I abandoned
that effort given the evidence the scheme was pessimal.

I have no plans now to change the standardized structure or to export
a HAT from arch code. OTOH I've faced some recent reminders of what the
code looks like now and believe janitoring may well be in order.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
