Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7F2796B005C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 19:42:54 -0400 (EDT)
Message-ID: <4A0CAC78.7060107@redhat.com>
Date: Thu, 14 May 2009 19:42:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
References: <20090513084306.5874.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905141612100.15881@qirst.com> <20090515082312.F5B6.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090515082312.F5B6.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

>>>> The percentage of file backed pages protected is set via
>>>> /proc/sys/vm/file_mapped_ratio. This defaults to 20%.
>>> Why do you think typical mapped ratio is less than 20% on desktop machine?
>> Observation of the typical mapped size of Firefox under KDE.
> 
> My point is, desktop people have very various mapped ratio.
> Do you oppose this?

I suspect that the mapped ratio could be much higher
on my system.  I have only 2GB of RAM dedicated to my
dom0 (which is also my desktop) and the amount of page
cache often goes down to about 150MB.

At the moment nr_mapped is 26400 and the amount of
memory taken up by buffer and page cache together is
a little over 300MB.  That's close to 50%.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
