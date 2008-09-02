Date: Tue, 2 Sep 2008 19:02:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BD0641.4040705@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<200809011656.45190.nickpiggin@yahoo.com.au>
	<20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809011743.42658.nickpiggin@yahoo.com.au>
	<48BD0641.4040705@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 02 Sep 2008 14:54:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Nick Piggin wrote:
> > That could be a reasonable solution.  Balbir has other concerns about
> > this... so I think it is OK to try the radix tree approach first.
> 
> Thanks, Nick!
> 
> Kamezawa-San, I would like to integrate the radix tree patches after review and
> some more testing then integrate your patchset on top of it. Do you have any
> objections/concerns with the suggested approach?
> 
please show performance number first.

Thanks,
-kame


> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
