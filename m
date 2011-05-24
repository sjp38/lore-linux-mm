Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 02F926B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 19:53:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BCD863EE081
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:53:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A1C2745DF4D
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:53:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8874F45DF48
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:53:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A497E08002
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:53:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 432CE1DB8037
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:53:38 +0900 (JST)
Message-ID: <4DDC44F0.6090809@jp.fujitsu.com>
Date: Wed, 25 May 2011 08:53:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
References: <4DD2991B.5040707@cray.com> <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com> <20110520164924.GB2386@barrios-desktop> <4DDB3A1E.6090206@jp.fujitsu.com> <20110524083008.GA5279@suse.de> <4DDB6DF6.2050700@jp.fujitsu.com> <20110524084915.GC5279@suse.de> <4DDB74F7.9020109@jp.fujitsu.com> <20110524091611.GD5279@suse.de> <4DDB7D0F.3060204@jp.fujitsu.com> <20110524105746.GF5279@suse.de>
In-Reply-To: <20110524105746.GF5279@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: minchan.kim@gmail.com, abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

>> In old days, we always call drain_all_pages() if did_some_progress!=0. But
>> current kernel only call it when get_page_from_freelist() fail. So,
>> wait_iff_congested() may help but no guarantee to help us.
>>
>> If you still strongly worry about IPI cost, I'm concern to move drain_all_pages()
>> to more unfrequently point. but to ignore pcp makes less sense, IMHO.
>>
> 
> Yes, I'm worried about it because excessive time
> spent in drain_all_pages() has come up on the past
> http://lkml.org/lkml/2010/8/23/81 . The PCP lists are not being
> ignored at the moment. They are drained when direct reclaim makes
> forward progress but still fails to allocate a page.

Well, it's no priority==0 case. that's my point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
