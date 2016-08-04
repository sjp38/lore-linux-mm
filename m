Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 085586B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:54:28 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l2so421474028qkf.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:54:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u32si9109798qtb.52.2016.08.04.11.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 11:54:27 -0700 (PDT)
Date: Thu, 4 Aug 2016 20:54:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/7]  userfaultfd: add support for shared memory
Message-ID: <20160804185424.evlipxlvnlymljtu@redhat.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike,

On Thu, Aug 04, 2016 at 11:14:11AM +0300, Mike Rapoport wrote:
> These patches enable userfaultfd support for shared memory mappings. The
> VMAs backed with shmem/tmpfs can be registered with userfaultfd which
> allows management of page faults in these areas by userland.
> 
> This patch set adds implementation of shmem_mcopy_atomic_pte for proper
> handling of UFFDIO_COPY command. A callback to handle_userfault is added
> to shmem page fault handling path. The userfaultfd register/unregister
> methods are extended to allow shmem VMAs.
> 
> The UFFDIO_ZEROPAGE and UFFDIO_REGISTER_MODE_WP are not implemented which
> is reflected by userfaultfd API handshake methods.

This looks great.

I'm getting rejects during rebase but not because of your changes, I
think I'll fold some patches that I originally fixed up incrementally,
in order to reduce the reject churn.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
