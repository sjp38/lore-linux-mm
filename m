Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 243E86B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 07:17:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8GBHuOD031497
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Sep 2009 20:17:56 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7154B45DE51
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:17:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F92C45DE4E
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:17:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3196CE1800B
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:17:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DB1F4E1800A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:17:52 +0900 (JST)
Message-ID: <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
Date: Wed, 16 Sep 2009 20:17:52 +0900 (JST)
Subject: Re: kcore patches (was Re: 2.6.32 -mm merge plans)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Am=?ISO-2022-JP?B?P3JpY29fV2FuZw==?= <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Américo_Wang さんは書きました：
> On Wed, Sep 16, 2009 at 7:15 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>>#kcore-fix-proc-kcores-statst_size.patch: is it right?
>>kcore-fix-proc-kcores-statst_size.patch
>
> Hmm, I think KAMEZAWA Hiroyuki's patchset is a much better fix for this.
> Hiroyuki?
>
Hmm ? My set is not agaisnt "file size" of /proc/kcore.

One problem of this patch is..this makes size of /proc/kcore as 0 bytes.
Then, objdump cannot read this. (it checks file size.)
readelf can read this. (it ignores file size.)

I wonder what you mention is.... because we know precise kclist_xxx
after my series, we can calculate kcore's size in precise by
get_kcore_size().

It seems /proc's inode->i_size is "static" and we cannot
provides return value of get_kcore_size() directly. It may need
some work and should depends on my kclist_xxx patch sets which are not
in merge candidates. If you can wait, I'll do some work for fixing this
problem. (but will not be able to merge directly against upstream.)

But for now, we have to use some fixed value....and using above
patch for 2.6.31 is not very bad.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
