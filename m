Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D77FC6B0276
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:44:04 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so49083042pfy.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:44:04 -0800 (PST)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id b2si2895120pll.243.2017.01.19.00.44.03
        for <linux-mm@kvack.org>;
        Thu, 19 Jan 2017 00:44:04 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com> <1484814154-1557-2-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1484814154-1557-2-git-send-email-rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] userfaultfd: non-cooperative: rename *EVENT_MADVDONTNEED to *EVENT_REMOVE
Date: Thu, 19 Jan 2017 16:43:55 +0800
Message-ID: <03ad01d27230$2b57d9a0$82078ce0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Rapoport' <rppt@linux.vnet.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>, linux-mm@kvack.org


On Thursday, January 19, 2017 4:23 PM Mike Rapoport wrote: 
> 
> The UFFD_EVENT_MADVDONTNEED purpose is to notify uffd monitor about removal
> of certain range from address space tracked by userfaultfd.
> Hence, UFFD_EVENT_REMOVE seems to better reflect the operation semantics.
> Respectively, 'madv_dn' field of uffd_msg is renamed to 'remove' and the
> madvise_userfault_dontneed callback is renamed to userfaultfd_remove.
> 
Looks that "no function change" is missing.

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
