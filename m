Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2E6356B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:12:30 -0500 (EST)
Message-ID: <4B2B8DC6.7010506@redhat.com>
Date: Fri, 18 Dec 2009 09:12:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com> <4B2B85C3.5040409@redhat.com>
In-Reply-To: <4B2B85C3.5040409@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/18/2009 08:38 AM, Avi Kivity wrote:

>> + /* Number of processes running page reclaim code on this zone. */
>> + atomic_t concurrent_reclaimers;
>> + wait_queue_head_t reclaim_wait;
>> +
>
> Counting semaphore?

I don't see a safe way to adjust a counting semaphore
through /proc/sys.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
