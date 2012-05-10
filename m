Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 977C16B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 18:30:55 -0400 (EDT)
Message-ID: <4FAC418E.6060500@redhat.com>
Date: Thu, 10 May 2012 18:30:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into
 per user_struct spinlock
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com> <4FA2C946.60006@redhat.com> <4FA2EA4A.6040703@redhat.com> <CAMYGaxosaVXmpQQqpq+bGV9F7-i8APTpDq=ErWdhw2EHGEzmKg@mail.gmail.com> <CAMYGaxruZbhvtZg76_zo6-BjChObpCAE8-MTA=xbBOavct+XNw@mail.gmail.com> <4FABD6BE.1060401@redhat.com> <CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
In-Reply-To: <CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rajman mekaco <rajman.mekaco@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/10/2012 11:39 AM, rajman mekaco wrote:
> On Thu, May 10, 2012 at 8:24 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 05/10/2012 09:34 AM, rajman mekaco wrote:
>>
>>> Any updates on this ?
>>
>>
>> There is still no usecase to demonstrate a problem, so no real
>> justification to merge the patch.  Coming up with such a usecase
>> is up to the submitter of the patch.
>
> Maybe you didn't read my last email:
> If 2 different user-mode processes executing on 2 CPUs under 2 different
> users want to access the same shared memory through the
> shmctl(SHM_LOCK) / shmget(SHM_HUGETLB) / usr_shm_lock
> primitives, they could compete/spin even though their user_structs
> are different.
>
> Can you please correct me if I am missing some crucial point of understanding ?

Mlock is a very very expensive operation.

Updating the mlock statistics is a very cheap operation.

Does this spinlock ever show up contention wise?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
