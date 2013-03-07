Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 398376B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 01:41:35 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so132586pbc.38
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 22:41:34 -0800 (PST)
Message-ID: <51383699.7060805@gmail.com>
Date: Thu, 07 Mar 2013 14:41:29 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] tmpfs: fix mempolicy object leaks
References: <1361344302-26565-1-git-send-email-gthelen@google.com> <1361344302-26565-2-git-send-email-gthelen@google.com> <alpine.LNX.2.00.1302201221270.1152@eggly.anvils> <5133E178.90405@gmail.com> <alpine.LNX.2.00.1303051101350.27525@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303051101350.27525@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,
On 03/06/2013 03:40 AM, Hugh Dickins wrote:
> On Mon, 4 Mar 2013, Will Huck wrote:
>> Could you explain me why shmem has more relationship with mempolicy? It seems
>> that there are many codes in shmem handle mempolicy, but other components in
>> mm subsystem just have little.
> NUMA mempolicy is mostly handled in mm/mempolicy.c, which services the
> mbind, migrate_pages, set_mempolicy, get_mempolicy system calls: which
> govern how process memory is distributed across NUMA nodes.
>
> mm/shmem.c is affected because it was also found useful to specify
> mempolicy on the shared memory objects which may back process memory:
> that includes SysV SHM and POSIX shared memory and tmpfs.  mm/hugetlb.c
> contains some mempolicy handling for hugetlbfs; fs/ramfs is kept minimal,
> so nothing in there.
>
> Those are the memory-based filesystems, where NUMA mempolicy is most
> natural.  The regular filesystems could support shared mempolicy too,
> but that would raise more awkward design questions.

I found that if mbind several processes to one node and almost exhaust 
memory, processes will just stuck and no processes make progress or be 
killed. Is it normal?

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
