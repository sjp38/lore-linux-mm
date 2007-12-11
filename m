Date: Tue, 11 Dec 2007 13:51:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6] Use two zonelists per node instead of multiple
 zonelists v11r2
Message-Id: <20071211135122.7a4a8dec.akpm@linux-foundation.org>
In-Reply-To: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
References: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Dec 2007 20:21:57 +0000 (GMT)
Mel Gorman <mel@csn.ul.ie> wrote:

> This is a rebase of the two-zonelist patchset to 2.6.24-rc4-mm1 and some
> warnings cleared up.

Sorry, but I don't think I'll be looking at anything which looks like it
isn't a bugfix for a while.

I'm swamped in regressions (and everyone else should be too) but also we
need to look at why there were so many regressions - people jamming way too
much inadequately tested stuff into the 2.6.24 merge window.  The only way
we can fix that is to merge less stuff and to more carefully review and
test the things which we _do_ plan on merging.

Part of that process is for me to get more -mm kernels out and to test them
more and to encourage more people to test them and to report and fix
problems.  But I've hardly looked at the -mm queue in a week because of
2.6.24 regressions.

argh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
