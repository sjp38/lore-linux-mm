Date: Wed, 9 Jan 2008 09:50:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080109065015.GG7602@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
References: <20071225140519.ef8457ff.akpm@linux-foundation.org>
 <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
 <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
 <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
 <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Nishanth Aravamudan wrote:

> Do we (perhaps you already have done so, Christoph), want to validate
> any other users of numa_node_id() that then make assumptions about the
> characteristics of the nid? Hrm, that sounds good in theory, but seems
> hard in practice?

Hmmm... The main allocs are the slab allocations. If we fallback in 
kmalloc etc then we are fine for the common case. SLUB falls back 
correctly. Its just the weird nesting of functions in SLAB that has made 
this a bit difficult for that allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
