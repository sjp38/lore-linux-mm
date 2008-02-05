Date: Tue, 5 Feb 2008 10:12:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
In-Reply-To: <1202225017.5332.1.camel@localhost>
Message-ID: <Pine.LNX.4.64.0802051011400.11705@schroedinger.engr.sgi.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20080202090914.GA27723@one.firstfloor.org>  <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
  <1202149243.5028.61.camel@localhost>  <20080205143149.GA4207@csn.ul.ie>
 <1202225017.5332.1.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Could we focus on the problem instead of discussion of new patches under 
development? Can we confirm that what Kosaki sees is a bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
