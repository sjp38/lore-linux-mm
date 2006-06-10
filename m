Date: Fri, 9 Jun 2006 21:52:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: zoned VM stats: Add NR_ANON
In-Reply-To: <20060610133207.df05aa29.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0606092149220.4820@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
 <20060608230305.25121.97821.sendpatchset@schroedinger.engr.sgi.com>
 <20060608210056.9b2f3f13.akpm@osdl.org> <Pine.LNX.4.64.0606091152490.916@schroedinger.engr.sgi.com>
 <20060610133207.df05aa29.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, hugh@veritas.com, npiggin@suse.de, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Sat, 10 Jun 2006, KAMEZAWA Hiroyuki wrote:

> Can this accounting catch  page migration ?  TBD ?
> Now all coutners are counted per zone, migration should be cared.

Page migration removes the reverse mapping for the old page and installs 
the mappings to the new page later. This means that the counters are taken 
care of.

try_to_unmap_one removes the mapping and decrements the zone counter.

remove_migration_pte adds the mapping to the new page and increments the 
relevant zone counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
