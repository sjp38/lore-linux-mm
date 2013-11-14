Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 79CC16B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 10:54:30 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fa1so2248408pad.30
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 07:54:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id tu7si28379405pab.162.2013.11.14.07.54.27
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 07:54:28 -0800 (PST)
Message-ID: <5284F201.4040607@redhat.com>
Date: Thu, 14 Nov 2013 10:53:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org> <CAA_GA1df0sbaBvTPjfPB0Pqyc=KtFq98Qsg=r7NPRn5z=Qsw2g@mail.gmail.com>
In-Reply-To: <CAA_GA1df0sbaBvTPjfPB0Pqyc=KtFq98Qsg=r7NPRn5z=Qsw2g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linux-Kernel <linux-kernel@vger.kernel.org>

On 11/12/2013 05:30 AM, Bob Liu wrote:
> Hi Johannes,
>
> On Fri, Oct 11, 2013 at 5:46 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>          Future
>>
>> Right now we have a fixed ratio (50:50) between inactive and active
>> list but we already have complaints about working sets exceeding half
>> of memory being pushed out of the cache by simple used-once streaming
>> in the background.  Ultimately, we want to adjust this ratio and allow
>> for a much smaller inactive list.  These patches are an essential step
>> in this direction because they decouple the VMs ability to detect
>> working set changes from the inactive list size.  This would allow us
>> to base the inactive list size on something more sensible, like the
>> combined readahead window size for example.
>>
>
> I found that this patchset have the similar purpose as
> Zcache(http://lwn.net/Articles/562254/) in some way.

Sorry, but that is unrelated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
