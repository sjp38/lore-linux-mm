Subject: Re: removing mm->rss and mm->anon_rss from kernel?
From: Magnus Damm <damm@opensource.se>
In-Reply-To: <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>
	 <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com>
	 <418AD329.3000609@yahoo.com.au>
	 <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com>
	 <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au>
	 <1099622957.29587.101.camel@gaston><418C55A7.9030100@yahoo.com.au>
	 <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
	 <204290000.1099754257@[10.10.2.4]>
	 <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
	 <226170000.1099843883@[10.10.2.4]>
	 <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
Content-Type: text/plain
Message-Id: <1100087871.8656.59.camel@localhost>
Mime-Version: 1.0
Date: Wed, 10 Nov 2004 12:57:51 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2004-11-08 at 17:04, Christoph Lameter wrote:
> On Sun, 7 Nov 2004, Martin J. Bligh wrote:
> 
> > Doing ps or top is not unusual at all, and the sysadmins should be able
> > to monitor their system in a reasonable way without crippling it, or even
> > effecting it significantly.
> 
> Hmm.. What would you think about a pointer to a stats structure in mm,
> which would only be allocated if stats are requested by /proc actions? The
> struct would contain a timestamp which would insure that the stats are
> only generated in certain intervals and not over and over again. This
> would also make it possible to force a regeneration of the numbers.

I assume you mean that the mm->rss and mm->rss_anon counters have been
replaced with stat calculation on demand. Maybe it is possible to keep a
needs_update-flag with each vma instead. Then only the vma:s with that
flag set needs to be recalculated. 

A nice feature would be to be able to assign each process/mm a stat
gathering mode - choose between no statistics, statistics updated every
N jiffy and real time statistics. Yeah, dream on.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
