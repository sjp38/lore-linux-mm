Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E454E6B004A
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 11:29:02 -0400 (EDT)
Received: by vws16 with SMTP id 16so6277787vws.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 08:28:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913084741.GD17950@balbir.in.ibm.com>
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913084741.GD17950@balbir.in.ibm.com>
Date: Tue, 14 Sep 2010 00:28:30 +0900
Message-ID: <AANLkTimsUQuEeS2QvSwY_WhnQY7n=D73fNmOoqgrTqbZ@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag management
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

2010/9/13 Balbir Singh <balbir@linux.vnet.ibm.com>:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-13 16:08:22=
]:
>
>>
>> I think this small race is not very critical but it's bug.
>> We have this race since 2.6.34.
>> =3D
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Now. memory cgroup accounts file-mapped by counter and flag.
>> counter is working in the same way with zone_stat but FileMapped flag on=
ly
>> exists in memcg (for helping move_account).
>>
>> This flag can be updated wrongly in a case. Assume CPU0 and CPU1
>> and a thread mapping a page on CPU0, another thread unmapping it on CPU1=
