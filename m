Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 685006B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 01:26:53 -0500 (EST)
Message-ID: <50E52316.6010602@redhat.com>
Date: Thu, 03 Jan 2013 01:20:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] mm: introduce VM_POPULATE flag to better deal with
 racy userspace programs
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-10-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-10-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> The vm_populate() code populates user mappings without constantly
> holding the mmap_sem. This makes it susceptible to racy userspace
> programs: the user mappings may change while vm_populate() is running,
> and in this case vm_populate() may end up populating the new mapping
> instead of the old one.
>
> In order to reduce the possibility of userspace getting surprised by
> this behavior, this change introduces the VM_POPULATE vma flag which
> gets set on vmas we want vm_populate() to work on. This way
> vm_populate() may still end up populating the new mapping after such a
> race, but only if the new mapping is also one that the user has
> requested (using MAP_SHARED, MAP_LOCKED or mlock) to be populated.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <ri

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
