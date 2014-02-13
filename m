Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BEB9D6B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 04:58:39 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so10444515pad.8
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 01:58:39 -0800 (PST)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id d4si1476920pao.273.2014.02.13.01.58.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 01:58:38 -0800 (PST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 15:28:13 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 089563940023
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:28:09 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1D9w10M3408154
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:28:01 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1D9w706026826
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:28:07 +0530
Message-ID: <52FC98A6.1000701@linux.vnet.ibm.com>
Date: Thu, 13 Feb 2014 15:34:22 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org> <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com> <52F88C16.70204@linux.vnet.ibm.com> <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com> <52F8C556.6090006@linux.vnet.ibm.com> <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com> <52FC6F2A.30905@linux.vnet.ibm.com> <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/13/2014 01:35 PM, David Rientjes wrote:
> On Thu, 13 Feb 2014, Raghavendra K T wrote:
>
>> I was able to test (1) implementation on the system where readahead problem
>> occurred. Unfortunately it did not help.
>>
>> Reason seem to be that CONFIG_HAVE_MEMORYLESS_NODES dependency of
>> numa_mem_id(). The PPC machine I am facing problem has topology like
>> this:
[...]
>>
>> So it seems numa_mem_id() does not help for all the configs..
>> Am I missing something ?
>>
>
> You need the patch from http://marc.info/?l=linux-mm&m=139093411119013
> first.

Thanks David, unfortunately even after applying that patch, I do not see
the improvement.

Interestingly numa_mem_id() seem to still return the value of a
memoryless node.
May be  per cpu _numa_mem_ values are not set properly. Need to dig out ....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
