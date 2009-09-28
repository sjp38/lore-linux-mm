Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DB8B96B009E
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:12:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8SGE5AX031504
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Sep 2009 01:14:05 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5AF945DE50
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 01:14:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2C9545DE4F
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 01:14:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8C1E1DB803F
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 01:14:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40C021DB8041
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 01:14:04 +0900 (JST)
Message-ID: <a0ea21a7cfe313202e2b51510aa5435a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909281637160.25798@sister.anvils>
References: <4AB9A0D6.1090004@crca.org.au>
    <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
    <4ABC80B0.5010100@crca.org.au>
    <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
    <4AC0234F.2080808@crca.org.au>
    <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
    <20090928033624.GA11191@localhost>
    <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0909281637160.25798@sister.anvils>
Date: Tue, 29 Sep 2009 01:14:03 +0900 (JST)
Subject: Re: No more bits in vm_area_struct's vm_flags.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 28 Sep 2009, KAMEZAWA Hiroyuki wrote:
>>
>> What I dislike is making vm_flags to be long long ;)
>
> Why?
I'm sorry if my "dislike" sounds too strong.

Every time I see long long in the kernel, my concern is
"do I need spinlock to access this for 32bit arch ? is it safe ?".
(And it makes binary=>disassemble=>C (by eyes) a bit difficult)
Then, I don't like long long personally.

Another reason is some other calls like test_bit() cannot be used against
long long. (even if it's not used _now_)

Maybe vm->vm_flags will not require extra locks because
it can be protected by bigger lock as mmap_sem. Then, please make it
to be long long if its's recommended.

keeping vm_flags to be 32bit may makes vma_merge() ugly.
If so, long long is  a choice.

Thanks,
-Kame


> Hugh
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
