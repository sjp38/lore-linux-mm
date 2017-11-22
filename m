Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0AEE6B0253
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:29:42 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id 27so1300764lft.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 02:29:42 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id b78si2573920lfb.153.2017.11.22.02.29.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 02:29:41 -0800 (PST)
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
References: <20171101053244.5218-1-slandden@gmail.com>
 <20171103063544.13383-1-slandden@gmail.com>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <f141dd62-b962-9235-d70d-4b2b4bd508bc@sony.com>
Date: Wed, 22 Nov 2017 11:29:40 +0100
MIME-Version: 1.0
In-Reply-To: <20171103063544.13383-1-slandden@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 11/03/2017 07:35 AM, Shawn Landden wrote:
> It is common for services to be stateless around their main event loop.
> If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
> signals to the kernel that epoll_wait() and friends may not complete,
> and the kernel may send SIGKILL if resources get tight.
>
> See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
>
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).
>
> 16 bytes per process is kinda spendy, but I want to keep
> lru behavior, which mem_score_adj does not allow. When a supervisor,
> like Android's user input is keeping track this can be done in user-space.
> It could be pulled out of task_struct if an cross-indexing additional
> red-black tree is added to support pid-based lookup.
What android version is using systemd?
In android there is a OnTrimMemory that is sent from activitymanager that
you can listen on and make a nice exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
