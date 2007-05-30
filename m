Date: Wed, 30 May 2007 13:10:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/7] KAMEZAWA Hiroyuki - migration by kernel
In-Reply-To: <Pine.LNX.4.64.0705301304200.2671@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705301309530.2712@schroedinger.engr.sgi.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
 <20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
 <20070530114243.e3c3c75e.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0705302021040.7044@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705301304200.2671@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Christoph Lameter wrote:

> What guarantees that the old vma is not gone by then?

We would need to add the vma on the stack to the anon vma list .... Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
