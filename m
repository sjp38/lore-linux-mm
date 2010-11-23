Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 93C086B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:35:36 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAN8afgs011312
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:36:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAN8ZYPw403454
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:35:34 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAN8ZYKm028757
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:35:34 -0500
Subject: Re: Free memory never fully used, swapping
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101122154419.ee0e09d2.akpm@linux-foundation.org>
References: <20101115195246.GB17387@hostway.ca>
	 <20101122154419.ee0e09d2.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 23 Nov 2010 00:35:31 -0800
Message-ID: <1290501331.2390.7023.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-22 at 15:44 -0800, Andrew Morton wrote:
> > These are all x86_64, and so there is no highmem garbage going on. 
> > The only zones would be for DMA, right?

There shouldn't be any highmem-related action going on.

> Is the combination of memory fragmentation and large-order allocations
> the only thing that would be causing this reclaim here?

It does sound somewhat suspicious.  Are you using hugetlbfs or
allocating large pages?  What are your high-order allocations going to?

> Is there some easy bake knob for finding what
>  is causing the free memory jumps each time this happens? 

I wish.  :)  The best thing to do is to watch stuff like /proc/vmstat
along with its friends like /proc/{buddy,meminfo,slabinfo}.  Could you
post some samples of those with some indication of where the bad
behavior was seen?

I've definitely seen swapping in the face of lots of free memory, but
only in cases where I was being a bit unfair about the numbers of
hugetlbfs pages I was trying to reserve.

-- Dave
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
