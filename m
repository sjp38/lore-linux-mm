Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Brief introduction
Date: Wed, 29 Aug 2001 13:47:22 +0200
References: <Pine.LNX.4.32.0108291050010.1979-100000@skynet>
In-Reply-To: <Pine.LNX.4.32.0108291050010.1979-100000@skynet>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010829114040Z16069-32383+2222@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 29, 2001 11:55 am, Mel wrote:
> Hello Linux-MM,
> 
> As part of a larger project, I am to write a small paper describing how
> the Linux MM works, including the algorithms used and the O(whatever)
> running time each of them takes. This includes everything from the
> different ways of allocating memory, to swapping, to the individual
> optimisations such as use-once. I will be starting with kernel 2.4.9 but
> will do my best to keep up to date with the various patches that affect
> the memory manager and will be lurking here on the list.
> 
> This in it's very early days so it'll be some time before I actually have
> something to show, but if people have areas they would like to see
> concentrated on or suggestions on what the most important sections to
> highlight are, I would be glad to hear them.
> 
> As appaling as this may sound to some of you ;)

I am quite sure nobody will find this appalling.

> this is purely a
> documentation effort and I don't intend to submit patches yet except in
> the unlikely event I notice something blatently wrong. When I am finished,
> I hope to have something that will help people get a grip on how the MM
> functions that isn't just "read the source"

When you have something to look at you should consider contacting Tigran 
Aivazian <tigran@veritas.com> and offer up your work as a chapter for Linux 
Kernel 2.4 Internals, which currently lacks any treatment of the subject at 
all.  Not to mention getting the benefit of some of Tigran's customary 
attention to detail.

You might get some good ideas on style from Understanding the Linux Kernel.

I doesn't matter whether it's brief or long.  You will probably find it's 
hard to keep it brief once you get started.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
