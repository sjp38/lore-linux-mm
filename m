Message-ID: <40226AD2.10408@cyberone.com.au>
Date: Fri, 06 Feb 2004 03:09:54 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm improvements
References: <16416.64425.172529.550105@laputa.namesys.com>	<Pine.LNX.4.44.0402041459420.3574-100000@localhost.localdomain>	<16417.3444.377405.923166@laputa.namesys.com>	<4021A6BA.5000808@cyberone.com.au>	<16418.19751.234876.491644@laputa.namesys.com>	<40225D1F.8090103@cyberone.com.au>	<40225E0B.70200@cyberone.com.au>	<16418.24401.323448.472921@laputa.namesys.com>	<40226267.3080703@cyberone.com.au>	<16418.25964.158500.724463@laputa.namesys.com>	<40226793.3000306@cyberone.com.au> <16418.26985.77248.358318@laputa.namesys.com>
In-Reply-To: <16418.26985.77248.358318@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Nick Piggin writes:
> > 
>
>[...]
>
> > 
> > That wasn't my immediate problem, but rather than an 'if'.
> > 
> > The main thing I'm worried about is you seem to be not
> > handling the error case correctly.
>
>Take a look at the for-loops conditions.
>
>

Bah, sorry for the noise. I prefer my version and removing
the conditions from the for loops, but doesn't matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
