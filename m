Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 30B1C6B004D
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:21:56 -0400 (EDT)
Message-ID: <4F8093D0.1050908@tilera.com>
Date: Sat, 7 Apr 2012 15:21:52 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 07/10] mm: use mm->exe_file instead of first VM_EXECUTABLE
 vma->vm_file
References: <20120407185546.9726.62260.stgit@zurg> <20120407190125.9726.33538.stgit@zurg>
In-Reply-To: <20120407190125.9726.33538.stgit@zurg>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Robert Richter <robert.richter@amd.com>, Eric Paris <eparis@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Al Viro <viro@zeniv.linux.org.uk>, James Morris <james.l.morris@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kentaro Takeda <takedakn@nttdata.co.jp>

On 4/7/2012 3:01 PM, Konstantin Khlebnikov wrote:
> Some security modules and oprofile still uses VM_EXECUTABLE for retrieving
> task's executable file, after this patch they will use mm->exe_file directly.
> mm->exe_file protected with mm->mmap_sem, so locking stays the same.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Robert Richter <robert.richter@amd.com>
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Eric Paris <eparis@redhat.com>
> Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: linux-security-module@vger.kernel.org
> Cc: oprofile-list@lists.sf.net

For arch/tile:

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
