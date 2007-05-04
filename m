Date: Fri, 4 May 2007 10:28:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order v4 [0/2]
In-Reply-To: <1178299460.5236.35.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705041027030.22643@schroedinger.engr.sgi.com>
References: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
 <20070503224730.3bc6f8a8.akpm@linux-foundation.org>
 <200705040826.23687.jbarnes@virtuousgeek.org>
 <Pine.LNX.4.64.0705040913340.21436@schroedinger.engr.sgi.com>
 <1178299460.5236.35.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Lee Schermerhorn wrote:

> Hmmm...  "serious hackery", indeed!  ;-)

Maybe on the arch level but minimal changes to core code.
And it is a step towards avoiding zones in NUMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
