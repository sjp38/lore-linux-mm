Date: Sat, 6 Nov 2004 13:31:06 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041106213106.GH2890@holomorphy.com>
References: <16781.12572.181444.967905@wombat.chubb.wattle.id.au> <Pine.LNX.4.44.0411061553120.21150-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0411061553120.21150-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Chubb <peter@chubb.wattle.id.au>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Nov 2004, Peter Chubb wrote:
>> Is this going to scale properly to large machines, which usually have
>> large numbers of active processes?  top is already
>> almost unuseably slow on such machines; if all the pagetables have to
>> be scanned to get RSS, it'll probably slow to a halt.

On Sat, Nov 06, 2004 at 03:54:17PM -0500, Rik van Riel wrote:
> Not probably.  Certainly.
> Christopher would do well to actually use his patch, while
> running eg. an Oracle benchmark and using top to monitor
> system activity.

OAST with a few thousand clients should do it. I think it tops out
around 5000 or 1000 without benchmark source adjustments. The database
itself, of course, has no trouble with many clients, the workload
simulator was merely not intended for so many.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
