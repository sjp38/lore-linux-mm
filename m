Received: from m7.gw.fujitsu.co.jp ([10.0.50.77]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L5LgwH031975 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:21:42 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L5LfsA004090 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:21:41 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7L5LfBM008307 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 14:21:41 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2S00IMX6W4BT@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 14:21:41 +0900 (JST)
Date: Sat, 21 Aug 2004 14:26:48 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
In-reply-to: <20040821.140121.41645060.taka@valinux.co.jp>
Message-id: <4126DD18.70306@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <20040821025543.GS11200@holomorphy.com> <4126D6E5.9070804@jp.fujitsu.com>
 <20040821.140121.41645060.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: wli@holomorphy.com, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,
Hirokazu Takahashi wrote:

> Hi,
> 
> 
>>William Lee Irwin III wrote:
>>
>>
>>>On Sat, Aug 21, 2004 at 11:31:21AM +0900, Hiroyuki KAMEZAWA wrote:
>>>
>>>
>>>>This patch removes bitmap from buddy allocator used in
>>>>alloc_pages()/free_pages() in the kernel 2.6.8.1.
<snip>
>>In my understanding, the patch assumes that size of mem_map[] in each
>>zone must be multiple of 2^MAX_ORDER, right?
>>But it doesn't seem it's a big problem, as we can just allocate extra
>>mem_map[] to round up if it isn't.
> 
> 
> I think this may help the buddy allocator to work withtout adding
> page_ivs_valid(buddy1).
> 
> 
As you say, I expects the size of zone is multiple of MAX_ORDER.
But IA64 kernel's MAX_ORDER is 4 Giga bytes :(
A Tiger4, an IA64 machine, I use has physical  memory map like this:

0-2G  :
4-8G  :
10-12G:

contiguous mem_map is smaller than MAX_ORDER.

So I think page_is_valid(buddy1) is needed only for a few pages,
which is top of big buddy, in this case.

Hmm.... :(

Thank you,
KAME

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
