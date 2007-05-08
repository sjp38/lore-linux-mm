Date: Tue, 8 May 2007 11:05:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change zonelist order v5 [1/3] implements zonelist order
 selection
In-Reply-To: <1178645622.5203.53.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705081104180.9941@schroedinger.engr.sgi.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
 <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
 <1178643985.5203.27.camel@localhost>  <Pine.LNX.4.64.0705081021340.9446@schroedinger.engr.sgi.com>
 <1178645622.5203.53.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2007, Lee Schermerhorn wrote:

> > So far testing is IA64 only?
> Yes, so far.  I will test on an Opteron platform this pm.  
> Assume that no news is good news.

A better assumption: no news -> no testing. You probably need a 
configuration with a couple of nodes. Maybesomething less symmetric than 
Kame? I.e. have 4GB nodes and then DMA32 takes out a sizeable chunk of it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
