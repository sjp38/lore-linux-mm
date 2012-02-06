Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E29836B13F3
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 15:02:23 -0500 (EST)
Received: by qadz32 with SMTP id z32so2555467qad.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 12:02:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120206104856.e56680a2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203113822.19cf6fd2.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4ixtGPwDxsd8vnW=ErSh7zaVgO6m=6C7wxk2xmK69QnURQ@mail.gmail.com>
	<20120206104856.e56680a2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 6 Feb 2012 12:02:22 -0800
Message-ID: <CALWz4izDB=ctQkuhqM_aSPo2M1kJ=PPFDjEY25EzRmKPF8vX+A@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Sun, Feb 5, 2012 at 5:48 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 3 Feb 2012 12:03:38 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> On Thu, Feb 2, 2012 at 6:38 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, =A02 Feb 2012 17:37:13 -0800
>> > Ying Han <yinghan@google.com> wrote:
>
>> >
>> > Do you want to do memory locking by setting swap_limit=3D0 ?
>>
>> hmm, not sure what do you mean here?
>>
>
> Do you want to add memory.swap.limit_in_bytes file for limitting swap
> and do memrory.swap.limit_in_bytes =3D 0
> for guaranteeing any anon pages will never be swapped-out ?

That's not what I was thinking. But I am quite curious what's our
decision making of not going there at the first place? I won't be
surprised to see objections of setting swap as separate limit, but
didn't find the pointer online yet.

Thanks

--Ying
>
>
>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
