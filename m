Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F1DB86B007E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 10:27:32 -0400 (EDT)
Received: by iwn8 with SMTP id 8so3336496iwn.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 07:27:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110708084629.73c7e543.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110707155217.909c429a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110707142922.c9657ec4.akpm@linux-foundation.org>
	<20110708084629.73c7e543.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 9 Jul 2011 19:57:30 +0530
Message-ID: <CAKTCnz=tKo=769oPq+vQxykYYy36GDZL4XpuHuFGKT-LitSytQ@mail.gmail.com>
Subject: Re: [PATCH][Cleanup] memcg: consolidates memory cgroup lru stat functions
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>

>> The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes
>> uses "struct mem_cgroup *memcg". =A0That's irritating. =A0I think "memcg=
"
>> is better.
>>
>
> Sure. I always use "mem" but otheres not ;(
> Ok, I'll use memcg.

This would be a good cleanup to do. CC'ing Raghavendra who might be
interested in looking at the cleanup

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
