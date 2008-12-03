Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB3GFYmE027111
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Dec 2008 01:15:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB23445DE50
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:15:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C76FE45DE4F
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:15:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ADE761DB8040
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:15:33 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62A1E1DB803E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:15:33 +0900 (JST)
Message-ID: <17466.10.75.179.62.1228320932.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081203141931.GH17701@balbir.in.ibm.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
    <20081201211905.1CEB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
    <20081202180525.2023892c.kamezawa.hiroyu@jp.fujitsu.com>
    <20081203141931.GH17701@balbir.in.ibm.com>
Date: Thu, 4 Dec 2008 01:15:32 +0900 (JST)
Subject: Re: [PATCH 11/11] memcg: show reclaim_stat
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-02
> 18:05:25]:
>
>> On Mon,  1 Dec 2008 21:19:49 +0900 (JST)
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> > added following four field to memory.stat file.
>> >
>> >   - recent_rotated_anon
>> >   - recent_rotated_file
>> >   - recent_scanned_anon
>> >   - recent_scanned_file
>> >
>> > it is useful for memcg reclaim debugging.
>> >
>> I'll put this under CONFIG_DEBUG_VM.
>>
>
> I think they'll be useful even outside for tasks that need to take
> decisions, it will be nice to see what sort of reclaim is going on.
There are already pgin/pgout value.

> I
> would like to see them outside, there is no cost associated with them
> and assuming we'll not change the LRU logic very frequently, we don't
> need to be afraid of breaking ABI either :)
>
There are 2 reasons to put this under DEBUG
 1. This is not exported as this value under /proc by global VM management.
 2. Few people can explain what this really means. No documentation in
    Docunemtation/ directory. I can't add precise explanation by myself.
    As Kosaki wrote, this is for his debug, IMHO.

If you want to show this, please add above two first.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
