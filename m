Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C125990015F
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 19:45:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C6CBC3EE0BB
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:45:17 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B07E945DE68
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:45:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 857CF45DE7E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:45:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75FCE1DB803A
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:45:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 425C01DB8038
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:45:17 +0900 (JST)
Message-ID: <4E373A80.3090206@jp.fujitsu.com>
Date: Tue, 02 Aug 2011 08:45:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: reverse lru scanning order
References: <20110727111002.9985.94938.stgit@localhost6> <4E36D110.30407@openvz.org>
In-Reply-To: <4E36D110.30407@openvz.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@openvz.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

(2011/08/02 1:15), Konstantin Khlebnikov wrote:
> sorry, this patch is broken.

If you resend a _tested_ patch, I'll ack this one.

Thanks.


> 
> Konstantin Khlebnikov wrote:
>> LRU scanning order was accidentially changed in commit v2.6.27-5584-gb69408e:
>> "vmscan: Use an indexed array for LRU variables".
>> Before that commit reclaimer always scan active lists first.
>>
>> This patch just reverse it back.
>> This is just notice and question: "Does it affect something?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
