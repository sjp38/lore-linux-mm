Date: Thu, 14 Feb 2008 11:07:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <84144f020802140057m5dcf479fjd71911ff573055f2@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0802141107310.32613@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com>  <20080214040314.118141086@sgi.com>
 <84144f020802140057m5dcf479fjd71911ff573055f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> Why does slub_min_order=9 matter? I suppose this is fixing some other
> real bug?

No its just making the behavior of slub running with huge pages better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
