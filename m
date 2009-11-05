Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 267AD6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 13:51:30 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B0B2F82C314
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 13:58:12 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3rWtuq4sJlYZ for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 13:58:08 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4D44B70040D
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:27:57 -0500 (EST)
Date: Thu, 5 Nov 2009 10:20:18 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] lib: generic percpu counter array
In-Reply-To: <20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911051017310.25718@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1> <20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com> <20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Anothter major percpu coutner is vm_stat[]. This patch implements
> vm_stat[] style counter array in lib/percpu_counter.c
> This is designed for introducing vm_stat[] style counter to memcg,
> but maybe useful for other people. By using this, counter array
> using percpu can be implemented easily in compact structure.


Note that vm_stat support was written that way because we have extreme
space constraints due to the need to keep statistics per zone and per cpu
and avoid cache line pressure that would result through the use of big
integer arrays per zone and per cpu. For a large number of zones and cpus
this is desastrous.

If you only need to keep statistics per cpu for an entity then the vmstat
approach is overkill. A per cpu allocation of a counter is enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
