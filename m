Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97A9F6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 07:47:38 -0400 (EDT)
Received: by vws16 with SMTP id 16so1948826vws.14
        for <linux-mm@kvack.org>; Fri, 17 Sep 2010 04:47:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100916131432.049118bd.akpm@linux-foundation.org>
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100916131432.049118bd.akpm@linux-foundation.org>
Date: Fri, 17 Sep 2010 20:47:36 +0900
Message-ID: <AANLkTinz9=i+wYzBFf0iu_m_C=+t72iiyELoivigxYkH@mail.gmail.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

2010/9/17 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 16 Sep 2010 14:46:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> This is onto The mm-of-the-moment snapshot 2010-09-15-16-21.
>>
>> =3D=3D
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Now, memory cgroup uses for_each_possible_cpu() for percpu stat handling=
