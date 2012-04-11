Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 03BA96B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:54:25 -0400 (EDT)
Received: by yenm8 with SMTP id m8so899700yen.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 11:54:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F85BE78.8040205@redhat.com>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
 <1334162298-18942-2-git-send-email-mgorman@suse.de> <4F85BE78.8040205@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Apr 2012 14:54:04 -0400
Message-ID: <CAHGf_=rm0m4XZn=BJ8uLnarq9MwSvFbQMW=5ueRzM8ezincKmA@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: vmscan: Remove lumpy reclaim
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 11, 2012 at 1:25 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/11/2012 12:38 PM, Mel Gorman wrote:
>>
>> Lumpy reclaim had a purpose but in the mind of some, it was to kick
>> the system so hard it trashed. For others the purpose was to complicate
>> vmscan.c. Over time it was giving softer shoes and a nicer attitude but
>> memory compaction needs to step up and replace it so this patch sends
>> lumpy reclaim to the farm.
>>
>> The tracepoint format changes for isolating LRU pages with this patch
>> applied. Furthermore reclaim/compaction can no longer queue dirty pages in
>> pageout() if the underlying BDI is congested. Lumpy reclaim used this
>> logic
>> and reclaim/compaction was using it in error.
>>
>> Signed-off-by: Mel Gorman<mgorman@suse.de>
>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
