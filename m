Date: Mon, 8 Nov 2004 08:04:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <226170000.1099843883@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>
 <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com><418AD329.3000609@yahoo.com.au>
  <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com><418AE0F0.5050908@yahoo.com.au>
  <418AE9BB.1000602@yahoo.com.au><1099622957.29587.101.camel@gaston><418C55A7.9030100@yahoo.com.au>
 <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com><204290000.1099754257@[10.10.2.4]>
 <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
 <226170000.1099843883@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Nov 2004, Martin J. Bligh wrote:

> Doing ps or top is not unusual at all, and the sysadmins should be able
> to monitor their system in a reasonable way without crippling it, or even
> effecting it significantly.

Hmm.. What would you think about a pointer to a stats structure in mm,
which would only be allocated if stats are requested by /proc actions? The
struct would contain a timestamp which would insure that the stats are
only generated in certain intervals and not over and over again. This
would also make it possible to force a regeneration of the numbers.

Maybe lots of other statistical values in mm_struct could then also be
removed?

> Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
> getting rather silly ....

Nope. The future of computing seems to be very high numbers of cpus.
NASAs Columbia has 10k cpus and the new BlueGen solution from IBM is
already at 8k.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
