Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AC8E16B0044
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 16:13:33 -0400 (EDT)
Date: Sat, 31 Mar 2012 22:13:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120331201324.GA17565@redhat.com>
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120331092929.19920.54540.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Matt Helsley <matthltc@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Cyrill Gorcunov <gorcunov@openvz.org>

On 03/31, Konstantin Khlebnikov wrote:
>
> comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
> where all this stuff was introduced:
>
> > ...
> > This avoids pinning the mounted filesystem.
>
> So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
> fix some hypothetical pinning fs from umounting by mm which already unmapped all
> its executable files, but still alive. Does anyone know any real world example?

This is the question to Matt.

> keep mm->exe_file alive till final mmput().

Please see the recent discussion, http://marc.info/?t=133096188900012

(just in case, the patch itself was deadly wrong, don't look at it ;)

> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -378,7 +378,6 @@ struct mm_struct {
>
>  	/* store ref to file /proc/<pid>/exe symlink points to */
>  	struct file *exe_file;
> -	unsigned long num_exe_file_vmas;

Add Cyrill. This conflicts with
c-r-prctl-add-ability-to-set-new-mm_struct-exe_file.patch in -mm.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
