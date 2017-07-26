Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D623E6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:27:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l13so36159809qtc.15
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:27:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 84si14205717qky.78.2017.07.26.07.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 07:27:26 -0700 (PDT)
Date: Wed, 26 Jul 2017 16:27:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RESEND PATCH 2/2] userfaultfd: selftest: Add tests for
 UFFD_FREATURE_SIGBUS
Message-ID: <20170726142723.GW29716@redhat.com>
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue, Jul 25, 2017 at 12:47:42AM -0400, Prakash Sangappa wrote:
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>  tools/testing/selftests/vm/userfaultfd.c |  121 +++++++++++++++++++++++++++++-
>  1 files changed, 118 insertions(+), 3 deletions(-)

Like Mike said, some comment about the test would be better, commit
messages are never one liners in the kernel.

> @@ -408,6 +409,7 @@ static int copy_page(int ufd, unsigned long offset)
>  				userfaults++;
>  			break;
>  		case UFFD_EVENT_FORK:
> +			close(uffd);
>  			uffd = msg.arg.fork.ufd;
>  			pollfd[0].fd = uffd;
>  			break;

Isn't this fd leak bugfix independent of the rest of the changes? The
only side effects should have been that it could run out of fds, but I
assume this was found by source review as I doubt it could run out of fds.
This could be splitted off in a separate patch.

Overall it looks a good test also exercising UFFD_EVENT_FORK at the
same time.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
