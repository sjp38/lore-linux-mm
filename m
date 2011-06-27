Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 471599000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 03:43:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5B5D23EE0BC
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 16:42:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40FDC45DF48
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 16:42:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 286F845DF41
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 16:42:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A59A1DB804D
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 16:42:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6D81DB803C
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 16:42:56 +0900 (JST)
Message-ID: <4E08346F.3070203@jp.fujitsu.com>
Date: Mon, 27 Jun 2011 16:42:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/2] fadvise: support POSIX_FADV_NOREUSE
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com> <4E07F349.2040900@jp.fujitsu.com> <20110627071139.GC1247@thinkpad>
In-Reply-To: <20110627071139.GC1247@thinkpad>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andrea@betterlinux.com
Cc: akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, tytso@mit.edu, shaohua.li@intel.com, P@draigBrady.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>>>  POSIX_FADV_DONTNEED = drop page cache if possible
>>>  POSIX_FADV_NOREUSE = reduce page cache eligibility
>>
>> Eeek.
>>
>> Your POSIX_FADV_NOREUSE is very different from POSIX definition.
>> POSIX says,
>>
>>        POSIX_FADV_NOREUSE
>>               Specifies that the application expects to access the specified data once  and  then
>>               not reuse it thereafter.
>>
>> IfI understand correctly, it designed for calling _before_ data access
>> and to be expected may prevent lru activation. But your NORESE is designed
>> for calling _after_ data access. Big difference might makes a chance of
>> portability issue.
> 
> You're right. NOREUSE is designed to implement drop behind policy.
> 
> I'll post a new patch that will plug this logic in DONTNEED (like the
> presious version), but without breaking the old /proc/sys/vm/drop_caches
> behavior.

Great!

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
