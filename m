Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEAE6B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:54:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h89so474054qtd.18
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 01:54:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c129si2498116qkd.326.2018.03.16.01.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 01:54:54 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2G8s5Uq100034
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:54:53 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gr7qmxw9a-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:54:52 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 08:54:50 -0000
Subject: Re: [PATCH 3/8] Uprobe: Rename map_info to uprobe_map_info
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-4-ravi.bangoria@linux.vnet.ibm.com>
 <20180315124449.7d92c06b@vmware.local.home>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Fri, 16 Mar 2018 14:26:58 +0530
MIME-Version: 1.0
In-Reply-To: <20180315124449.7d92c06b@vmware.local.home>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <e8d9fc29-62b2-95eb-d868-42df26c3212e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/15/2018 10:14 PM, Steven Rostedt wrote:
> On Tue, 13 Mar 2018 18:25:58 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>> -static inline struct map_info *free_map_info(struct map_info *info)
>> +static inline struct uprobe_map_info *
>> +uprobe_free_map_info(struct uprobe_map_info *info)
>>  {
>> -	struct map_info *next = info->next;
>> +	struct uprobe_map_info *next = info->next;
>>  	kfree(info);
>>  	return next;
>>  }
>>  
>> -static struct map_info *
>> -build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
>> +static struct uprobe_map_info *
>> +uprobe_build_map_info(struct address_space *mapping, loff_t offset,
> Also, as these functions have side effects (like you need to perform a
> mmput(info->mm), you need to add kerneldoc type comments to these
> functions, explaining how to use them.
>
> When you upgrade a function from static to use cases outside the file,
> it requires documenting that function for future users.

Sure, will add a comment here.

Thanks for the review,
Ravi
