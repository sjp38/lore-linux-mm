Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F2C696B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:28:57 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nADGSrrT024147
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 14 Nov 2009 01:28:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AA8645DE53
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:28:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 506E745DE4F
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:28:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 108251DB8040
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:28:53 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B68BA1DB803F
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:28:52 +0900 (JST)
Message-ID: <79c5730b1754925478f02c1605dde814.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360911130759tb9ffde4n8101bd27f31b5669@mail.gmail.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
    <20091113164134.79805c13.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360911130759tb9ffde4n8101bd27f31b5669@mail.gmail.com>
Date: Sat, 14 Nov 2009 01:28:51 +0900 (JST)
Subject: Re: [RFC MM 4/4] speculative page fault
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> On Fri, Nov 13, 2009 at 4:41 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> + &#160; &#160; &#160; if (mm->generation != key)
>> + &#160; &#160; &#160; &#160; &#160; &#160; &#160; goto
speculative_fault_retry;
>> +
>
> You can use match_key in here again. :)
>
Ah, yes. mm->key or mm->version is more straightforward, maybe.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
