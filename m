Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A71906B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 20:26:50 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2383845qwa.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 17:26:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110809090455.92901845.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110808110658.31053.55013.stgit@localhost6>
	<20110808110659.31053.92935.stgit@localhost6>
	<CAEwNFnBojMWL1QRfn_buhwUwMOBRGSUGdWBgmzdt9vsCVmLFmQ@mail.gmail.com>
	<20110809090455.92901845.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 9 Aug 2011 09:26:47 +0900
Message-ID: <CAEwNFnDKsCFWFshHxUkfc3dBTF=0-0eH2ZunyRYt2tcxW72KuA@mail.gmail.com>
Subject: Re: [PATCH 2/2] vmscan: activate executable pages after first usage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi, Kame.

On Tue, Aug 9, 2011 at 9:04 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 9 Aug 2011 09:02:28 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Mon, Aug 8, 2011 at 8:07 PM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org> wrote:
>> > Logic added in commit v2.6.30-5507-g8cab475
>> > (vmscan: make mapped executable pages the first class citizen)
>> > was noticeably weakened in commit v2.6.33-5448-g6457474
>> > (vmscan: detect mapped file pages used only once)
>> >
>> > Currently these pages can become "first class citizens" only after second usage.
>> >
>> > After this patch page_check_references() will activate they after first usage,
>> > and executable code gets yet better chance to stay in memory.
>> >
>> > TODO:
>> > run some cool tests like in v2.6.30-5507-g8cab475 =)
>> >
>> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
>> > ---
>>
>> It might be a very controversial topic.
>> AFAIR, at least, we did when vmscan: make mapped executable pages the
>> first class citizen was merged. :)
>>
>> You try to change behavior.
>>
>> Old : protect *working set* executable page
>> New: protect executable page *unconditionally*.
>>
>
> Hmm ? I thought
> Old: protect pages if referenced twice
> New: protect executable page if referenced once.
>
> IIUC, ANON is proteced if it's referenced once.
>
> So, this patch changes EXECUTABLE file to the same class as ANON pages.

"Working set" means two reference in implementation of the moment. But
it can change in future as many as we want.

"Unconditionally" means that all of mapped page starts from referenced
pte so it would activate all of executable pages.

>
> Anyway, I agree test/measurement is required.

Absolutely.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
