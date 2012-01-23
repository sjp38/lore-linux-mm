Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 7B2F26B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 06:53:47 -0500 (EST)
Received: by wicr5 with SMTP id r5so2610066wic.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 03:53:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120123112022.GB1707@cmpxchg.org>
References: <CAJd=RBC8dCGgqXqP+yjW2+pVoSeFXwXfjx8DLHhMuY8goOadZw@mail.gmail.com>
	<CAJd=RBBqp3bMGwFc14BJ7+=KsfO0gLnrnXwbRdLDYOJDdvbptA@mail.gmail.com>
	<20120123112022.GB1707@cmpxchg.org>
Date: Mon, 23 Jan 2012 19:53:45 +0800
Message-ID: <CAJd=RBDEGDZkCTC_rwE9jWRBJuWDdncoQ55fip9TYukqqUFoNw@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of zone
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 7:20 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Jan 23, 2012 at 12:47:34AM +0800, Hillf Danton wrote:
>> Hi all
>>
>> For easy review, it is re-prepared based on 3.3-rc1.
>>
>> Thanks
>> Hillf
>>
>> =3D=3D=3Dcut please=3D=3D=3D
>> From: Hillf Danton <dhillf@gmail.com>
>> Subject: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of=
 zone
>>
>> While iterating over memory cgroup hierarchy, pages are reclaimed from e=
ach
>> mem cgroup, and reclaim terminates after a full round-trip. It is possib=
le
>> that no pages on the lru lists of given zone are reclaimed, as terminati=
on
>> is checked after the reclaiming function.
>>
>> Mem cgroup iteration is rearranged a bit to make sure that pages are rec=
laimed
>> from both mem cgroups and zone.
>
> It's not only possible, it's guaranteed: with the memory controller
> enabled, the global per-zone lru lists are empty.
>
> Pages used to be linked on the global per-zone AND the memcg per-zone
> lru lists. =C2=A0Nowadays, they only sit on the memcg per-zone lists, whi=
ch
> is why global reclaim does a hierarchy walk.
>

Thanks for getting me up to date 8-)
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
