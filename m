Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7CA6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 04:13:42 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so3312676igb.14
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 01:13:42 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id p6si17746796icc.57.2014.04.07.01.13.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 01:13:41 -0700 (PDT)
Date: Mon, 7 Apr 2014 10:13:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH -mm 2/3] lockdep: mark rwsem_acquire_read as recursive
Message-ID: <20140407081336.GC11096@twins.programming.kicks-ass.net>
References: <cover.1396779337.git.vdavydov@parallels.com>
 <8c6473e959a4557d8622a6d7ff24888cb3f7512d.1396779337.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c6473e959a4557d8622a6d7ff24888cb3f7512d.1396779337.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Ingo Molnar <mingo@redhat.com>

On Sun, Apr 06, 2014 at 07:33:51PM +0400, Vladimir Davydov wrote:
> rw_semaphore implementation allows recursing calls to down_read, but
> lockdep thinks that it doesn't. As a result, it will complain
> false-positively, e.g. if we do not observe some predefined locking
> order when taking an rw semaphore for reading and a mutex.
> 
> This patch makes lockdep think rw semaphore is read-recursive, just like
> rw spin lock.

Uhm no rwsem isn't read recursive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
