Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D1C516B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 07:46:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n81BkWcf025891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 20:46:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C46D45DE4F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 20:46:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7015645DE4C
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 20:46:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CF0F1DB8041
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 20:46:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D2C7E08001
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 20:46:32 +0900 (JST)
Message-ID: <131e030829a2333d9e0de29783133335.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909011217440.18858@sister.anvils>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
    <20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0909011031140.13740@sister.anvils>
    <20090901185013.c86bd937.kamezawa.hiroyu@jp.fujitsu.com>
    <20090901191018.19a69696.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0909011158080.17324@sister.anvils>
    <Pine.LNX.4.64.0909011217440.18858@sister.anvils>
Date: Tue, 1 Sep 2009 20:46:31 +0900 (JST)
Subject: Re: [mmotm][BUG] free is bigger than presnet Re: mmotm
 2009-08-27-16-51 uploaded
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 1 Sep 2009, Hugh Dickins wrote:
>> On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:
>> >
>> > Sorry again, at continuing tests...thre are still..
>> >
>> > MemTotal:       24421124 kB
>> > MemFree:        25158956 kB
>> > Buffers:            2264 kB
>> > Cached:            34936 kB
>> > SwapCached:         5140 kB
>> >
>> > I wonder I miss something..
>>
>> I've not been looking at /proc/meminfo: I'll do some stuff and see
>> if it goes wrong for me too, will let you know if so.
>
> Well, I've not yet noticed unbelievable MemFree, but my Active(anon)
> (and Active) is bigger than my MemTotal and rising each iteration.
>
> Probably not directly related to your case, and probably related to
> my tmpfs or loop use: but I'd better pursue the anomaly I can so
> easily reproduce, than worry about the anomaly you can reproduce.
>
I'll dig more. (After dinner, I doubt myself ;)

> Good luck with yours!
you too.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
