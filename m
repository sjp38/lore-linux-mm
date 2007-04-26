Date: Thu, 26 Apr 2007 09:06:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v3
In-Reply-To: <1177603203.5705.36.camel@localhost>
Message-ID: <Pine.LNX.4.64.0704260904190.1655@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
 <200704261147.44413.ak@suse.de>  <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
  <20070426195348.6a4e5652.kamezawa.hiroyu@jp.fujitsu.com>
 <1177603203.5705.36.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Hmmmm... One additional easy way to fix this would be to create a DMA 
node and place it very distant to other nodes. This would make it a 
precious system resource that is only used for

1. GFP_DMA allocations

2. If the memory on the other nodes is exhausted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
