Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D7FFE6B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 17:10:40 -0500 (EST)
Date: Sun, 6 Nov 2011 23:10:38 +0100
From: Lennart Poettering <mzxreary@0pointer.de>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111106221038.GB11672@tango.0pointer.de>
References: <1320614101.3226.5.camel@offbook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320614101.3226.5.camel@offbook>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@gnu.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>

On Sun, 06.11.11 18:15, Davidlohr Bueso (dave@gnu.org) wrote:

> From: Davidlohr Bueso <dave@gnu.org>
> 
> This patch adds a new RLIMIT_TMPFSQUOTA resource limit to restrict an individual user's quota across all mounted tmpfs filesystems.
> It's well known that a user can easily fill up commonly used directories (like /tmp, /dev/shm) causing programs to break through DoS.

Thanks a lot for this work! One comment without looking at the patch in detail:

> +	if (atomic_long_read(&user->shmem_bytes) + len > 
> +	    rlimit(RLIMIT_TMPFSQUOTA))
> +		return -ENOSPC;

This should be EDQUOT "Disk quota exceeded", not ENOSPC "No space left
on device".

Lennart

-- 
Lennart Poettering - Red Hat, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
