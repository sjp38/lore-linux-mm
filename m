Date: Fri, 9 Jun 2006 08:55:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 06/14] Add per zone counters to zone node and global VM
 statistics
In-Reply-To: <20060608210101.155e8d4f.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606090855050.31570@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
 <20060608230310.25121.77780.sendpatchset@schroedinger.engr.sgi.com>
 <20060608210101.155e8d4f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2006, Andrew Morton wrote:

> > +char *vm_stat_item_descr[NR_STAT_ITEMS] = { "mapped","pagecache" };
> 
> static?

It is accessed from driver/base/node.c.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
