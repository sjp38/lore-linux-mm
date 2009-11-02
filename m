Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 23F396B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:44:49 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA2FikSX011720
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Nov 2009 00:44:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C20F45DE54
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 00:44:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3C945DE52
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 00:44:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD1531DB8040
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 00:44:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 549741DB805F
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 00:44:45 +0900 (JST)
Message-ID: <7d6cb1fd385affaf02d3e1f4b648a3ce.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360911020704r45d7f4fmd347d270622fe2c5@mail.gmail.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360911020704r45d7f4fmd347d270622fe2c5@mail.gmail.com>
Date: Tue, 3 Nov 2009 00:44:44 +0900 (JST)
Subject: Re: [RFC][-mm][PATCH 0/6] oom-killer: total renewal
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> Hi, Kame.
>
> I looked over the patch series.
> It's rather big change of OOM.
yes, bigger than I expected.

> I see you and David want to make OOM fresh from scratch.
> But, It makes for testers to test harder.
>
I see. Maybe I have to separate this to 2 or 3 stages.

> I like your idea of fork-bomb detector.
> Don't we use it without big change of as-is OOM heuristic?
>
yes, this is big change. And I'll cut out usable part ;)
Maybe I'll drop most of changes in patch 6's heuristics part.
(but selection of baseline for LOWMEM is not so bad.)

What I want in early stage is
  - fix for mempolicy. (we need to pass nodemask)
  - swap counting (regardless of oom)
  - low_rss counting (if admited...)
  - fork-bomb detector

Let me think how to make patch set small and easy to test.

> Anyway,I need time to dive the code and test it.
> Maybe weekend.
>
> Thanks for great effort. :)
>
Thank you for review.

Regards,
-Kame

> On Mon, Nov 2, 2009 at 4:22 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Hi, as discussed in "Memory overcommit" threads, I started rewrite.
>>
>> This is just for showing "I started" (not just chating or sleeping ;)
>>
>> All implemtations are not fixed yet. So feel free to do any comments.
>> This set is for minimum change set, I think. Some more rich functions
>> can be implemented based on this.
>>
>> All patches are against "mm-of-the-moment snapshot 2009-11-01-10-01"
>>
>> Patches are organized as
>>
>> (1) pass oom-killer more information, classification and fix mempolicy
>> case.
>> (2) counting swap usage
>> (3) counting lowmem usage
>> (4) fork bomb detector/killer
>> (5) check expansion of total_vm
>> (6) rewrite __badness().
>>
>> passed small tests on x86-64 boxes.
>>
>> Thanks,
>> -Kame
>>
>>
>
>
>
> --
> Kind regards,
> Minchan Kim
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
