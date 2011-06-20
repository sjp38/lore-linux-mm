Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BEE8D9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:23:33 -0400 (EDT)
Message-ID: <4DFF8207.5080700@redhat.com>
Date: Tue, 21 Jun 2011 01:23:19 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>	 <1308587683-2555-2-git-send-email-amwang@redhat.com> <1308589163.11430.245.camel@nimitz>
In-Reply-To: <1308589163.11430.245.camel@nimitz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 00:59, Dave Hansen a??e??:
> On Tue, 2011-06-21 at 00:34 +0800, Amerigo Wang wrote:
>> +config TRANSPARENT_HUGEPAGE_THRESHOLD
>> +       depends on TRANSPARENT_HUGEPAGE
>> +       int "The minimal threshold of enabling Transparent Hugepage"
>> +       range 512 8192
>> +       default "512"
>> +       help
>> +         The threshold of enabling Transparent Huagepage automatically,
>> +         in Mbytes, below this value, Transparent Hugepage will be disabled
>> +         by default during boot.
>
> It makes some sense to me that there would _be_ a threshold, simply
> because you need some space to defragment things.  But, I can't imagine
> any kind of user having *ANY* kind of idea what to set this to.  Could
> we add some text to this?  Maybe:
>
>          Transparent hugepages are created by moving other pages out of
>          the way to create large, contiguous swaths of free memory.
>          However, some memory on a system can not be easily moved.  It is
>          likely on small systems that this unmovable memory will occupy a
>          large portion of total memory, which makes even attempting to
>          create transparent hugepages very expensive.
>
>          If you are unsure, set this to the smallest possible value.
>
>          To override this at boot, use the $FOO boot command-line option.
>

Yeah, I totally agree to improve the help message as you said,
please forgive a non-English speaker. ;)

> I'm also not sure putting a ceiling on this makes a lot of sense.
> What's the logic behind that?  I know it would be a mess to expose it to
> users, but shouldn't this be a per-zone limit, logically?  Seems like a
> 8GB system would have similar issues to a two-numa-node 16GB system.
>

I am not sure about this, since I am new to THP, I just replaced
the hard-code 512 with a Kconfig var. But I am certainly open
to improve this as you said if Andrea agrees.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
