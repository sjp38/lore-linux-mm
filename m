Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DAC59900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 13:50:09 -0400 (EDT)
Received: by wwi36 with SMTP id 36so4242508wwi.26
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 10:50:07 -0700 (PDT)
Message-ID: <4DAB26F6.40407@gmail.com>
Date: Sun, 17 Apr 2011 19:44:22 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
References: <20110416132546.765212221@intel.com> <4DAA976A.3080007@gmail.com> <20110417093048.GA4027@localhost>
In-Reply-To: <20110417093048.GA4027@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Il 17/04/2011 11:30, Wu Fengguang ha scritto:
> On Sun, Apr 17, 2011 at 03:31:54PM +0800, Marco Stornelli wrote:
>> Il 16/04/2011 15:25, Wu Fengguang ha scritto:
>>> Andrew,
>>>
>>> This revision undergoes a number of simplifications, cleanups and fixes.
>>> Independent patches are separated out. The core patches (07, 08) now have
>>> easier to understand changelog. Detailed rationals can be found in patch 08.
>>>
>>> In response to the complexity complaints, an introduction document is
>>> written explaining the rationals, algorithm and visual case studies:
>>>
>>> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
>>
>> It'd be great if you wrote a summary in the kernel documentation.
>
> Perhaps not in this stage. That will only frighten people away I'm
> afraid. The main concerns now are "why the complexities?". People at
> this time perhaps won't bother looking into any lengthy documents at
> all.
>

For the moment ok if you think we are in a not-ready-for-mainline yet. 
But for the final version the documentation would be welcome, maybe with 
the pdf as reference. The documentation is always the last thing but 
it's important! :)

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
