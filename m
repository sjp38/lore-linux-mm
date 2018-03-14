Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 914966B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:21:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u68so1138468wmd.5
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:21:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 34si283091edl.118.2018.03.14.08.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 08:21:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2EF9U57100775
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:21:01 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gq5b8376r-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:20:59 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 14 Mar 2018 15:20:57 -0000
Subject: Re: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
 <20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Wed, 14 Mar 2018 20:52:59 +0530
MIME-Version: 1.0
In-Reply-To: <20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <ec9c4ef7-0117-7c7c-64bc-f6bf4261721d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/14/2018 07:20 PM, Masami Hiramatsu wrote:
> On Tue, 13 Mar 2018 18:26:03 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> No functionality changes.
> Please consider to describe what is this change and why, here.

Will add in next version.

>> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
>> ---
>>  Documentation/trace/uprobetracer.txt | 16 +++++++++++++---
>>  kernel/trace/trace.c                 |  2 +-
>>  2 files changed, 14 insertions(+), 4 deletions(-)
>>
>> diff --git a/Documentation/trace/uprobetracer.txt b/Documentation/trace/uprobetracer.txt
>> index bf526a7c..8fb13b0 100644
>> --- a/Documentation/trace/uprobetracer.txt
>> +++ b/Documentation/trace/uprobetracer.txt
>> @@ -19,15 +19,25 @@ user to calculate the offset of the probepoint in the object.
>>  
>>  Synopsis of uprobe_tracer
>>  -------------------------
>> -  p[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a uprobe
>> -  r[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a return uprobe (uretprobe)
>> -  -:[GRP/]EVENT                           : Clear uprobe or uretprobe event
>> +  p[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
>> +  r[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
> Ah, OK in this context, [] means optional syntax :)

Correct.

Thanks,
Ravi
