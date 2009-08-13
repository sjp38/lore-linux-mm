Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A80C6B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 17:49:49 -0400 (EDT)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id n7DLnnGu006359
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 22:49:49 +0100
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by zps19.corp.google.com with ESMTP id n7DLnk1x029717
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:49:46 -0700
Received: by pzk14 with SMTP id 14so722585pzk.29
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:49:46 -0700 (PDT)
Date: Thu, 13 Aug 2009 14:49:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] Add MAP_HUGETLB example to vm/hugetlbpage.txt V2
In-Reply-To: <617054c59f53f43f6fecfd6908cfb86ea1dd6f72.1250156841.git.ebmunson@us.ibm.com>
Message-ID: <alpine.DEB.2.00.0908131449270.9805@chino.kir.corp.google.com>
References: <cover.1250156841.git.ebmunson@us.ibm.com> <e9b02974a0cca308927ff3a4a0765b93faa6d12f.1250156841.git.ebmunson@us.ibm.com> <83949d066e2a7221a25dd74d12d6dcf7e8b4e9ba.1250156841.git.ebmunson@us.ibm.com>
 <617054c59f53f43f6fecfd6908cfb86ea1dd6f72.1250156841.git.ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009, Eric B Munson wrote:

> This patch adds an example of how to use the MAP_HUGETLB flag to
> the vm documentation.
> 
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> ---
> Changes from V1:
>  Rebase to newest linux-2.6 tree
>  Change MAP_LARGEPAGE to MAP_HUGETLB to match flag name in huge page shm
> 
>  Documentation/vm/hugetlbpage.txt |   80 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 80 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index ea8714f..d30fa1a 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -337,3 +337,83 @@ int main(void)
>  
>  	return 0;
>  }
> +
> +*******************************************************************
> +
> +/*
> + * Example of using hugepage memory in a user application using the mmap
> + * system call with MAP_LARGEPAGE flag.  Before running this program make

s/MAP_LARGEPAGE/MAP_HUGETLB/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
