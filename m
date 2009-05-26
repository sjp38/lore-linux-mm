Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 459FC6B005C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:01:14 -0400 (EDT)
Date: Tue, 26 May 2009 14:01:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090526140110.c4a100fb.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.10.0905261653160.23631@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
	<20090524144056.0849.A69D9226@jp.fujitsu.com>
	<4A1A057A.3080203@oracle.com>
	<20090526032934.GC9188@linux-sh.org>
	<alpine.DEB.1.10.0905261022170.7242@gentwo.org>
	<20090526131540.70fd410a.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0905261653160.23631@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: lethal@linux-sh.org, randy.dunlap@oracle.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 16:54:58 -0400 (EDT)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 26 May 2009, Andrew Morton wrote:
> 
> > I still worry that there may be usage patterns which will result in
> > this message coming out many times.
> 
> Note that vm_swa_full is defined the following way
> 
> #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> 
> This means that vm_swap_full is true when more than 50% of swap are in
> use. The printed flag will therefore only be cleared if swap use falls to
> less than half.

(which was highly relevant changelog material)

OK.  But it that optimal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
