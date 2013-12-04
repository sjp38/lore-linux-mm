Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f208.google.com (mail-pd0-f208.google.com [209.85.192.208])
	by kanga.kvack.org (Postfix) with ESMTP id 05CF46B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 10:16:15 -0500 (EST)
Received: by mail-pd0-f208.google.com with SMTP id r10so248391pdi.3
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 07:16:15 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id sb9si378578igb.6.2013.12.04.01.00.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 01:00:24 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 4 Dec 2013 14:30:11 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 767E0E0053
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 14:32:22 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB4905qH53215272
	for <linux-mm@kvack.org>; Wed, 4 Dec 2013 14:30:05 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB4909j7010568
	for <linux-mm@kvack.org>; Wed, 4 Dec 2013 14:30:09 +0530
Message-ID: <529EF0FB.2050808@linux.vnet.ibm.com>
Date: Wed, 04 Dec 2013 14:38:11 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of empty
 numa node
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org> <529EE811.5050306@linux.vnet.ibm.com> <20131204004125.a06f7dfc.akpm@linux-foundation.org>
In-Reply-To: <20131204004125.a06f7dfc.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/04/2013 02:11 PM, Andrew Morton wrote:
> On Wed, 04 Dec 2013 14:00:09 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
>
>> Unfaortunately, from my search, I saw that the code belonged to pre git
>> time, so could not get much information on that.
>
> Here: https://lkml.org/lkml/2004/8/20/242
>
> It seems it was done as a rather thoughtless performance optimisation.
> I'd say it's time to reimplement max_sane_readahead() from scratch.
>

Ok. Thanks for the link. I think after that,
Here it was changed to pernode:
https://lkml.org/lkml/2004/8/21/9 to avoid iteration all over.

do you think above patch (+comments) with some sanitized nr (thus
avoiding iteration over nodes in remote numa readahead case) does look
better?
or should we iterate all memory.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
