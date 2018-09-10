Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6F398E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:34:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x5-v6so1279882ioa.6
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:34:23 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o3-v6si12411933iod.5.2018.09.10.10.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 10:34:23 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
 <55b44432-ade5-f090-bfe7-ea20f3e87285@redhat.com>
 <20180910172011.GB3902@linux-r8p5>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <78fa0507-4789-415b-5b9c-18e3fcefebab@nvidia.com>
Date: Mon, 10 Sep 2018 10:34:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180910172011.GB3902@linux-r8p5>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 9/10/18 10:20 AM, Davidlohr Bueso wrote:
> On Mon, 10 Sep 2018, Waiman Long wrote:
>> On 09/08/2018 12:13 AM, John Hubbard wrote:
[...]
>>> It's also interesting that there are two main huge page systems (THP an=
d Hugetlbfs), and I sometimes
>>> wonder the obvious thing to wonder: are these sufficiently different to=
 warrant remaining separate,
>>> long-term?=C2=A0 Yes, I realize they're quite different in some ways, b=
ut still, one wonders. :)
>>
>> One major difference between hugetlbfs and THP is that the former has to
>> be explicitly managed by the applications that use it whereas the latter
>> is done automatically without the applications being aware that THP is
>> being used at all. Performance wise, THP may or may not increase
>> application performance depending on the exact memory access pattern,
>> though the chance is usually higher that an application will benefit
>> than suffer from it.
>>
>> If an application know what it is doing, using hughtblfs can boost
>> performance more than it can ever achieved by THP. Many large enterprise
>> applications, like Oracle DB, are using hugetlbfs and explicitly disable
>> THP. So unless THP can improve its performance to a level that is
>> comparable to hugetlbfs, I won't see the later going away.
>=20
> Yep, there are a few non-trivial workloads out there that flat out discou=
rage
> thp, ie: redis to avoid latency issues.
>=20

Yes, the need for guaranteed, available-now huge pages in some cases is=20
understood. That's not the quite same as saying that there have to be two d=
ifferent
subsystems, though. Nor does it even necessarily imply that the pool has to=
 be
reserved in the same way as hugetlbfs does it...exactly.

So I'm wondering if THP behavior can be made to mimic hugetlbfs enough (per=
haps
another option, in addition to "always, never, madvise") that we could just=
 use
THP in all cases. But the "transparent" could become a sliding scale that c=
ould
go all the way down to "opaque" (hugetlbfs behavior).


thanks,
--=20
John Hubbard
NVIDIA
