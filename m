Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 109438E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:20:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r25-v6so7374325edc.7
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:20:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18-v6si1630530edb.332.2018.09.10.10.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 10:20:23 -0700 (PDT)
Date: Mon, 10 Sep 2018 10:20:11 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
Message-ID: <20180910172011.GB3902@linux-r8p5>
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
 <55b44432-ade5-f090-bfe7-ea20f3e87285@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <55b44432-ade5-f090-bfe7-ea20f3e87285@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On Mon, 10 Sep 2018, Waiman Long wrote:

>On 09/08/2018 12:13 AM, John Hubbard wrote:
>>
>> Hi Daniel and all,
>>
>> I'm interested in the first 3 of those 4 topics, so if it doesn't conflict with HMM topics or
>> fix-gup-with-dma topics, I'd like to attend. GPUs generally need to access large chunks of
>> memory, and that includes migrating (dma-copying) pages around.
>>
>> So for example a multi-threaded migration of huge pages between normal RAM and GPU memory is an
>> intriguing direction (and I realize that it's a well-known topic, already). Doing that properly
>> (how many threads to use?) seems like it requires scheduler interaction.
>>
>> It's also interesting that there are two main huge page systems (THP and Hugetlbfs), and I sometimes
>> wonder the obvious thing to wonder: are these sufficiently different to warrant remaining separate,
>> long-term?  Yes, I realize they're quite different in some ways, but still, one wonders. :)
>
>One major difference between hugetlbfs and THP is that the former has to
>be explicitly managed by the applications that use it whereas the latter
>is done automatically without the applications being aware that THP is
>being used at all. Performance wise, THP may or may not increase
>application performance depending on the exact memory access pattern,
>though the chance is usually higher that an application will benefit
>than suffer from it.
>
>If an application know what it is doing, using hughtblfs can boost
>performance more than it can ever achieved by THP. Many large enterprise
>applications, like Oracle DB, are using hugetlbfs and explicitly disable
>THP. So unless THP can improve its performance to a level that is
>comparable to hugetlbfs, I won't see the later going away.

Yep, there are a few non-trivial workloads out there that flat out discourage
thp, ie: redis to avoid latency issues.

Thanks,
Davidlohr
