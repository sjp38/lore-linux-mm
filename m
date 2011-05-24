Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EB3916B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:06:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 07F993EE0BB
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:06:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E2EAC45DEC3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:06:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB69445DEC2
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:06:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE93B1DB803F
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:06:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8606B1DB802F
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:06:09 +0900 (JST)
Message-ID: <4DDB74F7.9020109@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:05:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
References: <4DCDA347.9080207@cray.com> <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com> <4DD2991B.5040707@cray.com> <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com> <20110520164924.GB2386@barrios-desktop> <4DDB3A1E.6090206@jp.fujitsu.com> <20110524083008.GA5279@suse.de> <4DDB6DF6.2050700@jp.fujitsu.com> <20110524084915.GC5279@suse.de>
In-Reply-To: <20110524084915.GC5279@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: minchan.kim@gmail.com, abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

>>> Why?
>>
>> Otherwise, we don't have good PCP dropping trigger. Big machine might have
>> big pcp cache.
>>
> 
> Big machines also have a large cost for sending IPIs.

Yes. But it's only matter if IPIs are frequently happen.
But, drain_all_pages() is NOT only IPI source. some vmscan function (e.g.
try_to_umap) makes a lot of IPIs.

Then, it's _relatively_ not costly. I have a question. Do you compare which
operation and drain_all_pages()? IOW, your "costly" mean which scenario suspect?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
