Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id A28BD8D0002
	for <linux-mm@kvack.org>; Fri, 11 May 2012 23:10:40 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so5979423obb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 20:10:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FAC418E.6060500@redhat.com>
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
	<4FA2C946.60006@redhat.com>
	<4FA2EA4A.6040703@redhat.com>
	<CAMYGaxosaVXmpQQqpq+bGV9F7-i8APTpDq=ErWdhw2EHGEzmKg@mail.gmail.com>
	<CAMYGaxruZbhvtZg76_zo6-BjChObpCAE8-MTA=xbBOavct+XNw@mail.gmail.com>
	<4FABD6BE.1060401@redhat.com>
	<CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
	<4FAC418E.6060500@redhat.com>
Date: Sat, 12 May 2012 08:40:39 +0530
Message-ID: <CAMYGaxrYex7ALY4_5R_jTz-xftu6zVD3-SmUdVDO-Gy4Vom7gA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into per
 user_struct spinlock
From: rajman mekaco <rajman.mekaco@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>>
>> Maybe you didn't read my last email:
>> If 2 different user-mode processes executing on 2 CPUs under 2 different
>> users want to access the same shared memory through the
>> shmctl(SHM_LOCK) / shmget(SHM_HUGETLB) / usr_shm_lock
>> primitives, they could compete/spin even though their user_structs
>> are different.
>>
>> Can you please correct me if I am missing some crucial point of
>> understanding ?
>
>
> Mlock is a very very expensive operation.
>
> Updating the mlock statistics is a very cheap operation.
>
> Does this spinlock ever show up contention wise?

I just tested for working and not contention. :)
I was just going by correctness of concept.
But I understand what you say and I will try to actually test contention
for this in the coming days.

>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
