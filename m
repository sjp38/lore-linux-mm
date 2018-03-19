Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 254C66B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 09:41:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h89so6166694qtd.18
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 06:41:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g6si68200qto.11.2018.03.19.06.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 06:40:58 -0700 (PDT)
Date: Mon, 19 Mar 2018 14:40:51 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
Message-ID: <20180319134050.GA12554@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180315144959.GB19643@redhat.com>
 <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
 <20180316175030.GA28770@redhat.com>
 <4b337afd-fc5e-6110-888b-d4fa36a797ee@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b337afd-fc5e-6110-888b-d4fa36a797ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

Hi Ravi,

On 03/19, Ravi Bangoria wrote:
>
> On 03/16/2018 11:20 PM, Oleg Nesterov wrote:
> >
> > And it seems that you are trying to confuse yourself, not only me ;) Just
> > suppose that an application does mmap+munmap in a loop and the mapped region
> > contains uprobe but not the counter.
>
> this is fine because ...

Yes, I guess I tried to say "counter but not uprobe" but possibly I was actually
confused.

> Our initial design was to increment counter in install_breakpoint() but
> uprobed instruction gets patched in a very early stage of binary loading
> and vma that holds the counter may not be mapped yet.

Yes, yes, I understand this is not that simple...

> > Btw, why do we need a counter, not a boolean? Who else can modify it?
> > Or different uprobes can share the same counter?
>
> Yes, multiple SDT markers can share the counter.

OK, thanks.

Oleg.
