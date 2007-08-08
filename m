Date: Wed, 8 Aug 2007 16:28:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/3] Use one zonelist that is filtered instead of multiple
 zonelists
In-Reply-To: <20070808211032.GB2441@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081627520.17224@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
 <20070808161545.32320.41940.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0708081041240.12652@schroedinger.engr.sgi.com>
 <20070808211032.GB2441@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Mel Gorman wrote:

> The zone_id is the one I'm really interested in. It looks like the most
> promising optimisation for avoiding zone_idx in the hotpath.

Certainly the highest priority. However, if the nodeid could be coded in 
then we may be able to also avoid the GFP_THISNODE zonelists and improve 
the speed of matching a zonelist to a node mask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
