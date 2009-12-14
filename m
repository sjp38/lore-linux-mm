Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 809566B003D
	for <linux-mm@kvack.org>; Sun, 13 Dec 2009 23:09:29 -0500 (EST)
Message-ID: <4B25BA6E.5010002@redhat.com>
Date: Sun, 13 Dec 2009 23:09:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com> <28c262360912131614h62d8e0f7qf6ea9ab882f446d4@mail.gmail.com>
In-Reply-To: <28c262360912131614h62d8e0f7qf6ea9ab882f446d4@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 12/13/2009 07:14 PM, Minchan Kim wrote:

> On Sat, Dec 12, 2009 at 6:46 AM, Rik van Riel<riel@redhat.com>  wrote:

>> If too many processes are active doing page reclaim in one zone,
>> simply go to sleep in shrink_zone().

> I am worried about one.
>
> Now, we can put too many processes reclaim_wait with NR_UNINTERRUBTIBLE state.
> If OOM happens, OOM will kill many innocent processes since
> uninterruptible task
> can't handle kill signal until the processes free from reclaim_wait list.
>
> I think reclaim_wait list staying time might be long if VM pressure is heavy.
> Is this a exaggeration?
>
> If it is serious problem, how about this?
>
> We add new PF_RECLAIM_BLOCK flag and don't pick the process
> in select_bad_process.

A simpler solution may be to use sleep_on_interruptible, and
simply have the process continue into shrink_zone() if it
gets a signal.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
