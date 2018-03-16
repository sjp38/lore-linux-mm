Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D10576B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 07:39:26 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q19so4385817qta.17
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:39:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p1si4594035qkh.45.2018.03.16.04.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 04:39:25 -0700 (PDT)
Date: Fri, 16 Mar 2018 12:39:18 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-ID: <20180316113917.GA21303@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180315142120.GA19218@redhat.com>
 <20180315143044.GA19643@redhat.com>
 <3b303a2d-35dd-9178-fc03-de9f2d588797@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b303a2d-35dd-9178-fc03-de9f2d588797@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/16, Ravi Bangoria wrote:
>
> On 03/15/2018 08:00 PM, Oleg Nesterov wrote:
> > Note to mention that sdt_find_vma() can return NULL but the callers do
> > vma_offset_to_vaddr(vma) without any check.
>
> If the "mm" we are passing to sdt_find_vma() is returned by
> uprobe_build_map_info(ref_ctr_offset), sdt_find_vma() must
> _not_ return NULL.

Not at all.

Once build_map_info() returns any mapping can go away. Otherwise, why do
you think the caller has to take ->mmap_sem and use find_vma()? If you
were right, build_map_info() could just return the list of vma's instead
of list of mm's.

Oleg.
