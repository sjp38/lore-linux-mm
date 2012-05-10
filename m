Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 58EC36B00F4
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:39:06 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2736156obb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:39:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FABD6BE.1060401@redhat.com>
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
	<4FA2C946.60006@redhat.com>
	<4FA2EA4A.6040703@redhat.com>
	<CAMYGaxosaVXmpQQqpq+bGV9F7-i8APTpDq=ErWdhw2EHGEzmKg@mail.gmail.com>
	<CAMYGaxruZbhvtZg76_zo6-BjChObpCAE8-MTA=xbBOavct+XNw@mail.gmail.com>
	<4FABD6BE.1060401@redhat.com>
Date: Thu, 10 May 2012 21:09:05 +0530
Message-ID: <CAMYGaxqxb=XR8R26h4e2URA2hG2M3j9V4u0DLJ9ifmkZKJa+eg@mail.gmail.com>
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into per
 user_struct spinlock
From: rajman mekaco <rajman.mekaco@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2012 at 8:24 PM, Rik van Riel <riel@redhat.com> wrote:
> On 05/10/2012 09:34 AM, rajman mekaco wrote:
>
>> Any updates on this ?
>
>
> There is still no usecase to demonstrate a problem, so no real
> justification to merge the patch. =A0Coming up with such a usecase
> is up to the submitter of the patch.

Maybe you didn't read my last email:
If 2 different user-mode processes executing on 2 CPUs under 2 different
users want to access the same shared memory through the
shmctl(SHM_LOCK) / shmget(SHM_HUGETLB) / usr_shm_lock
primitives, they could compete/spin even though their user_structs
are different.

Can you please correct me if I am missing some crucial point of understandi=
ng ?

Or did you mean that I should update the ChangeLog with this kind of
description ?

>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
