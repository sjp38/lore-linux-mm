Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FDA86B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:20:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA6JKueL022306
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 7 Nov 2009 04:20:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF4A445DE4F
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:20:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE1F945DD77
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:20:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3F441DB8037
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:20:55 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A50B1DB803B
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:20:52 +0900 (JST)
Message-ID: <ffef0f18fe9ae9948d0db7fb4b0a0341.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911061409310.15636@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
    <20091104234923.GA25306@redhat.com>
    <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
    <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
    <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
    <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1>
    <da621335371fccd6cfb3d8d7c0c2bf3a.squirrel@webmail-b.css.fujitsu.com>
    <alpine.DEB.1.10.0911061409310.15636@V090114053VZO-1>
Date: Sat, 7 Nov 2009 04:20:51 +0900 (JST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 7 Nov 2009, KAMEZAWA Hiroyuki wrote:
>
>> And allocate mm->usage only when the first CLONE_THREAD is specified.
>
> Ok.
>
>> if (mm->usage)
>>     access per cpu
>> else
>>     atomic_long_xxx
>
> If we just have one thread: Do we need atomic access at all?
>
Unfortunately, kswapd/vmscan touch this.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
