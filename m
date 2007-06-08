Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58G7nax019628
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 12:07:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58G7ilw192082
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 10:07:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58G7i6E024867
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 10:07:44 -0600
Message-ID: <46697EDA.9000209@us.ibm.com>
Date: Fri, 08 Jun 2007 09:07:54 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com> <20070606204432.b670a7b1.akpm@linux-foundation.org> <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com> <20070607162004.GA27802@vino.hallyn.com> <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Eric W. Biederman wrote:

>
>At this point given that we actually have a small user space dependency
>and the fact that after I have reviewed the code it looks harmless to
>change the inode number of those inodes, in both cases they are just
>anonymous inodes generated with new_inode, and anything that we wrap
>is likely to be equally so.
>
>So it looks to me like we need to do three things:
>- Fix the inode number
>
Okay. its already done.

>
>- Fix the name on the hugetlbfs dentry to hold the key
>
I don't see need for doing this for hugetlbfs inodes. Currently, they 
don't base their
name on "key" + basing on the "key" is kind of useless anyway (its not 
unique).

>
>- Add a big fat comment that user space programs depend on this
>  behavior of both the dentry name and the inode number.
>
I don't think, the user-space can depend on the dentry-name. It can only 
depend
on inode# to match shmid. (since key is not unique esp. for key=0x00000000).

BTW, I agree that shmid is not unique even without namespaces as its 
based on
seq# and we wrap seq#.

Thanks,
Badari




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
