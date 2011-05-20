Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 836FF6B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:00:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1F2953EE0C2
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:00:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0268E45DE50
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:00:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E212A45DE4E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:00:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB4631DB802F
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:00:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D7071DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:00:13 +0900 (JST)
Message-ID: <4DD5D92B.8030209@jp.fujitsu.com>
Date: Fri, 20 May 2011 11:59:55 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control
 struct
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, yinghan@google.com, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com

> Hmm, got Nick's email wrong.
> 
> --Ying

Ping.
Can you please explain current status? When I can see your answer?



> 
> On Tue, Apr 26, 2011 at 6:15 PM, Ying Han <yinghan@google.com> wrote:
>> On Tue, Apr 26, 2011 at 5:47 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>>> > > {
>>>> > >    struct xfs_mount *mp;
>>>> > >    struct xfs_perag *pag;
>>>> > >    xfs_agnumber_t ag;
>>>> > >    int       reclaimable;
>>>> > > +   int nr_to_scan = sc->nr_slab_to_reclaim;
>>>> > > +   gfp_t gfp_mask = sc->gfp_mask;
>>>> >
>>>> > And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim
>>>> > poped up new question.
>>>> > Why don't we pass more clever slab shrinker target? Why do we need pass
>>>> > similar two argument?
>>>> >
>>>>
>>>> I renamed the nr_slab_to_reclaim and nr_scanned in shrink struct.
>>>
>>> Oh no. that's not naming issue. example, Nick's previous similar patch pass
>>> zone-total-pages and how-much-scanned-pages. (ie shrink_slab don't calculate
>>> current magical target scanning objects anymore)
>>>    ie, "4 * max_pass * (scanned / nr- lru_pages-in-zones)"
>>>
>>> Instead, individual shrink_slab callback calculate this one.
>>> see git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
>>>
>>> I'm curious why you change the design from another guy's previous very similar effort and
>>> We have to be convinced which is better.
>>
>> Thank you for the pointer. My patch is intended to consolidate all
>> existing parameters passed from reclaim code
>> to the shrinker.
>>
>> Talked w/ Nick and Andrew from last LSF, we agree that this patch
>> will be useful for other extensions later which allows us easily
>> adding extensions to the shrinkers without shrinker files. Nick and I
>> talked about the effort later to pass the nodemask down to the
>> shrinker. He is cc-ed in the thread. Another thing I would like to
>> repost is to add the reclaim priority down to the shrinker, which we
>> won't throw tons of page caches pages by reclaiming one inode slab
>> object.
>>
>> --Ying


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
