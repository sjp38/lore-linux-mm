Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 09E35474B5
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 14:34:01 -0200 (BRST)
Date: Tue, 22 Oct 2002 14:33:48 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
In-Reply-To: <3DB4855F.D5DA002E@digeo.com>
Message-ID: <Pine.LNX.4.44L.0210221428060.1648-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Oct 2002, Andrew Morton wrote:

> He had 3 million dentries and only 100k pages on the LRU,
> so we should have been reclaiming 60 dentries per scanned
> page.
>
> Conceivably the multiply in shrink_slab() overflowed, where
> we calculate local variable `delta'.  But doubtful.

What if there were no pages left to scan for shrink_caches ?

Could it be possible that for some strange reason the machine
ended up scanning 0 slab objects ?

60 * 0 is still 0, after all ;)

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
