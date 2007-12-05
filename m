Date: Wed, 5 Dec 2007 19:50:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: What can we do to get ready for memory controller merge in
 2.6.25
Message-Id: <20071205195020.c44b7a5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071130191114.866b5ce0.kamezawa.hiroyu@jp.fujitsu.com>
References: <474ED005.7060300@linux.vnet.ibm.com>
	<200711301311.48291.nickpiggin@yahoo.com.au>
	<474F7FDF.3000506@linux.vnet.ibm.com>
	<20071130191114.866b5ce0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Nov 2007 19:11:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'd like to post some patches below in the next week.
>   - throttling the number of callers of try_to_free_mem_cgroup_pages()
>   - background reclaim and high/low watermark.
>   - some cleanups.
> 
I'd like to hold off "big changes" until the end of 2.6.25 merge window
and to make current memory controller be tested by many people.

I'll maintain new feature patches in countainer mailing list for a while.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
