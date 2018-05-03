Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4D36B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 04:32:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so11439533wre.23
        for <linux-mm@kvack.org>; Thu, 03 May 2018 01:32:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g53-v6si489686edb.149.2018.05.03.01.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 01:32:17 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w438VLNe037364
	for <linux-mm@kvack.org>; Thu, 3 May 2018 04:32:15 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hqxn6gv66-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 May 2018 04:32:15 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.ibm.com>;
	Thu, 3 May 2018 09:32:13 +0100
Subject: Re: [PATCH v3 0/9] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Date: Thu, 3 May 2018 14:02:00 +0530
MIME-Version: 1.0
In-Reply-To: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <f77789c0-9277-23bf-9abb-92f3f36c4baa@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com
Cc: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com


On 04/17/2018 10:02 AM, Ravi Bangoria wrote:
> Userspace Statically Defined Tracepoints[1] are dtrace style markers
> inside userspace applications. Applications like PostgreSQL, MySQL,
> Pthread, Perl, Python, Java, Ruby, Node.js, libvirt, QEMU, glib etc
> have these markers embedded in them. These markers are added by developer
> at important places in the code. Each marker source expands to a single
> nop instruction in the compiled code but there may be additional
> overhead for computing the marker arguments which expands to couple of
> instructions. In case the overhead is more, execution of it can be
> omitted by runtime if() condition when no one is tracing on the marker:
>
>     if (reference_counter > 0) {
>         Execute marker instructions;
>     }   
>
> Default value of reference counter is 0. Tracer has to increment the 
> reference counter before tracing on a marker and decrement it when
> done with the tracing.

Hi Oleg, Masami,

Can you please review this :) ?

Thanks.
