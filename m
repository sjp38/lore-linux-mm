From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE masks
Date: Wed, 1 Aug 2007 13:07:43 +0200
References: <1185566878.5069.123.camel@localhost> <200708011233.02103.ak@suse.de> <20070801110120.GA9449@linux-sh.org>
In-Reply-To: <20070801110120.GA9449@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708011307.44189.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

> As long as interleaving is possible after boot, then yes. It's only the
> boot-time interleave that we would like to avoid,

But when anybody does interleaving later it could just as easily
fill up your small nodes, couldn't it?

Boot time allocations are small compared to what user space
later can allocate.

And do you really want them in the normal fallback lists? The normal zone
reservation heuristics probably won't work unless you put them into
special low zones.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
