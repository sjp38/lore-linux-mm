Date: Thu, 26 Apr 2007 18:25:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
In-Reply-To: <20070427092736.d0626a30.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0704261824340.23914@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
 <200704261147.44413.ak@suse.de> <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0704260846590.1382@schroedinger.engr.sgi.com>
 <20070427092736.d0626a30.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2007, KAMEZAWA Hiroyuki wrote:

> > DMA memory.
> > 
> It seems a bit complicated. If we do so, following can occur,
> 
> Node1: cpu0,1,2,3
> Node0: cpu4,5,6,7

We were discussing a two node NUMA system. If you have more put it onto 
the last.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
