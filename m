Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E66916B7584
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 19:01:22 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w6-v6so8054591wrc.22
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 16:01:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q18-v6si3320524wrg.14.2018.09.05.16.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 16:01:21 -0700 (PDT)
Date: Thu, 6 Sep 2018 01:01:09 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
In-Reply-To: <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.21.1809060059390.1416@nanos.tec.linutronix.de>
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com> <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com> <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Lameter <cl@linux.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On Wed, 5 Sep 2018, Laurent Dufour wrote:
> On 05/09/2018 17:10, Christopher Lameter wrote:
> > Large page sizes also reduce contention there.
> 
> That's true for the page fault path, but for process's actions manipulating the
> memory process's layout (mmap,munmap,madvise,mprotect) the impact is minimal
> unless the code has to manipulate the page tables.

And how exactly are you going to do any of those operations _without_
manipulating the page tables?

Thanks,

	tglx
