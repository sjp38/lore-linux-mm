Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 85D4F6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 06:53:06 -0400 (EDT)
Date: Fri, 20 Apr 2012 20:52:55 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH v2 05/10] mm: kill vma flag VM_CAN_NONLINEAR
Message-ID: <20120420105255.GC25458@amd.local0.net>
References: <20120407185546.9726.62260.stgit@zurg>
 <20120407190115.9726.85024.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120407190115.9726.85024.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>

On Sat, Apr 07, 2012 at 11:01:15PM +0400, Konstantin Khlebnikov wrote:
> This patch moves actual ptes filling for non-linear file mappings
> into special vma operation: ->remap_pages().
> 
> Now fs must implement this method to get non-linear mappings support.
> If fs uses filemap_fault() then it can use generic_file_remap_pages() for this.
> 

This should enable drivers that prepopulate mappings at mmap() time to
support nonlinear mappings! (I don't know if anyone uses these things
anymore, or ever had except for Oracle, but that's quite besides the
point).

Please update documentation?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
