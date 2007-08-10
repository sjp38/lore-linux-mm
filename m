Date: Fri, 10 Aug 2007 12:02:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <200708102013.49170.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <20070810104749.GA14300@skynet.ie> <Pine.LNX.4.64.0708101035020.12758@schroedinger.engr.sgi.com>
 <200708102013.49170.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007, Andi Kleen wrote:

> 
> > x86_64 does not support ZONE_HIGHMEM.
> 
> I also plan to eliminate ZONE_DMA soon (and replace all its users
> with a new allocator that sits outside the normal fallback lists) 

Hallelujah. You are my hero! x86_64 will switch off CONFIG_ZONE_DMA?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
