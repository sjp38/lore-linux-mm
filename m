Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id A41C56B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:48:33 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so934645ghr.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 12:48:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F85BEE1.1050607@redhat.com>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
 <1334162298-18942-4-git-send-email-mgorman@suse.de> <4F85BEE1.1050607@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Apr 2012 15:48:11 -0400
Message-ID: <CAHGf_=r8vBCm7-W1_6K_crbo-9C4zXSxn_u-LqHjYAVLdXieGg@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: vmscan: Remove reclaim_mode_t
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 11, 2012 at 1:26 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/11/2012 12:38 PM, Mel Gorman wrote:
>>
>> There is little motiviation for reclaim_mode_t once RECLAIM_MODE_[A]SYNC
>> and lumpy reclaim have been removed. This patch gets rid of reclaim_mode_t
>> as well and improves the documentation about what reclaim/compaction is
>> and when it is triggered.
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
