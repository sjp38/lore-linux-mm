Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 50F0C6B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 12:48:47 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2834533obb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 09:48:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
	<4FA2C946.60006@redhat.com>
	<4FA2EA4A.6040703@redhat.com>
	<CAMYGaxosaVXmpQQqpq+bGV9F7-i8APTpDq=ErWdhw2EHGEzmKg@mail.gmail.com>
	<CAMYGaxruZbhvtZg76_zo6-BjChObpCAE8-MTA=xbBOavct+XNw@mail.gmail.com>
	<4FABD6BE.1060401@redhat.com>
	<CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
Date: Thu, 10 May 2012 22:18:46 +0530
Message-ID: <CAMYGaxrj37Wwan+UKKvvSj6M+G=ksNMscmF40JDMrKZmx5tD2g@mail.gmail.com>
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into per
 user_struct spinlock
From: rajman mekaco <rajman.mekaco@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> If 2 different user-mode processes executing on 2 CPUs under 2 different
> users want to access the same shared memory through the

One correction:
This will happen even for different shared memory as the lock is global.
This fact just increases the relevance of this patch, dont you think ?

> shmctl(SHM_LOCK) / shmget(SHM_HUGETLB) / usr_shm_lock
> primitives, they could compete/spin even though their user_structs
> are different.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
