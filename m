Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0FCEF6B007D
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:41:40 -0500 (EST)
Received: by pwj10 with SMTP id 10so1010304pwj.6
        for <linux-mm@kvack.org>; Fri, 22 Jan 2010 07:41:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ea36dc1ede8240f85a69215be964c61a.squirrel@webmail-b.css.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	 <1264168844.2789.4.camel@barrios-desktop>
	 <ea36dc1ede8240f85a69215be964c61a.squirrel@webmail-b.css.fujitsu.com>
Date: Sat, 23 Jan 2010 00:41:39 +0900
Message-ID: <28c262361001220741n426c52a3t371aeabe89c154c7@mail.gmail.com>
Subject: Re: [PATCH v2] oom-kill: add lowmem usage aware oom kill handling
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

2010/1/23 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> <snip>
>>> @@ -475,7 +511,7 @@ void mem_cgroup_out_of_memory(struct mem
>>>
>>> =C2=A0 =C2=A0 =C2=A0read_lock(&tasklist_lock);
>>> =C2=A0retry:
>>> - =C2=A0 =C2=A0p =3D select_bad_process(&points, mem);
>>> + =C2=A0 =C2=A0p =3D select_bad_process(&points, mem, CONSTRAINT_NONE);
>>
>> Why do you fix this with only CONSTRAINT_NONE?
>> I think we can know CONSTRAINT_LOWMEM with gfp_mask in here.
>>
> memcg is just for accounting anon/file pages. Then, it's never
> cause lowmem oom problem (any memory is ok for memcg).

Okay. Thanks for the explanation.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
