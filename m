Date: Fri, 26 Jan 2007 09:25:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/8] Create the ZONE_MOVABLE zone
In-Reply-To: <Pine.LNX.4.64.0701261721340.23091@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0701260924500.7301@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234538.28809.24662.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260915390.7209@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261721340.23091@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Mel Gorman wrote:

> Other than adding some TEXT_FOR_MOVABLE, an addition to TEXTS_FOR_ZONES() and
> similar updates for FOR_ALL_ZONES(), what code in there uses special awareness
> of the zone?

Look for special handling of ZONE_DMA32 and you will find what you are 
looking for. In particular ZONE_MOVABLE needs to be considered for 
node_page_state calculations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
