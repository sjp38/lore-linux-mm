Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D89916B03C4
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 08:42:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s22so6030840pfs.0
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 05:42:26 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id h7si20540146pgn.97.2017.04.05.05.42.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 05:42:26 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ONX00E5ESMMDG00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 05 Apr 2017 13:42:22 +0100 (BST)
Subject: Re: [PATCH v3] userfaultfd: provide pid in userfault msg
From: Alexey Perevalov <a.perevalov@samsung.com>
Message-id: <a442cd0f-87a6-2a88-8139-3dc2f4e92620@samsung.com>
Date: Wed, 05 Apr 2017 15:42:18 +0300
MIME-version: 1.0
In-reply-to: <20170404190419.GA5081@redhat.com>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
References: <1491211956-6095-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170403093318eucas1p2ebd57e5e4c33707063687ccd571f67bb@eucas1p2.samsung.com>
 <1491211956-6095-2-git-send-email-a.perevalov@samsung.com>
 <20170404190419.GA5081@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, rppt@linux.vnet.ibm.com, mike.kravetz@oracle.com, dgilbert@redhat.com

On 04/04/2017 10:04 PM, Andrea Arcangeli wrote:
> Hello Alexey,
>
> v3 looks great to me.
>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
>
> On top of v3 I think we could add this to make it more obvious to the
> developer tpid isn't necessarily there by just looking at the data
> structure.
>
> This is purely cosmetical, so feel free to comment if you
> disagree.
Why not, I agree with this change.

>
> I'm also fine to add an anonymous union later if a new usage for those
> bytes emerges (ABI side doesn't change anything which is why this
> could be done later as well, only the API changes here but then I
> doubt we'd break the API later for this, so if we want pagefault.feat.*
> it probably should be done right now).
>
> Thanks,
> Andrea
>
> >From 901951f5a0456aa07d4fb1231cf2b1d352beb36f Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 4 Apr 2017 20:50:54 +0200
> Subject: [PATCH 1/1] userfaultfd: provide pid in userfault msg - add feat
>   union
>
> No ABI change, but this will make it more explicit to software that
> ptid is only available if requested by passing UFFD_FEATURE_THREAD_ID
> to UFFDIO_API. The fact it's a union will also self document it
> shouldn't be taken for granted there's a tpid there.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>   include/uapi/linux/userfaultfd.h | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index ff8d0d2..524b860 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -84,7 +84,9 @@ struct uffd_msg {
>   		struct {
>   			__u64	flags;
>   			__u64	address;
> -			__u32   ptid;
> +			union {
> +				__u32 ptid;
> +			} feat;
>   		} pagefault;
>   
>   		struct {
>
>
>
>


-- 
Best regards,
Alexey Perevalov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
