Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F8DF6B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 12:25:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n54GPXOh029035
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Jun 2009 01:25:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CAD0545DE7A
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:25:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 615F445DE70
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:25:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA80D1DB803E
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:25:31 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 615601DB803B
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:25:31 +0900 (JST)
Message-ID: <990133947abefb130319d1a7339b718d.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0906041600540.18591@sister.anvils>
References: <4A26AC73.6040804@gmail.com>
    <Pine.LNX.4.64.0906041600540.18591@sister.anvils>
Date: Fri, 5 Jun 2009 01:25:30 +0900 (JST)
Subject: Re: swapoff throttling and speedup?
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Joel Krauska <jkrauska@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 3 Jun 2009, Joel Krauska wrote:
>> I'm hoping others have been down this road before.
>>
>> As a rule, we try to avoid swapping when possible, but using:
>> vm.swappiness = 1
>>
>> But it does still happen on occasion and that lead to this mail.
>
> Thanks for taking the trouble to write: opinions, anyone?
>

Is there anyone who wants a system call like this ?

  int mem_swapin(int pid, start-addr, size)
  - try to swap in pages from range [addr, addr+size) of pid.
    we can do this force-pagein against file caches and shmem now.
    this is for swap.

I doubts there are no one who can make use of this in sane way. But I'm
sometimes surprised to find that there are people make use of swap
intentionally...

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
