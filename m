From: Russ Anderson <rja@sgi.com>
Message-Id: <200411081547.iA8FlH90124208@ben.americas.sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Date: Mon, 8 Nov 2004 09:47:17 -0600 (CST)
In-Reply-To: <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk> from "Matthew Wilcox" at Nov 07, 2004 06:25:54 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote:
> 
> On Sun, Nov 07, 2004 at 08:11:24AM -0800, Martin J. Bligh wrote:
> > Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
> > getting rather silly ....
> 
> NASA bought a 10k CPU system, but that's a cluster.  I think the largest
> single system within that cluster is 256 CPUs.

Each "node" is a single linux kernel with 512 processors..
There are 20 nodes in the cluster.  20 x 512p = 10,240 processors.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
