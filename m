Date: Mon, 8 Nov 2004 08:07:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <20041108152621.GB2456@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0411080807080.7996@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
 <226170000.1099843883@[10.10.2.4]> <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
 <20041108152621.GB2456@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Nov 2004, Andi Kleen wrote:

> > NASA bought a 10k CPU system, but that's a cluster.  I think the largest
> > single system within that cluster is 256 CPUs.
>
> 512 CPUs AFAIK.

We surely would want to go much higher on that....
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
