Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L5WowH003653 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:32:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L5WomZ013710 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:32:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s3.gw.fujitsu.co.jp (8.12.10)
	id i7L5WnkO025932 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:32:49 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2S0094F7EOBA@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 14:32:49 +0900 (JST)
Date: Sat, 21 Aug 2004 14:37:56 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
In-reply-to: <20040821052116.GU11200@holomorphy.com>
Message-id: <4126DFB4.7070404@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <20040821025543.GS11200@holomorphy.com>
 <20040821.135624.74737461.taka@valinux.co.jp>
 <20040821052116.GU11200@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

> On Sat, Aug 21, 2004 at 01:56:24PM +0900, Hirokazu Takahashi wrote:
> 
>>I also impressed by your patch.
>>In my understanding, the patch assumes that size of mem_map[] in each
>>zone must be multiple of 2^MAX_ORDER, right?
>>But it doesn't seem it's a big problem, as we can just allocate extra
>>mem_map[] to round up if it isn't.
> 
> 
> In __free_pages_bulk() changing BUG_ON(bad_range(zone, buddy1)) to
> if (bad_range(zone, buddy1)) break; should fix this. The start of
> the zone must be aligned to MAX_ORDER so buddy2 doesn't need checks.
> It may be worthwhile to make a distinction the bounds checks and the
> zone check and to BUG_ON() the zone check in isolation and not repeat
> the bounds check for the validity check.
> 
> 
Okay, I understand several BUG_ON() are needless.
I'll be more carefull to recognize what is checked.

Thank you.
KAME

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
