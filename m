Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43FA9900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 19:58:00 -0400 (EDT)
Received: by bwz17 with SMTP id 17so5094377bwz.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 16:57:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520144919.57541b8d.akpm@linux-foundation.org>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124212.facdc595.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520144919.57541b8d.akpm@linux-foundation.org>
Date: Sat, 21 May 2011 08:57:57 +0900
Message-ID: <BANLkTikeEw4WNutzBs5bVnrmUs23dfVPug@mail.gmail.com>
Subject: Re: [PATCH 2/8] memcg: easy check routine for reclaimable
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 20 May 2011 12:42:12 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> +bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg)
>> +{
>> + =A0 =A0 unsigned long nr;
>> + =A0 =A0 int zid;
>> +
>> + =A0 =A0 for (zid =3D NODE_DATA(0)->nr_zones - 1; zid >=3D 0; zid--)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_zone_reclaimable_pages(memcg, 0=
, zid))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 if (zid < 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> + =A0 =A0 return true;
>> +}
>
> A wee bit of documentation would be nice.

Yes, I'll add some.

> =A0Perhaps improving the name
> would suffice: mem_cgroup_has_reclaimable().
>
ok, I will use that name.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
