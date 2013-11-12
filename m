Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 55B9A6B00EF
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 05:30:53 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id un15so6718994pbc.5
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 02:30:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.123])
        by mx.google.com with SMTP id je1si19061066pbb.30.2013.11.12.02.30.50
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 02:30:51 -0800 (PST)
Received: by mail-vc0-f173.google.com with SMTP id lh4so4079875vcb.18
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 02:30:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Date: Tue, 12 Nov 2013 18:30:49 +0800
Message-ID: <CAA_GA1df0sbaBvTPjfPB0Pqyc=KtFq98Qsg=r7NPRn5z=Qsw2g@mail.gmail.com>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linux-Kernel <linux-kernel@vger.kernel.org>

Hi Johannes,

On Fri, Oct 11, 2013 at 5:46 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>         Future
>
> Right now we have a fixed ratio (50:50) between inactive and active
> list but we already have complaints about working sets exceeding half
> of memory being pushed out of the cache by simple used-once streaming
> in the background.  Ultimately, we want to adjust this ratio and allow
> for a much smaller inactive list.  These patches are an essential step
> in this direction because they decouple the VMs ability to detect
> working set changes from the inactive list size.  This would allow us
> to base the inactive list size on something more sensible, like the
> combined readahead window size for example.
>

I found that this patchset have the similar purpose as
Zcache(http://lwn.net/Articles/562254/) in some way.

Zcache uses the cleancache API to compress clean file pages so as to
keep them in memory, and only pages which used to in active file pages
are considered. Through Zcache we can hold more active pages in memory
and won't be effected by streaming workload.

Perhaps you can take a look at the way of zcache, your workloads are
very likely to benefit from it.
And zcache don't need so many changes to core VM/VFS subsystem because
it's based on cleancache API. I think it's more acceptable.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
