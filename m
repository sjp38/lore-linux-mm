Date: Fri, 15 Sep 2006 19:23:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060915183604.11a8d045.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609151922210.10550@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <20060915170455.f8b98784.pj@sgi.com> <20060915183604.11a8d045.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, Andrew Morton wrote:

> I doubt it - if we still hit z->zone_pgdat->node_id for all 40-odd zones,
> I expect the cost will be comparable.

This is the zone_to_nid() macro.

Could we add a node_id field to the zone? So zone_to_nid() becomes one 
lookup?

Note that zone_pgdat is out of the hot zone in the zone structure. Its 
therefore slow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
