Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA18980
	for <linux-mm@kvack.org>; Sat, 1 Feb 2003 02:14:13 -0800 (PST)
Date: Sat, 1 Feb 2003 02:14:23 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030201021423.1c18397f.akpm@digeo.com>
In-Reply-To: <20030201100001.GC29981@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030131151858.6e9cc35e.akpm@digeo.com>
	<20030201095848.C789@nightmaster.csn.tu-chemnitz.de>
	<20030201013136.312a946d.akpm@digeo.com>
	<20030201100001.GC29981@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: ingo.oeser@informatik.tu-chemnitz.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> On Sat, Feb 01, 2003 at 01:31:36AM -0800, Andrew Morton wrote:
> > Well I'm thinking of renaming it to hugebugfs.  It should be settled down
> > shortly.
> 
> We've had a difference of opinion wrt. the proper mechanism for
> referring things to the head of their superpage. I guess in one
> sense I could be blamed for not following directions, but I _really_
> didn't want to go in the direction of killing ->lru for all time.

It's not killed - tons of stuff can be stuck at page[1].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
