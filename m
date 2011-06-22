Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A1B6D6B024C
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:07:10 -0400 (EDT)
Message-ID: <4E015C36.2050005@redhat.com>
Date: Wed, 22 Jun 2011 11:06:30 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP configurable
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 09:23, David Rientjes a??e??:
> On Tue, 21 Jun 2011, Amerigo Wang wrote:
>
>> Don't hard-code 512M as the threshold in kernel, make it configruable,
>> and set 512M by default.
>>
>> And print info when THP is disabled automatically on small systems.
>>
>> V2: Add more description in help messages, correct some typos,
>> print the mini threshold too.
>>
>
> I like the printk that notifies users why THP was disabled because it
> could potentially be a source of confusion (and fixing the existing typos
> in hugepage_init() would also be good).  However, I disagree that we need
> to have this as a config option: you either want the feature for your
> systems or you don't.  Perhaps add a "transparent_hugepage=force" option
> that will act as "always" but also force it to be enabled in all
> scenarios, even without X86_FEATURE_PSE, that will override all the logic
> that thinks it knows better?

I think that is overkill, because we can still enable THP via /sys
for small systems.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
