Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 0512F6B0069
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 15:25:54 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so2680388eaa.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2012 12:25:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121205095221.GB2489@suse.de>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de>
	<1349801921-16598-6-git-send-email-mgorman@suse.de>
	<CA+ydwtqQ7iK_1E+7ctLxYe8JZY+SzMfuRagjyHJ12OYsxbMcaA@mail.gmail.com>
	<20121204141501.GA2797@suse.de>
	<alpine.LNX.2.00.1212042042130.13895@eggly.anvils>
	<alpine.LNX.2.00.1212042211340.892@eggly.anvils>
	<alpine.LNX.2.00.1212042320050.19453@eggly.anvils>
	<20121205095221.GB2489@suse.de>
Date: Wed, 5 Dec 2012 22:25:53 +0200
Message-ID: <CA+ydwtoduPVnkzL4cgRdaNjhTYa1HV2KUi6CjXsap_qOuu_SQQ@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix shared mempolicy leak
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

2012/12/5 Mel Gorman <mgorman@suse.de>:
> On Tue, Dec 04, 2012 at 11:24:30PM -0800, Hugh Dickins wrote:
>> From: Mel Gorman <mgorman@suse.de>
>>
>> Commit 00442ad04a5e ("mempolicy: fix a memory corruption by refcount
>> imbalance in alloc_pages_vma()") changed get_vma_policy() to raise the
>> refcount on a shmem shared mempolicy; whereas shmem_alloc_page() went
>> on expecting alloc_page_vma() to drop the refcount it had acquired.
>> This deserves a rework: but for now fix the leak in shmem_alloc_page().
>
> Thanks Hugh for turning gibber into a patch!
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
>
> Tommi, just in case, can you confirm this fixes the problem for you please?

Confirmed! No more complaints from kmemleak.

Thanks,
Tommi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
