Date: Tue, 9 Nov 2004 03:12:37 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041108161237.GB27808@krispykreme.ozlabs.ibm.com>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com> <226170000.1099843883@[10.10.2.4]> <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

 
> Nope. The future of computing seems to be very high numbers of cpus.
> NASAs Columbia has 10k cpus and the new BlueGen solution from IBM is
> already at 8k.

Bluegene isnt a fair comparison, its a cluster (and its much more than
8k cpus).

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
