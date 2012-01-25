Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id B061A6B005A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 20:47:15 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so149819wib.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 17:47:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALWz4iznfeLX1u00bWWf_ziThCrJNAJUQVBRu8Rv9yDsdMmKsQ@mail.gmail.com>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<CALWz4iyB0oSMBsfLJYD+xrB7ua9bRg5FD=cw4Sc-EdG1iLynow@mail.gmail.com>
	<CAJd=RBC+y3pVAsbCNP+mBm6Lfcx5XpTcg6D-us5J1E+W+_JcAQ@mail.gmail.com>
	<CALWz4iznfeLX1u00bWWf_ziThCrJNAJUQVBRu8Rv9yDsdMmKsQ@mail.gmail.com>
Date: Wed, 25 Jan 2012 09:47:13 +0800
Message-ID: <CAJd=RBCYsOSrJFjbBqqnU4=580Pd2sHQUhpxWfqx0rXJAxihuA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 25, 2012 at 7:22 AM, Ying Han <yinghan@google.com> wrote:
> On Mon, Jan 23, 2012 at 7:45 PM, Hillf Danton <dhillf@gmail.com> wrote:
>> With soft limit available, what if nr_to_reclaim set to be the number of
>> pages exceeding soft limit? With over reclaim abused, what are the targets
>> of soft limit?
>
> The nr_to_reclaim is set to SWAP_CLUSTER_MAX (32) for direct reclaim
> and ULONG_MAX for background reclaim. Not sure we can set it, but it
> is possible the res_counter_soft_limit_excess equal to that target
> value. The current soft limit mechanism provides a clue of WHERE to
> reclaim pages when there is memory pressure, it doesn't change the
> reclaim target as it was before.
>

Decrement in sc->nr_to_reclaim was tried in another patch, you already saw it.

> Overreclaim a cgroup under its softlimit is bad, but we should be
> careful not introducing side effect before providing the guarantee.

Yes 8-)

> Here, the should_continue_reclaim() has logic of freeing a bit more
> order-0 pages for compaction. The logic got changed after this.
>

Compaction is to increase the successful rate of THP allocation, and in turn
to back up higher performance. In soft limit, performance guarantee is not
extra request but treated with less care.

Which one you prefer, compaction or guarantee?

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
