Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDB48E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 00:13:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63-v6so26887526ite.2
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 21:13:11 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j18-v6si5995034ioa.193.2018.09.07.21.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 21:13:10 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
Date: Fri, 7 Sep 2018 21:13:01 -0700
MIME-Version: 1.0
In-Reply-To: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven
 Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 9/4/18 2:28 PM, Daniel Jordan wrote:
> Pavel Tatashin, Ying Huang, and I are excited to be organizing a performa=
nce and scalability microconference this year at Plumbers[*], which is happ=
ening in Vancouver this year.=C2=A0 The microconference is scheduled for th=
e morning of the second day (Wed, Nov 14).
>=20
> We have a preliminary agenda and a list of confirmed and interested atten=
dees (cc'ed), and are seeking more of both!
>=20
> Some of the items on the agenda as it stands now are:
>=20
> =C2=A0- Promoting huge page usage:=C2=A0 With memory sizes becoming ever =
larger, huge pages are becoming more and more important to reduce TLB misse=
s and the overhead of memory management itself--that is, to make the system=
 scalable with the memory size.=C2=A0 But there are still some remaining ga=
ps that prevent huge pages from being deployed in some situations, such as =
huge page allocation latency and memory fragmentation.
>=20
> =C2=A0- Reducing the number of users of mmap_sem:=C2=A0 This semaphore is=
 frequently used throughout the kernel.=C2=A0 In order to facilitate scalin=
g this longstanding bottleneck, these uses should be documented and unneces=
sary users should be fixed.
>=20
> =C2=A0- Parallelizing cpu-intensive kernel work:=C2=A0 Resolve problems o=
f past approaches including extra threads interfering with other processes,=
 playing well with power management, and proper cgroup accounting for the e=
xtra threads.=C2=A0 Bonus topic: proper accounting of workqueue threads run=
ning on behalf of cgroups.
>=20
> =C2=A0- Preserving userland during kexec with a hibernation-like mechanis=
m.
>=20
> These center around our interests, but having lots of topics to choose fr=
om ensures we cover what's most important to the community, so we would lik=
e to hear about additional topics and extensions to those listed here.=C2=
=A0 This includes, but is certainly not limited to, work in progress that w=
ould benefit from in-person discussion, real-world performance problems, an=
d experimental and academic work.
>=20
> If you haven't already done so, please let us know if you are interested =
in attending, or have suggestions for other attendees.

Hi Daniel and all,

I'm interested in the first 3 of those 4 topics, so if it doesn't conflict =
with HMM topics or
fix-gup-with-dma topics, I'd like to attend. GPUs generally need to access =
large chunks of
memory, and that includes migrating (dma-copying) pages around. =20

So for example a multi-threaded migration of huge pages between normal RAM =
and GPU memory is an=20
intriguing direction (and I realize that it's a well-known topic, already).=
 Doing that properly
(how many threads to use?) seems like it requires scheduler interaction.

It's also interesting that there are two main huge page systems (THP and Hu=
getlbfs), and I sometimes
wonder the obvious thing to wonder: are these sufficiently different to war=
rant remaining separate,
long-term?  Yes, I realize they're quite different in some ways, but still,=
 one wonders. :)


thanks,
--=20
John Hubbard
NVIDIA
