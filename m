Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4C26B0277
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 00:26:47 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id n5so5778942uad.19
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 21:26:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a186sor1606311vkc.287.2017.11.20.21.26.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 21:26:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171121051639.1228-1-slandden@gmail.com>
References: <20171121044947.18479-1-slandden@gmail.com> <20171121051639.1228-1-slandden@gmail.com>
From: Shawn Landden <slandden@gmail.com>
Date: Mon, 20 Nov 2017 21:26:45 -0800
Message-ID: <CA+49okr0PC5sOuLQfuBt3J6KtWANa4eYoDpqOvp7rbQ9JDWQ5Q@mail.gmail.com>
Subject: Re: [RFC v4] It is common for services to be stateless around their
 main event loop. If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
 signals to the kernel that epoll_wait() and friends may not complete, and the
 kernel may send SIGKILL if resources get tight.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, willy@infradead.org

On Mon, Nov 20, 2017 at 9:16 PM, Shawn Landden <slandden@gmail.com> wrote:
> See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
>
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).
What about having a dedicated way to kill these type of processes,
instead of overloading the OOM killer? This was suggested by
Colin Walters <walters@verbum.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
