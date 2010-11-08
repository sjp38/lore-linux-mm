Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8584C6B0095
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 17:51:18 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 4/4] memcg: use native word page statistics counters
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.964566018@cmpxchg.org>
	<AANLkTinLK5DiG3ZkEFSAJNZrPKK7aXiPPYQ6z9M6RPhc@mail.gmail.com>
Date: Mon, 08 Nov 2010 14:51:01 -0800
In-Reply-To: <AANLkTinLK5DiG3ZkEFSAJNZrPKK7aXiPPYQ6z9M6RPhc@mail.gmail.com>
	(Minchan Kim's message of "Mon, 8 Nov 2010 09:01:54 +0900")
Message-ID: <xr93pqufa0q2.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Minchan Kim <minchan.kim@gmail.com> writes:

> On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
>> The statistic counters are in units of pages, there is no reason to
>> make them 64-bit wide on 32-bit machines.
>>
>> Make them native words. =C2=A0Since they are signed, this leaves 31 bit =
on
>> 32-bit machines, which can represent roughly 8TB assuming a page size
>> of 4k.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
