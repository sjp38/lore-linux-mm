Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87C4A8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:09:42 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f34-v6so21980099qtk.16
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:09:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q54-v6si5405492qtc.380.2018.09.10.10.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 10:09:41 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <55b44432-ade5-f090-bfe7-ea20f3e87285@redhat.com>
Date: Mon, 10 Sep 2018 13:09:36 -0400
MIME-Version: 1.0
In-Reply-To: <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 09/08/2018 12:13 AM, John Hubbard wrote:
>
> Hi Daniel and all,
>
> I'm interested in the first 3 of those 4 topics, so if it doesn't confl=
ict with HMM topics or
> fix-gup-with-dma topics, I'd like to attend. GPUs generally need to acc=
ess large chunks of
> memory, and that includes migrating (dma-copying) pages around. =20
>
> So for example a multi-threaded migration of huge pages between normal =
RAM and GPU memory is an=20
> intriguing direction (and I realize that it's a well-known topic, alrea=
dy). Doing that properly
> (how many threads to use?) seems like it requires scheduler interaction=
=2E
>
> It's also interesting that there are two main huge page systems (THP an=
d Hugetlbfs), and I sometimes
> wonder the obvious thing to wonder: are these sufficiently different to=
 warrant remaining separate,
> long-term?  Yes, I realize they're quite different in some ways, but st=
ill, one wonders. :)

One major difference between hugetlbfs and THP is that the former has to
be explicitly managed by the applications that use it whereas the latter
is done automatically without the applications being aware that THP is
being used at all. Performance wise, THP may or may not increase
application performance depending on the exact memory access pattern,
though the chance is usually higher that an application will benefit
than suffer from it.

If an application know what it is doing, using hughtblfs can boost
performance more than it can ever achieved by THP. Many large enterprise
applications, like Oracle DB, are using hugetlbfs and explicitly disable
THP. So unless THP can improve its performance to a level that is
comparable to hugetlbfs, I won't see the later going away.

Cheers,
Longman
