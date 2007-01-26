Date: Fri, 26 Jan 2007 08:33:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
In-Reply-To: <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Unmovable allocations in the movable zone. Yuck. Why dont you abandon the 
whole concept of statically sized movable zone and go back to the nice 
earlier idea of dynamically assigning MAX_ORDER chunks to be movable or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
