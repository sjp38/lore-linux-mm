Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67C186B025E
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 22:56:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k123so20928642qke.5
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 19:56:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q126si2373911qka.159.2017.10.06.19.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 19:56:36 -0700 (PDT)
Subject: Re: [PATCH] Userfaultfd: Add description for UFFD_FEATURE_SIGBUS
References: <1507344740-21993-1-git-send-email-prakash.sangappa@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <fd096fa5-e397-b1df-52cd-75bb8095706b@oracle.com>
Date: Fri, 6 Oct 2017 19:56:55 -0700
MIME-Version: 1.0
In-Reply-To: <1507344740-21993-1-git-send-email-prakash.sangappa@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, rppt@linux.vnet.ibm.com, mhocko@suse.com

cc: Andrea Arcangeli


On 10/6/17 7:52 PM, Prakash Sangappa wrote:
> Userfaultfd feature UFFD_FEATURE_SIGBUS was merged recently and should
> be available in Linux 4.14 release. This patch is for the manpage
> changes documenting this API.
>
> Documents the following commit:
>
> commit 2d6d6f5a09a96cc1fec7ed992b825e05f64cb50e
> Author: Prakash Sangappa <prakash.sangappa@oracle.com>
> Date: Wed Sep 6 16:23:39 2017 -0700
>
>      mm: userfaultfd: add feature to request for a signal delivery
>
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>   man2/ioctl_userfaultfd.2 |  9 +++++++++
>   man2/userfaultfd.2       | 17 +++++++++++++++++
>   2 files changed, 26 insertions(+)
>
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 60fd29b..cfc65ae 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -196,6 +196,15 @@ with the
>   flag set,
>   .BR memfd_create (2),
>   and so on.
> +.TP
> +.B UFFD_FEATURE_SIGBUS
> +Since Linux 4.14, If this feature bit is set, no page-fault events(
> +.B UFFD_EVENT_PAGEFAULT
> +) will be delivered, instead a
> +.B SIGBUS
> +signal will be sent to the faulting process. Applications using this
> +feature will not require the use of a userfaultfd monitor for handling
> +page-fault events.
>   .IP
>   The returned
>   .I ioctls
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 1741ee3..a033742 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -172,6 +172,23 @@ or
>   .BR ioctl (2)
>   operations to resolve the page fault.
>   .PP
> +Starting from Linux 4.14, if application sets
> +.B UFFD_FEATURE_SIGBUS
> +feature bit using
> +.B UFFDIO_API
> +.BR ioctl (2)
> +, no page fault notification will be forwarded to
> +the user-space, instead a
> +.B SIGBUS
> +signal is delivered to the faulting process. With this feature,
> +userfaultfd can be used for robustness purpose to simply catch
> +any access to areas within the registered address range that do not
> +have pages allocated, without having to deal with page-fault events.
> +No userfaultd monitor will be required for handling page faults. For
> +example, this feature can be useful for applications that want to
> +prevent the kernel from automatically allocating pages and filling
> +holes in sparse files when the hole is accessed thru mapped address.
> +.PP
>   Details of the various
>   .BR ioctl (2)
>   operations can be found in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
