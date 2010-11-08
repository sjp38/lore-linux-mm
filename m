Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F37026B0087
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 17:25:37 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 1/4] memcg: use native word to represent dirtyable pages
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.115646194@cmpxchg.org>
	<AANLkTi=qO84k-KWaG2R_nQr7vxRA2E7DbO4=XhVrFzjv@mail.gmail.com>
Date: Mon, 08 Nov 2010 14:25:15 -0800
In-Reply-To: <AANLkTi=qO84k-KWaG2R_nQr7vxRA2E7DbO4=XhVrFzjv@mail.gmail.com>
	(Minchan Kim's message of "Mon, 8 Nov 2010 07:56:43 +0900")
Message-ID: <xr93aaljbghg.fsf@ninji.mtv.corp.google.com>
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
>> The memory cgroup dirty info calculation currently uses a signed
>> 64-bit type to represent the amount of dirtyable memory in pages.
>>
>> This can instead be changed to an unsigned word, which will allow the
>> formula to function correctly with up to 160G of LRU pages on a 32-bit
Is is really 160G of LRU pages?  On 32-bit machine we use a 32 bit
unsigned page number.  With a 4KiB page size, I think that maps 16TiB
(1<<(32+12)) bytes.  Or is there some other limit?
>> system, assuming 4k pages. =C2=A0That should be plenty even when taking
>> racy folding of the per-cpu counters into account.
>>
>> This fixes a compilation error on 32-bit systems as this code tries to
>> do 64-bit division.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> Reported-by: Dave Young <hidave.darkstar@gmail.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
