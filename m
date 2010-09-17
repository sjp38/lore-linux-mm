Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D4386B007D
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 07:49:13 -0400 (EDT)
Received: by vws16 with SMTP id 16so1950333vws.14
        for <linux-mm@kvack.org>; Fri, 17 Sep 2010 04:49:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100917063537.GA4534@balbir.in.ibm.com>
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100916062159.GF22371@balbir.in.ibm.com>
	<20100916152204.6c457936.kamezawa.hiroyu@jp.fujitsu.com>
	<20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
	<20100917063537.GA4534@balbir.in.ibm.com>
Date: Fri, 17 Sep 2010 20:49:09 +0900
Message-ID: <AANLkTikWqPf_SfYn7fzL7ROGqCY=ZZR5mUzr7sah+TOd@mail.gmail.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2010/9/17 Balbir Singh <balbir@linux.vnet.ibm.com>:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-16 16:17:27=
]:
>
>> On Thu, 16 Sep 2010 15:22:04 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > This naming is from mem_cgroup_walk_tree(). Now we have
>> >
>> > =A0 mem_cgroup_walk_tree();
>> > =A0 mem_cgroup_walk_all();
>> >
>> > Rename both ? But it should be in separated patch.
>> >
>>
>> Considering a bit ...but..
>>
>> #define for_each_mem_cgroup(mem) \
>> =A0 =A0 =A0 for (mem =3D mem_cgroup_get_first(); \
>> =A0 =A0 =A0 =A0 =A0 =A0mem; \
>> =A0 =A0 =A0 =A0 =A0 =A0mem =3D mem_cgroup_get_next(mem);) \
>>
>> seems to need some helper functions. I'll consider about this clean up
>> but it requires some amount of patch because css_get()/css_put()/rcu...e=
tc..
>> are problematic.
>>
>
> Why does this need to be a macro (I know we use this for lists and
> other places), assuming for now we don't use the iterator pattern, we
> can rename mem_cgroup_walk_all() to for_each_mem_cgroup().
>

When I see for_each in the kernel source, I expect iterator and macro.
When I see "walk" in the kernel source, I expect callback and visit functio=
n.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
