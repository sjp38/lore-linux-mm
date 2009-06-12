Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 591A96B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:44:02 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:45:21 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
In-Reply-To: <1244799389.7172.110.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0906121244020.30911@melkki.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
 <20090612091002.GA32052@elte.hu> <1244798515.7172.99.camel@pasglop>
 <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
 <1244799389.7172.110.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009, Benjamin Herrenschmidt wrote:
> Take a break, take a step back, and look at the big picture. Do you
> really want to find all the needles in the haystack or just make sure
> you wear gloves when handling the hay ? :-)

Well, I would like to find the needles but I think we should do it with 
gloves on.

If everyone is happy with this version of Ben's patch, I'm going to just 
apply it and push it to Linus.

			Pekka
