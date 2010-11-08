Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 33EBA6B00A5
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 18:20:55 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 3/4] memcg: break out event counters from other stats
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.684449249@cmpxchg.org>
	<AANLkTikhX+2E5o=vqc6Yb6GGPJJT2FwuzKMiC31GdY0s@mail.gmail.com>
Date: Mon, 08 Nov 2010 15:20:38 -0800
Message-ID: <xr93hbfr9zcp.fsf@ninji.mtv.corp.google.com>
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
>> For increasing and decreasing per-cpu cgroup usage counters it makes
>> sense to use signed types, as single per-cpu values might go negative
>> during updates. =C2=A0But this is not the case for only-ever-increasing
>> event counters.
>>
>> All the counters have been signed 64-bit so far, which was enough to
>> count events even with the sign bit wasted.
>>
>> The next patch narrows the usage counters type (on 32-bit CPUs, that
>> is), though, so break out the event counters and make them unsigned
>> words as they should have been from the start.
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
