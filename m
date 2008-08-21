Date: Thu, 21 Aug 2008 00:13:22 -0700 (PDT)
Message-Id: <20080821.001322.236658980.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080820234615.258a9c04.akpm@linux-foundation.org>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080820234615.258a9c04.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 20 Aug 2008 23:46:15 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> On Wed, 20 Aug 2008 20:08:13 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > +	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
> 
> sparc64 allmodconfig:
> 
> mm/quicklist.c: In function `max_pages':
> mm/quicklist.c:44: error: invalid lvalue in unary `&'
> 
> we seem to have a made a spectacular mess of cpumasks lately.

It should explode similarly on x86, since it also defines node_to_cpumask()
as an inline function.

IA64 seems to be one of the few platforms to define this as a macro
evaluating to the node-to-cpumask array entry, so it's clear what
platform Motohiro-san did build testing on :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
