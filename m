From: Jesse Barnes <jbarnes@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Date: Mon, 8 Nov 2004 04:43:12 -0800
References: <4189EC67.40601@yahoo.com.au> <226170000.1099843883@[10.10.2.4]> <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200411080443.13295.jbarnes@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday, November 07, 2004 10:25 am, Matthew Wilcox wrote:
> On Sun, Nov 07, 2004 at 08:11:24AM -0800, Martin J. Bligh wrote:
> > Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
> > getting rather silly ....
>
> NASA bought a 10k CPU system, but that's a cluster.  I think the largest
> single system within that cluster is 256 CPUs.

512 I believe.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
