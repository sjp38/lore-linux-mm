Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l594W6em023011
	for <linux-mm@kvack.org>; Sat, 9 Jun 2007 00:32:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l594W6SE516474
	for <linux-mm@kvack.org>; Sat, 9 Jun 2007 00:32:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l594W55f022701
	for <linux-mm@kvack.org>; Sat, 9 Jun 2007 00:32:06 -0400
Message-ID: <466A2D4F.3040300@us.ibm.com>
Date: Fri, 08 Jun 2007 21:32:15 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com> <20070606204432.b670a7b1.akpm@linux-foundation.org> <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com> <20070607162004.GA27802@vino.hallyn.com> <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com> <46697EDA.9000209@us.ibm.com> <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com> <20070608165505.aa15fcdb.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>On Fri, 08 Jun 2007 17:43:34 -0600
>ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>>Some user space tools need to identify SYSV shared memory when
>>examining /proc/<pid>/maps.  To do so they look for a block device
>>with major zero, a dentry named SYSV<sysv key>, and having the minor of
>>the internal sysv shared memory kernel mount.
>>
>>To help these tools and to make it easier for people just browsing
>>/proc/<pid>/maps this patch modifies hugetlb sysv shared memory to
>>use the SYSV<key> dentry naming convention.
>>
>>User space tools will still have to be aware that hugetlb sysv
>>shared memory lives on a different internal kernel mount and so
>>has a different block device minor number from the rest of sysv
>>shared memory.
>>
>
>I assume this fix is preferred over Badari's?  If so, why?
>
No. You still need my patch to fix the current breakage.

This patch makes hugetlbfs also use same naming convention as regular 
shmem for its
name. This is not absolutely needed, its a nice to have. Currently, user 
space tools
can't depend on the filename alone, since its not unique (based on kry).

Thanks,
Badari

>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
