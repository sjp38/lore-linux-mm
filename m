From: Andi Kleen <ak@suse.de>
Subject: Re: Use Zoned VM Counters for NUMA statistics V3
Date: Sun, 25 Jun 2006 17:24:23 +0200
References: <Pine.LNX.4.64.0606241650050.16114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606241650050.16114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606251724.23783.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Remove the special statistics for numa and replace them with
> zoned vm counters. This has the side effect that global sums of these 
> events now show up in /proc/vmstat.
> 
> Also take the opportunity to move the zone_statistics() function from
> page_alloc.c into vmstat.c.

Ok for me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
