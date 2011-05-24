Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 723456B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:36:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 20AE33EE0BC
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:36:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 070CD2AEA8D
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:36:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1CB42E68C3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:36:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5F9EEF8004
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:36:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93A84E08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:36:40 +0900 (JST)
Message-ID: <4DDB7C1D.8040300@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:36:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
References: <4DCDA347.9080207@cray.com>	<BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>	<4DD2991B.5040707@cray.com>	<BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>	<20110520164924.GB2386@barrios-desktop>	<4DDB3A1E.6090206@jp.fujitsu.com>	<BANLkTinkcu5j1H8tHNT4aTmOL-GXfSwPQw@mail.gmail.com>	<4DDB6F48.1010809@jp.fujitsu.com> <BANLkTimbu0pDNb1cHGu0B6P-foRHQ2uiWw@mail.gmail.com>
In-Reply-To: <BANLkTimbu0pDNb1cHGu0B6P-foRHQ2uiWw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com

>> Can you please tell me previous discussion url or mail subject?
>> I mean, if it is costly and performance degression risk, we don't have to
>> take my idea.
> 
> Yes. You could see it by https://lkml.org/lkml/2011/4/30/81.

I think Wu pointed out "lightweight vmscan could reclaim pages but stealed
from another task case". It's very different with "most heavyweight vmscan
still failed to reclaim any pages". The point is, IPIs cost depend on the
frequency. stealing frequently occur on current logic, but vmscan priority==0
is?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
