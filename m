Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5D39000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 05:45:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 91D793EE0C0
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 18:45:10 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B16245DE8F
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 18:45:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5628545DE9B
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 18:45:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A4071DB803C
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 18:45:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FD231DB8038
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 18:45:10 +0900 (JST)
Message-ID: <4E085113.7060200@jp.fujitsu.com>
Date: Mon, 27 Jun 2011 18:44:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
References: <1308779480-4950-1-git-send-email-andrea@betterlinux.com> <4E03200D.60704@draigBrady.com> <4E081764.7040709@jp.fujitsu.com> <4E084AA7.2030701@draigBrady.com>
In-Reply-To: <4E084AA7.2030701@draigBrady.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P@draigBrady.com
Cc: andrea@betterlinux.com, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/06/27 18:17), Padraig Brady wrote:
> On 27/06/11 06:38, KOSAKI Motohiro wrote:
>>> Hmm, What if you do want to evict it from the cache for testing purposes?
>>> Perhaps this functionality should be associated with POSIX_FADV_NOREUSE?
>>> dd has been recently modified to support invalidating the cache for a file,
>>> and it uses POSIX_FADV_DONTNEED for that.
>>> http://git.sv.gnu.org/gitweb/?p=coreutils.git;a=commitdiff;h=5f311553
>>
>> This change don't break dd. dd don't have a special privilege of file cache
>> dropping if it's also used by other processes.
>>
>> if you want to drop a cache forcely (maybe for testing), you need to use
>> /proc/sys/vm/drop_caches. It's ok to ignore other processes activity because
>> it's privilege operation.
> 
> Well the function and privileges are separate things.
> I think we've agreed that the new functionality is
> best associated with POSIX_FADV_NOREUSE,
> and the existing functionality with POSIX_FADV_DONTNEED.
> 
> BTW, I don't think privileges are currently enforced
> as I got root to cache a file here with:
>   # (time md5sum; sleep 100) < big.file
> And a normal user was able to uncache with:
>   $ dd iflag=nocache if=big.file count=0
> Anyway as said, this is a separate "issue".

I'm failed to see your point. Why does dd need to ignore other
process activity? If no other process, this patch doesn't change
any behavior. Isn't it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
