Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92MYP9M015897
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 18:34:25 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92MYPMP483072
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 16:34:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92MYOlc017907
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 16:34:25 -0600
Subject: Re: [patch] fix file position for hugetlbfs-read-support
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <b040c32a0710021530o7a8ae28aybd65f8f4d677029@mail.gmail.com>
References: <b040c32a0710021530o7a8ae28aybd65f8f4d677029@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 15:37:31 -0700
Message-Id: <1191364651.6106.52.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 15:30 -0700, Ken Chen wrote:
> While working on a related area, I ran into a bug in hugetlbfs file
> read support that is currently in -mm tree
> (hugetlbfs-read-support.patch).
> 
> The problem is that hugetlb file position wasn't updated in
> hugetlbfs_read(), so sys_read() will always read from same file
> location.  A simple "cp" command that reads file until EOF will never
> terminate.  Fix it by updating the ppos at the end of
> hugetlbfs_read().
> 
> Signed-off-by: Ken Chen <kenchen@google.com>
> 

Acked-by: Badari Pulavarty <pbadari@us.ibm.com>

Thank you.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
