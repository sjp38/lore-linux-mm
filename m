Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E5F575F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 07:33:37 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so210400yxh.26
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 04:34:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0904190159t2898edfal858ba12d3460c4e5@mail.gmail.com>
References: <20090418152100.125A.A69D9226@jp.fujitsu.com>
	 <20090418184337.GA5556@cmpxchg.org>
	 <2f11576a0904190159t2898edfal858ba12d3460c4e5@mail.gmail.com>
Date: Sun, 19 Apr 2009 20:34:08 +0900
Message-ID: <2f11576a0904190434y1f897a57qeb22e478dd4d43bd@mail.gmail.com>
Subject: Re: [PATCH for mmotm 0414] vmscan,memcg: reintroduce sc->may_swap
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2009/4/19 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> Hi
>
> Hi
>
>>> @@ -1724,6 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pag
>>> =A0 =A0 =A0 struct scan_control sc =3D {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swap_cluster_max =3D SWAP_CLUSTER_MAX,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D swappiness,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
>>> @@ -1734,7 +1739,7 @@ unsigned long try_to_free_mem_cgroup_pag
>>> =A0 =A0 =A0 struct zonelist *zonelist;
>>>
>>> =A0 =A0 =A0 if (noswap)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 sc.may_unmap =3D 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.may_swap =3D 0;
>>
>> Can this be directly initialized?
>>
>> struct scan_control sc =3D {
>> =A0 =A0 =A0 =A0...
>> =A0 =A0 =A0 =A0.may_swap =3D !noswap,
>> =A0 =A0 =A0 =A0...
>> };
>
> your proposal is better coding style. but I also prefer condig style
> consistency.
> I think we should change may_unmap and may_swap at the same time.
> Thus, I'd like to does it by another patch.

Grr, I've misunderstood your comment.
Will fix as your suggestion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
