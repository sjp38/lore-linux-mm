Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0002C6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 13:07:54 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7GH7qRB022552
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 10:07:52 -0700
Received: from iym1 (iym1.prod.google.com [10.241.52.1])
	by wpaz5.hot.corp.google.com with ESMTP id p7GH7OeX026477
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 10:07:51 -0700
Received: by iym1 with SMTP id 1so141810iym.14
        for <linux-mm@kvack.org>; Tue, 16 Aug 2011 10:07:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110816093303.GA4484@csn.ul.ie>
References: <1313441856-1419-1-git-send-email-wad@chromium.org>
	<20110816093303.GA4484@csn.ul.ie>
Date: Tue, 16 Aug 2011 10:07:46 -0700
Message-ID: <CAB=4xhqu1FsJnNbHNeokyROvEFpRJYKhcHRLLw5QTVKOkbkWfQ@mail.gmail.com>
Subject: Re: [PATCH] mmap: add sysctl for controlling ~VM_MAYEXEC taint
From: Roland McGrath <mcgrathr@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Al Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org

On Tue, Aug 16, 2011 at 2:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> Is using shm_open()+mmap instead of open()+mmap() to open a file on
> /dev/shm really that difficult?
>
> int shm_open(const char *name, int oflag, mode_t mode);
> int open(const char *pathname, int flags, mode_t mode);

I cannot figure out the rationale behind this question at all.
Both of these library functions result in the same system call.

> An ordinary user is not going to know that a segfault from an
> application can be fixed with this sysctl. This looks like something
> that should be fixed in the library so that it can work on kernels
> that do not have the sysctl.

I think the expectation is that the administrator or system builder
who decides to set the (non-default) noexec mount option will also
set the sysctl at the same time.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
