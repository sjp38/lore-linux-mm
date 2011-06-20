Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C5DF09000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:01:25 -0400 (EDT)
Message-ID: <4DFF7CDD.308@redhat.com>
Date: Tue, 21 Jun 2011 01:01:17 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165035.GE20843@redhat.com>
In-Reply-To: <20110620165035.GE20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 00:50, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
>> transparent_hugepage=never should mean to disable THP completely,
>> otherwise we don't have a way to disable THP completely.
>> The design is broken.
>
> We want to allow people to boot with transparent_hugepage=never but to
> still allow people to enable it later at runtime. Not sure why you
> find it broken... Your patch is just crippling down the feature with
> no gain. There is absolutely no gain to disallow root to enable THP
> later at runtime with sysfs, root can enable it anyway by writing into
> /dev/mem.


What can I do if I don't want to see THP at all? I mean the same
behavior as when my CPU doesn't have PSE.

With this patch, there is no even /sys/kernel/vm/transparent_hugepage/
exists.

>
> Unless you're root and you enable it, it's completely disabled, so I
> don't see what you mean it's not completely disabled. Not even
> khugepaged is started, try to grep of khugepaged... (that wouldn't be
> the same with ksm where ksm daemon runs even when it's off for no
> gain, but I explicitly solved the locking so khugepaged will go away
> when enabled=never and return when enabled=always).

Without this patch, THP is still initialized (although khugepaged is not started),
that is what I don't want to see when I pass "transparent_hugepage=never",
because "never" for me means THP is totally unseen, even not initialized.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
