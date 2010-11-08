Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B799E6B0093
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 17:43:36 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oA8MhWEm007927
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 14:43:33 -0800
Received: from vws20 (vws20.prod.google.com [10.241.21.148])
	by wpaz37.hot.corp.google.com with ESMTP id oA8MhCKw018167
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 14:43:31 -0800
Received: by vws20 with SMTP id 20so623298vws.39
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 14:43:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101108223838.GM23393@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
 <20101106010357.GD23393@cmpxchg.org> <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
 <20101107215030.007259800@cmpxchg.org> <20101107220353.115646194@cmpxchg.org>
 <AANLkTi=qO84k-KWaG2R_nQr7vxRA2E7DbO4=XhVrFzjv@mail.gmail.com>
 <xr93aaljbghg.fsf@ninji.mtv.corp.google.com> <20101108223838.GM23393@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 8 Nov 2010 14:43:11 -0800
Message-ID: <AANLkTin_XH2dTOVrtuegVzNkupAVbwMhMFpsAPJMimo7@mail.gmail.com>
Subject: Re: [patch 1/4] memcg: use native word to represent dirtyable pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 2:38 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Mon, Nov 08, 2010 at 02:25:15PM -0800, Greg Thelen wrote:
>> Minchan Kim <minchan.kim@gmail.com> writes:
>>
>> > On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> w=
rote:
>> >> The memory cgroup dirty info calculation currently uses a signed
>> >> 64-bit type to represent the amount of dirtyable memory in pages.
>> >>
>> >> This can instead be changed to an unsigned word, which will allow the
>> >> formula to function correctly with up to 160G of LRU pages on a 32-bi=
t
>> Is is really 160G of LRU pages? =A0On 32-bit machine we use a 32 bit
>> unsigned page number. =A0With a 4KiB page size, I think that maps 16TiB
>> (1<<(32+12)) bytes. =A0Or is there some other limit?
>
> Yes, the dirty limit we calculate from it :)
>
> We have to be able to multiply this number by up to 100 (maximum dirty
> ratio value) without overflowing.

Duh :)   thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
