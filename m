Date: Thu, 18 Mar 2004 23:04:32 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] RSS limit enforcement for 2.6
Message-ID: <20040318220432.GB1505@openzaurus.ucw.cz>
References: <Pine.LNX.4.44.0403151816350.12895-100000@chimarrao.boston.redhat.com> <405699C1.7010906@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <405699C1.7010906@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Hi!

> >Hugh Dickins found a bug in the 2.4-rmap RSS limit enforcing
> >code that may well explain why the previous port of the code
> >to 2.6 resulted in bad performance.  The split active lists
> >in 2.4-rmap probably masked the largest damages, but in 2.6
> >it was very much visible.
> >
> >
> 
> Hi Rik,
> What was the problem by the way?

When running lingvistics computation, machine got completely
unusable due to bad memory pressure. nice -n 19 was
useless. Memory limit should help.
-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
