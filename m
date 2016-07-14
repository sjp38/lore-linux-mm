Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4126B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:25:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l89so59115383lfi.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 12:25:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h11si3364894wmd.58.2016.07.14.12.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 12:25:26 -0700 (PDT)
Date: Thu, 14 Jul 2016 15:22:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] mm: Track NR_KERNEL_STACK in KiB instead of number
 of stacks
Message-ID: <20160714192237.GA13522@cmpxchg.org>
References: <cover.1468523549.git.luto@kernel.org>
 <083c71e642c5fa5f1b6898902e1b2db7b48940d4.1468523549.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <083c71e642c5fa5f1b6898902e1b2db7b48940d4.1468523549.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Thu, Jul 14, 2016 at 12:14:10PM -0700, Andy Lutomirski wrote:
> Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
> zone.  This only makes sense if each kernel stack exists entirely in
> one zone, and allowing vmapped stacks could break this assumption.
> 
> Since frv has THREAD_SIZE < PAGE_SIZE, we need to track kernel stack
> allocations in a unit that divides both THREAD_SIZE and PAGE_SIZE on
> all architectures.  Keep it simple and use KiB.
> 
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
