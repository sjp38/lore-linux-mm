Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA0E6B743C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 13:11:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 77-v6so5699045qkz.5
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 10:11:54 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id c59-v6si338736qva.149.2018.09.05.10.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 10:11:53 -0700 (PDT)
Date: Wed, 5 Sep 2018 17:11:52 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
In-Reply-To: <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
Message-ID: <01000165aab80769-ad7aaedf-81ae-4bbb-a602-a2aa5d49f54e-000000@email.amazonses.com>
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com> <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com> <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On Wed, 5 Sep 2018, Laurent Dufour wrote:

> > Large page sizes also reduce contention there.
>
> That's true for the page fault path, but for process's actions manipulating the
> memory process's layout (mmap,munmap,madvise,mprotect) the impact is minimal
> unless the code has to manipulate the page tables.

Well if you compare having to operate on 4k instead of 64k then the impact
is 16xs for larger memory ranges. For smaller operations this may not be
that significant. But then I thought we were talking about large areas of
memory.
