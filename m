Date: Sat, 11 Feb 2006 13:27:17 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <20060211131324.63d49cff.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602111327001.24634@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
 <Pine.LNX.4.62.0602111054520.24060@schroedinger.engr.sgi.com>
 <20060211131324.63d49cff.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Feb 2006, Andrew Morton wrote:

> > Patch to fix the calling of page_referenced() follows. This is against 
> > 2.6.16-rc2. We probably need another patch for current mm. In the case
> > of VMSCAN_MAY_SWAP not set, we may just want to bypass the whole 
> > calculation thing for reclaim_mapped.
> > 
> 
> What's VMSCAN_MAY_SWAP?

Heh. Its gone!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
