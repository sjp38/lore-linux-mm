Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id C62769003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 19:31:41 -0400 (EDT)
Received: by obnw1 with SMTP id w1so143774961obn.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:31:41 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y4si2358442oiy.21.2015.07.22.16.31.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 16:31:40 -0700 (PDT)
Message-ID: <55B027D3.4020608@oracle.com>
Date: Wed, 22 Jul 2015 16:31:31 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch] mmap.2: document the munmap exception for underlying
 page size
References: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, mtk.manpages@gmail.com
Cc: Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 07/21/2015 05:41 PM, David Rientjes wrote:
> munmap(2) will fail with an errno of EINVAL for hugetlb memory if the
> length is not a multiple of the underlying page size.
>
> Documentation/vm/hugetlbpage.txt was updated to specify this behavior
> since Linux 4.1 in commit 80d6b94bd69a ("mm, doc: cleanup and clarify
> munmap behavior for hugetlb memory").
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   man2/mmap.2 | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/man2/mmap.2 b/man2/mmap.2
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -383,6 +383,10 @@ All pages containing a part
>   of the indicated range are unmapped, and subsequent references
>   to these pages will generate
>   .BR SIGSEGV .
> +An exception is when the underlying memory is not of the native page
> +size, such as hugetlb page sizes, whereas
> +.I length
> +must be a multiple of the underlying page size.
>   It is not an error if the
>   indicated range does not contain any mapped pages.
>   .SS Timestamps changes for file-backed mappings
>
> --

Should we also add a similar comment for the mmap offset?  Currently
the man page says:

"offset must be a multiple of the page size as returned by
  sysconf(_SC_PAGE_SIZE)."

For hugetlbfs, I beieve the offset must be a multiple of the
hugetlb page size.  A similar comment/exception about using
the "underlying page size" would apply here as well.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
