Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5776B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 22:02:32 -0400 (EDT)
Message-ID: <4A84C58B.6050707@kernel.org>
Date: Fri, 14 Aug 2009 11:01:47 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [Patch] percpu: use the right flag for get_vm_area()
References: <20090813060235.5516.12662.sendpatchset@localhost.localdomain>
In-Reply-To: <20090813060235.5516.12662.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Amerigo Wang wrote:
> get_vm_area() only accepts VM_* flags, not GFP_*.
> 
> And according to the doc of get_vm_area(), here should be
> VM_ALLOC.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Ingo Molnar <mingo@elte.hu>

Ah... indeed.

Acked-by: Tejun Heo <tj@kernel.org>

Will forward to Linus with other two patches today.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
