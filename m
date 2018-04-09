Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC996B0007
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:42:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t123so5301180wmt.8
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:42:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y29si583574edl.79.2018.04.09.06.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:42:10 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39Df1i8071114
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 09:42:09 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h870bpqtf-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:42:08 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 14:42:06 +0100
Subject: Re: [PATCH v2 7/9] trace_uprobe/sdt: Fix multiple update of same
 reference counter
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180404083110.18647-8-ravi.bangoria@linux.vnet.ibm.com>
 <20180409131730.GA25631@redhat.com>
 <90d2fc35-0d58-1cab-a474-642192c7e1ff@linux.vnet.ibm.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Mon, 9 Apr 2018 19:11:48 +0530
MIME-Version: 1.0
In-Reply-To: <90d2fc35-0d58-1cab-a474-642192c7e1ff@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <fd24639f-fe58-0078-1c7c-68d8b9484e08@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 04/09/2018 07:02 PM, Ravi Bangoria wrote:
> Hi Oleg,
>
> On 04/09/2018 06:47 PM, Oleg Nesterov wrote:
>> I didn't read this version yet, just one question...
>>
>> So now it depends on CONFIG_MMU_NOTIFIER, yes? I do not see any changes in Kconfig
>> files, this doesn't look right...
> Yes, you are write.

s/write/right.
