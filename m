Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id C95C76B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 21:49:13 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so20077786qgd.41
        for <linux-mm@kvack.org>; Wed, 28 May 2014 18:49:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o20si24822527qae.111.2014.05.28.18.49.13
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 18:49:13 -0700 (PDT)
Message-ID: <538691FB.8060309@redhat.com>
Date: Wed, 28 May 2014 21:48:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/5] mm: Introduce VM_PINNED and interfaces
References: <20140526145605.016140154@infradead.org> <20140526152107.823060865@infradead.org>
In-Reply-To: <20140526152107.823060865@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On 05/26/2014 10:56 AM, Peter Zijlstra wrote:

>  include/linux/mm.h       |    3 +
>  include/linux/mm_types.h |    5 +
>  kernel/fork.c            |    2 
>  mm/mlock.c               |  133 ++++++++++++++++++++++++++++++++++++++++++-----
>  mm/mmap.c                |   18 ++++--
>  5 files changed, 141 insertions(+), 20 deletions(-)

I'm guessing you will also want a patch that adds some code to
rmap.c, madvise.c, and a few other places to actually enforce
the VM_PINNED semantics?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
