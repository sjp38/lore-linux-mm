Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A10F16B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 18:06:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBIN6q5Q029871
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 19 Dec 2009 08:06:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0A1145DE65
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 08:06:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9D2A45DE55
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 08:06:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B29AB1DB8043
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 08:06:51 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CFAA1DB803E
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 08:06:51 +0900 (JST)
Message-ID: <ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20091218160437.GP29790@random.random>
References: <patchbomb.1261076403@v2.random>
    <d9c8d2160feb7d82736b.1261076431@v2.random>
    <20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
    <20091218160437.GP29790@random.random>
Date: Sat, 19 Dec 2009 08:06:50 +0900 (JST)
Subject: Re: [PATCH 28 of 28] memcg huge memory
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Fri, Dec 18, 2009 at 10:33:12AM +0900, KAMEZAWA Hiroyuki wrote:
>> Then, maybe we (I?) should cut this part (and some from 27/28) out and
>> merge into memcg. It will be helpful to all your work.
>
> You can't merge this part, huge_memory.c is not there yet. But you
> should merge 27/28 instead, that one is self contained.
>
>> But I don't like a situation which memcg's charge are filled with
>> _locked_ memory.
>
> There's no locked memory here. It's all swappable.
>
Ok, I missed.

My intentsion was adding a patch for adding "pagesize" parameters
to charge/uncharge function may be able to reduce size of changes.

>> (Especially, bad-configured softlimit+hugepage will adds much
>> regression.)
>> New counter as "usage of huge page" will be required for memcg, at
>> least.
>
> no, hugepages are fully transparent and userland can't possibly know
> if it's running on hugepages or regular pages. The only difference is
> in userland going faster, everything else is identical so there's no
> need of any other memcg.
>
I read your patch again.
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
