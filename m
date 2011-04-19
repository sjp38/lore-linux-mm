Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D51C900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 22:48:47 -0400 (EDT)
Received: by pzk32 with SMTP id 32so3731821pzk.14
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 19:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=HotRcWiRc4qa1aN+NJ4H5vfCWWA@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
 <20110415094040.GC8828@tiehlicka.suse.cz> <BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
 <20110418091351.GC8925@tiehlicka.suse.cz> <BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
 <20110418184240.GA11653@tiehlicka.suse.cz> <BANLkTi=HotRcWiRc4qa1aN+NJ4H5vfCWWA@mail.gmail.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Tue, 19 Apr 2011 10:48:25 +0800
Message-ID: <BANLkTi=CeBGF63gDj=jvWyXs3OjjkTsEpg@mail.gmail.com>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

Hi,

2011/4/19 Ying Han <yinghan@google.com>:
>
> that is true. =C2=A0I adopt the initial comment from Mel where we keep th=
e same
> logic of triggering and stopping kswapd with low/high_wmarks and also
> comparing the usage_in_bytes to the wmarks.=C2=A0Either way is confusing =
and
> guess we just need to document it well.

IMO another thing need to document well is that a user must setup
high_wmark_distance before setup low_wmark_distance to to make it
start work, and zero  low_wmark_distance before zero
high_wmark_distance to stop it. Otherwise it won't pass the sanity
check, which is not quite obvious.

Thanks,
Zhu Yanhai

> --Ying
>>
>> --
>> Michal Hocko
>> SUSE Labs
>> SUSE LINUX s.r.o.
>> Lihovarska 1060/12
>> 190 00 Praha 9
>> Czech Republic
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
