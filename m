Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 56F246B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:27:10 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nADGR0XR020531
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 14 Nov 2009 01:27:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9857F45DE6F
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:27:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7959245DE6E
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:27:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EEFA1DB803A
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:27:00 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16D791DB8037
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:27:00 +0900 (JST)
Message-ID: <3ddc57a71ab7c3a1eb1c08f6fc5dca47.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360911130727s25c34179u30360765c08853e0@mail.gmail.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
    <20091113164029.e7e8bcea.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360911130727s25c34179u30360765c08853e0@mail.gmail.com>
Date: Sat, 14 Nov 2009 01:26:59 +0900 (JST)
Subject: Re: [RFC MM 3/4] add mm version number
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> Hi, Kame.
>
Hi,

> On Fri, Nov 13, 2009 at 4:40 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>> &#160;static inline int mm_writer_trylock(struct mm_struct *mm)
>> &#160;{
>> - &#160; &#160; &#160; return down_write_trylock(&mm->sem);
>> + &#160; &#160; &#160; int ret = down_write_trylock(&mm->sem);
>> + &#160; &#160; &#160; if (!ret)
>
> It seems your typo.
> if (ret) ?
>
yes, yes..my mistake.
Thank you.

Regards,
-Kame


>> + &#160; &#160; &#160; &#160; &#160; &#160; &#160; mm->generation++;
>> + &#160; &#160; &#160; return ret;
>> &#160;}
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
