Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC2F6B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:30:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t24-v6so15939635qtn.7
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:30:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u10-v6si369789qvm.118.2018.05.04.07.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 07:30:27 -0700 (PDT)
Date: Fri, 4 May 2018 16:30:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 0/9] trace_uprobe: Support SDT markers having
 reference count (semaphore)
Message-ID: <20180504143021.GB26151@redhat.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
 <f77789c0-9277-23bf-9abb-92f3f36c4baa@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f77789c0-9277-23bf-9abb-92f3f36c4baa@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Cc: mhiramat@kernel.org, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

Sorry Ravi, I saved the new version for review and forgot about it... I'll
try to do this on weekend.

On 05/03, Ravi Bangoria wrote:
> 
> On 04/17/2018 10:02 AM, Ravi Bangoria wrote:
> > Userspace Statically Defined Tracepoints[1] are dtrace style markers
> > inside userspace applications. Applications like PostgreSQL, MySQL,
> > Pthread, Perl, Python, Java, Ruby, Node.js, libvirt, QEMU, glib etc
> > have these markers embedded in them. These markers are added by developer
> > at important places in the code. Each marker source expands to a single
> > nop instruction in the compiled code but there may be additional
> > overhead for computing the marker arguments which expands to couple of
> > instructions. In case the overhead is more, execution of it can be
> > omitted by runtime if() condition when no one is tracing on the marker:
> >
> >     if (reference_counter > 0) {
> >         Execute marker instructions;
> >     }   
> >
> > Default value of reference counter is 0. Tracer has to increment the 
> > reference counter before tracing on a marker and decrement it when
> > done with the tracing.
> 
> Hi Oleg, Masami,
> 
> Can you please review this :) ?
> 
> Thanks.
> 
