Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC566B0204
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 03:18:26 -0400 (EDT)
Message-ID: <4BC6BE78.1030503@kernel.org>
Date: Thu, 15 Apr 2010 16:21:28 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>	 <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org> <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
In-Reply-To: <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/15/2010 10:31 AM, Minchan Kim wrote:
> Hi, Tejun.
>> This being a pretty cold path, I don't really see much benefit in
>> converting it to alloc_pages_node_exact().  It ain't gonna make any
>> difference.  I'd rather stay with the safer / boring one unless
>> there's a pressing reason to convert.
> 
> Actually, It's to weed out not-good API usage as well as some
> performance gain.  But I don't think to need it strongly.
> Okay. Please keep in mind about this and correct it if you confirms
> it in future. :)

Hmm... if most users are converting over to alloc_pages_node_exact(),
I think it would be better to convert percpu too.  I thought it was a
performance optimization (of rather silly kind too).  So, this is to
weed out -1 node id usage?  Wouldn't it be better to update
alloc_pages_node() such that it whines once per each caller if it's
called with -1 node id and after updating most users convert the
warning into WARN_ON_ONCE()?  Having two variants for this seems
rather extreme to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
