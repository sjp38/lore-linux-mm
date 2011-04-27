Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAB119000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:20:00 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3R1JwGY003909
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:19:58 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz33.hot.corp.google.com with ESMTP id p3R1JBXu029727
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:19:57 -0700
Received: by qwf7 with SMTP id 7so732810qwf.24
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:19:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427093422.7740aa21.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
	<20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=PuQPz4tyj4M3bc--asanZd525cA@mail.gmail.com>
	<20110427093422.7740aa21.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 18:19:57 -0700
Message-ID: <BANLkTi=jV7NN5AtM2WgJnZEeybGUJJqK-A@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, Apr 26, 2011 at 5:34 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 Apr 2011 16:08:38 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAWA Hiroyuki <
>> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > BTW, I think it's better to avoid the watermark reclaim work as kswapd.
>> > It's confusing because we've talked about global reclaim at LSF.
>> >
>>
>> Can you clarify that?
>>
>
> Maybe I should write "it's better to avoid calling watermark work as kswapd"
>
> Many guys talk about soft-limit and removing LRU at talking about kswapd or
> bacground reclaim ;)

Ok, thanks :)

--Ying
>
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
