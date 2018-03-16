Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0A36B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:40:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a3so514979wme.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 02:40:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c62si1186626edf.457.2018.03.16.02.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 02:40:32 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2G9TBib099358
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:40:31 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gr9fkmvcu-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:40:31 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 09:40:28 -0000
Subject: Re: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
 <20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
 <ec9c4ef7-0117-7c7c-64bc-f6bf4261721d@linux.vnet.ibm.com>
 <20180315214750.fc1d53d01045d8e6c1e8e491@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Fri, 16 Mar 2018 15:12:38 +0530
MIME-Version: 1.0
In-Reply-To: <20180315214750.fc1d53d01045d8e6c1e8e491@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <e991f9e2-6488-7739-548d-6ca28c57826d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/15/2018 06:17 PM, Masami Hiramatsu wrote:
> Hi Ravi,
>
> On Wed, 14 Mar 2018 20:52:59 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> On 03/14/2018 07:20 PM, Masami Hiramatsu wrote:
>>> On Tue, 13 Mar 2018 18:26:03 +0530
>>> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>>>
>>>> No functionality changes.
>>> Please consider to describe what is this change and why, here.
>> Will add in next version.
> Thanks, and could you also move this before perf-probe patch?
> Also Could you make perf-probe check the tracing/README whether
> the kernel supports reference counter syntax or not?
>
> perf-tool can be used on older (or stable) kernel.

Sure, Will do that.

Thanks,
Ravi
