Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4496B6B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:14:19 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so627017pad.0
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:14:18 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id pt9si33439511pbb.240.2014.07.03.11.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:14:17 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 3 Jul 2014 23:44:14 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 86FC7E004B
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 23:45:32 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63IFZAG40435952
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 23:45:35 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63IEA9b015374
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 23:44:11 +0530
Message-ID: <53B59CB5.9060004@linux.vnet.ibm.com>
Date: Thu, 03 Jul 2014 23:41:01 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
In-Reply-To: <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/03/2014 09:11 PM, Linus Torvalds wrote:
> On Thu, Jul 3, 2014 at 6:02 AM, Raghavendra K T
> <raghavendra.kt@linux.vnet.ibm.com> wrote:
>>
>> However it broke sys_readahead semantics: 'readahead() blocks until the specified
>> data has been read'
>
> What? Where did you find that insane sentence? And where did you find
> an application that depends on that totally insane semantics that sure
> as hell was never intentional.
>
> If this comes from some man-page,

Yes it is.

then the man-page is just full of
> sh*t, and is being crazy. The whole and *only* point of readahead() is
> that it does *not* block, and you can do it across multiple files.

Entirely agree. Infact I also had the strong opinion that we should
rather change man page instead of making Linux performing badly by doing
large unnecessary readahead when there is no actual read, and
performance numbers have proved that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
