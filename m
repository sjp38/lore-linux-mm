Date: Thu, 18 Sep 2008 15:58:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Populating multiple ptes at fault time
In-Reply-To: <28c262360809171650g1395bbe2ya4e560851d37760d@mail.gmail.com>
References: <48D142B2.3040607@goop.org> <28c262360809171650g1395bbe2ya4e560851d37760d@mail.gmail.com>
Message-Id: <20080920035706.BAD6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeremy Fitzhardinge <jeremy@goop.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>
List-ID: <linux-mm.kvack.org>

> Hi, all
> 
> I have been thinking about this idea in native.
> I didn't consider it in minor page fault.
> As you know, it costs more cheap than major fault.
> However, the page fault is one of big bottleneck on demand-paging system.
> I think major fault might be a rather big overhead in many core system.
> 
> What do you think about this idea in native ?
> Do you really think that this idea don't help much in native ?
> 
> If I implement it in native, What kinds of benchmark do I need?
> Could you recommend any benchmark ?

I guess it is also useful for native.
Then, if you post patch & benchmark result, I'll review it with presusure.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
