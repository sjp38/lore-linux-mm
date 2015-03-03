Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 466806B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 19:42:30 -0500 (EST)
Received: by pablj1 with SMTP id lj1so9656809pab.10
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:42:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hn4si11519597pbb.173.2015.03.02.16.42.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 16:42:29 -0800 (PST)
Date: Mon, 2 Mar 2015 16:42:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: reorder can_do_mlock to fix audit denial
Message-Id: <20150302164228.4de418951c7d17b7e315d52f@linux-foundation.org>
In-Reply-To: <1425316867-6104-1-git-send-email-jeffv@google.com>
References: <1425316867-6104-1-git-send-email-jeffv@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Vander Stoep <jeffv@google.com>
Cc: nnk@google.com, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Paul Cassella <cassella@cray.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  2 Mar 2015 09:20:32 -0800 Jeff Vander Stoep <jeffv@google.com> wrote:

> A userspace call to mmap(MAP_LOCKED) may result in the successful
> locking of memory while also producing a confusing audit log denial.
> can_do_mlock checks capable and rlimit. If either of these return
> positive can_do_mlock returns true. The capable check leads to an LSM
> hook used by apparmour and selinux which produce the audit denial.
> Reordering so rlimit is checked first eliminates the denial on success,
> only recording a denial when the lock is unsuccessful as a result of
> the denial.

I'm assuming that this is a minor issue - a bogus audit log, no other
consequences.  And based on this I queued the patch for 4.0 with no
-stable backport.

All of this might have been wrong - the changelog wasn't very helpful
in making such decisions (hint).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
