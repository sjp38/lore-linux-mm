Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A79D16B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:47:59 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w19-v6so1098236plq.2
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:47:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n20si3373019pgc.508.2018.03.15.05.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 05:47:58 -0700 (PDT)
Date: Thu, 15 Mar 2018 21:47:50 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
Message-Id: <20180315214750.fc1d53d01045d8e6c1e8e491@kernel.org>
In-Reply-To: <ec9c4ef7-0117-7c7c-64bc-f6bf4261721d@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
	<20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
	<ec9c4ef7-0117-7c7c-64bc-f6bf4261721d@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

Hi Ravi,

On Wed, 14 Mar 2018 20:52:59 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> On 03/14/2018 07:20 PM, Masami Hiramatsu wrote:
> > On Tue, 13 Mar 2018 18:26:03 +0530
> > Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
> >
> >> No functionality changes.
> > Please consider to describe what is this change and why, here.
> 
> Will add in next version.

Thanks, and could you also move this before perf-probe patch?
Also Could you make perf-probe check the tracing/README whether
the kernel supports reference counter syntax or not?

perf-tool can be used on older (or stable) kernel.

Thank you,

> 
> >> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
> >> ---
> >>  Documentation/trace/uprobetracer.txt | 16 +++++++++++++---
> >>  kernel/trace/trace.c                 |  2 +-
> >>  2 files changed, 14 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/Documentation/trace/uprobetracer.txt b/Documentation/trace/uprobetracer.txt
> >> index bf526a7c..8fb13b0 100644
> >> --- a/Documentation/trace/uprobetracer.txt
> >> +++ b/Documentation/trace/uprobetracer.txt
> >> @@ -19,15 +19,25 @@ user to calculate the offset of the probepoint in the object.
> >>  
> >>  Synopsis of uprobe_tracer
> >>  -------------------------
> >> -  p[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a uprobe
> >> -  r[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a return uprobe (uretprobe)
> >> -  -:[GRP/]EVENT                           : Clear uprobe or uretprobe event
> >> +  p[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
> >> +  r[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
> > Ah, OK in this context, [] means optional syntax :)
> 
> Correct.
> 
> Thanks,
> Ravi
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
