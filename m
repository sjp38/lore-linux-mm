Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4F74F6B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 21:34:38 -0400 (EDT)
Date: Wed, 1 Aug 2012 11:34:28 +1000 (EST)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v3 07/10] mm: use mm->exe_file instead of first VM_EXECUTABLE
 vma->vm_file
In-Reply-To: <20120731104226.20515.76884.stgit@zurg>
Message-ID: <alpine.LRH.2.02.1208011133390.5762@tundra.namei.org>
References: <20120731103724.20515.60334.stgit@zurg> <20120731104226.20515.76884.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Eric Paris <eparis@redhat.com>, Robert Richter <robert.richter@amd.com>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Al Viro <viro@zeniv.linux.org.uk>, James Morris <james.l.morris@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, Kentaro Takeda <takedakn@nttdata.co.jp>

On Tue, 31 Jul 2012, Konstantin Khlebnikov wrote:

> Some security modules and oprofile still uses VM_EXECUTABLE for retrieving
> task's executable file, after this patch they will use mm->exe_file directly.
> mm->exe_file protected with mm->mmap_sem, so locking stays the same.
> 

Acked-by: James Morris <james.l.morris@oracle.com>




-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
