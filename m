Date: Tue, 8 May 2007 18:07:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change zonelist order v5 [1/3] implements zonelist order
 selection
In-Reply-To: <20070508175855.b126caf7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705081806220.17207@schroedinger.engr.sgi.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
 <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
 <1178643985.5203.27.camel@localhost> <Pine.LNX.4.64.0705081021340.9446@schroedinger.engr.sgi.com>
 <1178645622.5203.53.camel@localhost> <Pine.LNX.4.64.0705081104180.9941@schroedinger.engr.sgi.com>
 <1178656627.5203.84.camel@localhost> <20070509092912.3140bb78.kamezawa.hiroyu@jp.fujitsu.com>
 <20070508175855.b126caf7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2007, Andrew Morton wrote:

> I'm still cowering in fear of these patches, btw.
> 
> Please keep testing and sending them ;)

I hope you finally get a feel for the evil nature of ZONE_DMAxx. I 
think our x86_64 platform will have node 0 cordoned off for DMA if any 
DMA32 or DMA devices are on the system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
