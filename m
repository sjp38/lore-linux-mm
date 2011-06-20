Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 93BF59000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:07:15 -0400 (EDT)
Message-ID: <4DFF7E3B.1040404@redhat.com>
Date: Tue, 21 Jun 2011 01:07:07 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de>
In-Reply-To: <20110620165844.GA9396@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 00:58, Mel Gorman a??e??:
> On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
>> transparent_hugepage=never should mean to disable THP completely,
>> otherwise we don't have a way to disable THP completely.
>> The design is broken.
>>
>
> I don't get why it's broken. Why would the user be prevented from
> enabling it at runtime?
>

We need to a way to totally disable it, right? Otherwise, when I configure
THP in .config, I always have THP initialized even when I pass "=never".

For me, if you don't provide such way to disable it, it is not flexible.

I meet this problem when I try to disable THP in kdump kernel, there is
no user of THP in kdump kernel, THP is a waste for kdump kernel. This is
why I need to find a way to totally disable it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
