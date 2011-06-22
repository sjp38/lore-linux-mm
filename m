Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 10A526B024E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:11:33 -0400 (EDT)
Message-ID: <4E015D5C.4010809@redhat.com>
Date: Wed, 22 Jun 2011 11:11:24 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by transparent_hugepage=0
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <20110621133053.GO20843@redhat.com>
In-Reply-To: <20110621133053.GO20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <rdunlap@xenotime.net>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 21:30, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 04:10:42PM +0800, Amerigo Wang wrote:
>> Introduce "transparent_hugepage=0" to totally disable THP.
>> "transparent_hugepage=never" means setting THP to be partially
>> disabled, we need a new way to totally disable it.
>>
>
> I think I already clarified this is not worth it. Removing sysfs
> registration is just pointless. If you really want to save ~8k of RAM,
> at most you can try to move the init of the khugepaged slots hash and
> the kmem_cache_init to the khugepaged deamon start but even that isn't
> so useful. Not registering into sysfs is just pointless and it's a
> gratuitous loss of a feature.

Sorry, I replied to you in the other thread, so I don't want to dup
it here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
