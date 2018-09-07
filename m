Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5AD96B7BA8
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 20:53:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v1-v6so8705437wmh.4
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 17:53:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j12-v6sor4682843wrt.26.2018.09.06.17.53.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 17:53:20 -0700 (PDT)
MIME-Version: 1.0
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
 <877ejzqtdy.fsf@yhuang-dev.intel.com> <bd6f6f8b-4880-6c20-62f5-bb6ca3b5e6f7@oracle.com>
In-Reply-To: <bd6f6f8b-4880-6c20-62f5-bb6ca3b5e6f7@oracle.com>
From: Hugh Dickins <hughd@google.com>
Date: Thu, 6 Sep 2018 17:52:53 -0700
Message-ID: <CANsGZ6bW0vJcRpnfAesH-9_9vnrrvMHYH-UjH50zqLtA4WALyg@mail.gmail.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Christoph Lameter <cl@linux.com>, daniel.m.jordan@oracle.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, aaron.lu@intel.com, alex.kogan@oracle.com, Andrew Morton <akpm@linux-foundation.org>, boqun.feng@gmail.com, brouer@redhat.com, Davidlohr Bueso <dave@stgolabs.net>, dave.dice@oracle.com, dhaval.giani@oracle.com, ktkhai@virtuozzo.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Pavel.Tatashin@microsoft.com, Paul McKenney <paulmck@linux.vnet.ibm.com>, shady.issa@oracle.com, tariqt@mellanox.com, Thomas Gleixner <tglx@linutronix.de>, Tim Chen <tim.c.chen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, longman@redhat.com, Yang Shi <yang.shi@linux.alibaba.com>, shy828301@gmail.com, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, Jonathan Adams <jwadams@google.com>, Ashwin Chaugule <ashwinch@google.com>, Salman Qazi <sqazi@google.com>, Shakeel Butt <shakeelb@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Junaid Shahid <junaids@google.com>, Neha Agarwal <nehaagarwal@google.com>, Greg Thelen <gthelen@google.com>

On Thu, Sep 6, 2018 at 2:36 PM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> On 09/05/2018 06:58 PM, Huang, Ying wrote:
> > Hi, Christopher,
> >
> > Christopher Lameter <cl@linux.com> writes:
> >
> >> On Tue, 4 Sep 2018, Daniel Jordan wrote:
> >>
> >>>  - Promoting huge page usage:  With memory sizes becoming ever larger, huge
> >>> pages are becoming more and more important to reduce TLB misses and the
> >>> overhead of memory management itself--that is, to make the system scalable
> >>> with the memory size.  But there are still some remaining gaps that prevent
> >>> huge pages from being deployed in some situations, such as huge page
> >>> allocation latency and memory fragmentation.
> >>
> >> You forgot the major issue that huge pages in the page cache are not
> >> supported and thus we have performance issues with fast NVME drives that
> >> are now able to do 3Gbytes per sec that are only possible to reach with
> >> directio and huge pages.
> >
> > Yes.  That is an important gap for huge page.  Although we have huge
> > page cache support for tmpfs, we lacks that for normal file systems.
> >
> >> IMHO the huge page issue is just the reflection of a certain hardware
> >> manufacturer inflicting pain for over a decade on its poor users by not
> >> supporting larger base page sizes than 4k. No such workarounds needed on
> >> platforms that support large sizes. Things just zoom along without
> >> contortions necessary to deal with huge pages etc.
> >>
> >> Can we come up with a 2M base page VM or something? We have possible
> >> memory sizes of a couple TB now. That should give us a million or so 2M
> >> pages to work with.
> >
> > That sounds a good idea.  Don't know whether someone has tried this.
>
> IIRC, Hugh Dickins and some others at Google tried going down this path.
> There was a brief discussion at LSF/MM.  It is something I too would like
> to explore in my spare time.

Almost: I never tried that path myself, but mentioned that Greg Thelen had.

Hugh
