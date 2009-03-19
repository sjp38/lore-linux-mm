Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D9566B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 06:46:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2JAkqVT031598
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 19 Mar 2009 19:46:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CAFB45DE54
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 19:46:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 674D145DE51
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 19:46:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 485451DB8040
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 19:46:52 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D5D12E18002
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 19:46:51 +0900 (JST)
Message-ID: <100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
    <20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
    <20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
    <20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
    <20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
    <20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
    <20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
    <20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
    <20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
    <20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
    <20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090319111629.dcc9fe43.kamezawa.hiroyu@jp.fujitsu.com>
    <20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
    <20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
    <20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 19 Mar 2009 19:46:51 +0900 (JST)
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura さんは書きました：
> On Thu, 19 Mar 2009 19:01:18 +0900, Daisuke Nishimura
> <nishimura@mxp.nes.nec.co.jp> wrote:
>> On Thu, 19 Mar 2009 18:06:31 +0900, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > Core logic are much improved and I confirmed this logic can reduce
>> > orphan swap-caches. (But the patch size is bigger than expected.)
>> > Long term test is required and we have to verify paramaters are
>> reasonable
>> > and whether this doesn't make swapped-out applications slow..
>> >
>> Thank you for your patch.
>> I'll test this version and check what happens about swapcache usage.
>>
> hmm... underflow of inactive_anon seems to happen after a while.
> I've not done anything but causing memory pressure yet.
>
Hmm..maybe I miss something. maybe mem_cgroup_commit_charge() removes
Orphan flag implicitly.

I'll dig but may not be able to post a patch in this week.

Thanks,
-Kame



> [nishimura@GibsonE ~]$ cat /cgroup/memory/01/memory.stat
> cache 22994944
> rss 10559488
> pgpgin 2301009
> pgpgout 2292817
> active_anon 21004288
> inactive_anon 18446744073709510656
> active_file 1605632
> inactive_file 10944512
> unevictable 0
> hierarchical_memory_limit 33554432
> hierarchical_memsw_limit 50331648
> inactive_ratio 1
> recent_rotated_anon 857
> recent_rotated_file 10
> recent_scanned_anon 877
> recent_scanned_file 400
>
>
> Thanks,
> Daisuke Nishimura.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
