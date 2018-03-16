Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3C486B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 10:27:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x6so5209616pfx.16
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 07:27:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t9-v6si6427581plz.161.2018.03.16.07.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 07:27:07 -0700 (PDT)
Date: Fri, 16 Mar 2018 23:26:59 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
Message-Id: <20180316232659.4a9a31eac46c6b30105d2bce@kernel.org>
In-Reply-To: <e991f9e2-6488-7739-548d-6ca28c57826d@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
	<20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
	<ec9c4ef7-0117-7c7c-64bc-f6bf4261721d@linux.vnet.ibm.com>
	<20180315214750.fc1d53d01045d8e6c1e8e491@kernel.org>
	<e991f9e2-6488-7739-548d-6ca28c57826d@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Fri, 16 Mar 2018 15:12:38 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> On 03/15/2018 06:17 PM, Masami Hiramatsu wrote:
> > Hi Ravi,
> >
> > On Wed, 14 Mar 2018 20:52:59 +0530
> > Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
> >
> >> On 03/14/2018 07:20 PM, Masami Hiramatsu wrote:
> >>> On Tue, 13 Mar 2018 18:26:03 +0530
> >>> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
> >>>
> >>>> No functionality changes.
> >>> Please consider to describe what is this change and why, here.
> >> Will add in next version.
> > Thanks, and could you also move this before perf-probe patch?
> > Also Could you make perf-probe check the tracing/README whether
> > the kernel supports reference counter syntax or not?
> >
> > perf-tool can be used on older (or stable) kernel.
> 
> Sure, Will do that.

Please see scan_ftrace_readme@util/probe-file.c :)
It is easy to expand the pattern table.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
