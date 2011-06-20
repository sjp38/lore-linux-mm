Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 02D029000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:16:36 -0400 (EDT)
Message-ID: <4DFF8050.9070201@redhat.com>
Date: Tue, 21 Jun 2011 01:16:00 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <1308587683-2555-2-git-send-email-amwang@redhat.com> <20110620165955.GB9396@suse.de>
In-Reply-To: <20110620165955.GB9396@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 00:59, Mel Gorman a??e??:
> On Tue, Jun 21, 2011 at 12:34:29AM +0800, Amerigo Wang wrote:
>> Don't hard-code 512M as the threshold in kernel, make it configruable,
>> and set 512M by default.
>>
>
> I'm not seeing the gain here either. This is something that is going to
> be set by distributions and probably never by users. If the default of
> 512 is incorrect, what should it be? Also, the Kconfig help message has
> spelling errors.
>

Sorry for spelling errors, I am not an English speaker.

Hard-coding is almost never a good thing in kernel, enforcing 512
is not good either. Since the default is still 512, I don't think this
will affect much users.

I do agree to improve the help message, like Dave mentioned in his reply,
but I don't like enforcing a hard-coded number in kernel.

BTW, why do you think 512 is suitable for *all* users?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
