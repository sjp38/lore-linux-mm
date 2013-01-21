Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 47AD66B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 09:33:49 -0500 (EST)
Message-ID: <50FD51C4.6070909@redhat.com>
Date: Mon, 21 Jan 2013 09:33:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/rmap: rename anon_vma_unlock() => anon_vma_unlock_write()
References: <20130121115921.23500.7190.stgit@zurg>
In-Reply-To: <20130121115921.23500.7190.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

On 01/21/2013 06:59 AM, Konstantin Khlebnikov wrote:
> comment in 4fc3f1d66b1ef0d7b8dc11f4ff1cc510f78b37d6 ("mm/rmap, migration:
> Make rmap_walk_anon() and try_to_unmap_anon() more scalable") says:
>
> | Rename anon_vma_[un]lock() => anon_vma_[un]lock_write(),
> | to make it clearer that it's an exclusive write-lock in
> | that case - suggested by Rik van Riel.
>
> But that commit renames only anon_vma_lock()
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
