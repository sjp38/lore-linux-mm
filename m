Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D3E66B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:57:06 -0500 (EST)
Message-ID: <4B85AE8A.3080907@redhat.com>
Date: Wed, 24 Feb 2010 17:56:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 36/36] khugepaged
References: <20100221141009.581909647@redhat.com> <20100221141758.658303189@redhat.com> <20100224121111.232602ba.akpm@linux-foundation.org> <4B858BFC.8020801@redhat.com> <20100224125253.2edb4571.akpm@linux-foundation.org> <4B8592BB.1040007@redhat.com> <20100224131220.396216af.akpm@linux-foundation.org> <4B859900.6060504@redhat.com> <20100224225204.GG29956@random.random>
In-Reply-To: <20100224225204.GG29956@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/24/2010 05:52 PM, Andrea Arcangeli wrote:

> As sysctl that control defrag there is only one right now and it turns
> defrag on and off. We could make it more finegrined and have two
> files, one for the page faults in transparent_hugepage/defrag as
> always|madvise|never, and one yes|no in
> transparent_hugepage/khugepaged/defrag but that may be
> overdesign... I'm not sure really when and how to invoke memory
> compaction, so having that maximum amount of knobs really is only
> requires if we can't came up with an optimal design.

The knobs may be useful for testing what the best
default behaviour would be, as well as for workloads
with special needs (eg. HPC vs. workloads with many
short lived small processes).

On systems with many CPU cores, it would also be
fairly easy to do some background memory compaction
on an idle CPU core, so we have huge pages available
for when processes need them...

There are a lot of unknowns here still, so we probably
need to stay flexible for a while to come.

The only thing we do know is that the hugepages can
really speed up some workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
