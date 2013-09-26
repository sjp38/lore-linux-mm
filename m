Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A791B6B003A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:38:57 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so439202pde.37
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:38:57 -0700 (PDT)
Message-ID: <52439022.9080407@windriver.com>
Date: Thu, 26 Sep 2013 09:38:42 +0800
From: Ming Liu <ming.liu@windriver.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: avoid killing init if it assume the oom killed thread's
 mm
References: <1379929528-19179-1-git-send-email-ming.liu@windriver.com> <alpine.DEB.2.02.1309241933590.26187@chino.kir.corp.google.com> <52427970.8010905@windriver.com> <alpine.DEB.2.02.1309251056020.17676@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309251056020.17676@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/26/2013 01:56 AM, David Rientjes wrote:
> On Wed, 25 Sep 2013, Ming Liu wrote:
>
>>> We shouldn't be selecting a process where mm == init_mm in the first
>>> place, so this wouldn't fix the issue entirely.
>> But if we add a control point for "mm == init_mm" in the first place(ie. in
>> oom_unkillable_task), that would forbid the processes sharing mm with init to
>> be selected, is that reasonable? Actually my fix is just to protect init
>> process to be killed for its vfork child being selected and I think it's the
>> only place where there is the risk. If my understanding is wrong, pls correct
>> me.
>>
> We never want to select a process where task->mm == init_mm because if we
> kill it we won't free any memory, regardless of vfork().  The goal of the
> oom killer is solely to free memory, so it always tries to avoid needless
> killing.
Yes, that make sense, I will send the V1 patch.

the best,
thank you
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
