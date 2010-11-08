Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 321266B0085
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 17:29:06 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 2/4] memcg: catch negative per-cpu sums in dirty info
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.414283590@cmpxchg.org>
	<AANLkTik4GfMEpE7HaXe93YSy-cTGKjDW1TgKYtOC2wos@mail.gmail.com>
Date: Mon, 08 Nov 2010 14:28:46 -0800
In-Reply-To: <AANLkTik4GfMEpE7HaXe93YSy-cTGKjDW1TgKYtOC2wos@mail.gmail.com>
	(Minchan Kim's message of "Mon, 8 Nov 2010 08:26:29 +0900")
Message-ID: <xr9362w7bgbl.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Minchan Kim <minchan.kim@gmail.com> writes:

> On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> Folding the per-cpu counters can yield a negative value in case of
>> accounting races between CPUs.
>>
>> When collecting the dirty info, the code would read those sums into an
>> unsigned variable and then check for it being negative, which can not
>> work.
>>
>> Instead, fold the counters into a signed local variable, make the
>> check, and only then assign it.
>>
>> This way, the function signals correctly when there are insane values
>> instead of leaking them out to the caller.
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
