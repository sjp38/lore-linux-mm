Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE0E6B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 03:45:46 -0400 (EDT)
Received: by wyf19 with SMTP id 19so6400002wyf.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 00:45:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110503064945.GA18927@tiehlicka.suse.cz>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
 <20110429133313.GB306@tiehlicka.suse.cz> <20110501150410.75D2.A69D9226@jp.fujitsu.com>
 <20110503064945.GA18927@tiehlicka.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 3 May 2011 16:45:23 +0900
Message-ID: <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

2011/5/3 Michal Hocko <mhocko@suse.cz>:
> On Sun 01-05-11 15:06:02, KOSAKI Motohiro wrote:
>> > On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
>> > > There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
>> > > The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
>> > > is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
>> > > until the usage is lower than the high_wmark.
>> >
>> > I have mentioned this during Ying's patchsets already, but do we really
>> > want to have this confusing naming? High and low watermarks have
>> > opposite semantic for zones.
>>
>> Can you please clarify this? I feel it is not opposite semantics.
>
> In the global reclaim low watermark represents the point when we _start_
> background reclaim while high watermark is the _stopper_. Watermarks are
> based on the free memory while this proposal makes it based on the used
> memory.
> I understand that the result is same in the end but it is really
> confusing because you have to switch your mindset from free to used and
> from under the limit to above the limit.

Ah, right. So, do you have an alternative idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
