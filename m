Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9329A6B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:27:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so59172390lfg.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 12:27:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b193si33761181wmb.13.2016.07.14.12.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 12:27:31 -0700 (PDT)
Date: Thu, 14 Jul 2016 15:24:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: Fix memcg stack accounting for sub-page stacks
Message-ID: <20160714192445.GB13522@cmpxchg.org>
References: <cover.1468523549.git.luto@kernel.org>
 <9b5314e3ee5eda61b0317ec1563768602c1ef438.1468523549.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9b5314e3ee5eda61b0317ec1563768602c1ef438.1468523549.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Thu, Jul 14, 2016 at 12:14:11PM -0700, Andy Lutomirski wrote:
> We should account for stacks regardless of stack size, and we need
> to account in sub-page units if THREAD_SIZE < PAGE_SIZE.  Change the
> units to kilobytes and Move it into account_kernel_stack().
> 
> Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
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
