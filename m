Date: Sat, 26 Apr 2008 17:24:58 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] procfs task exe symlink
Message-ID: <20080426162458.GJ5882@ZenIV.linux.org.uk>
References: <1202348669.9062.271.camel@localhost.localdomain> <20080426091930.ffe4e6a8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080426091930.ffe4e6a8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Helsley <matthltc@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 26, 2008 at 09:19:30AM -0700, Andrew Morton wrote:

> +	set_mm_exe_file(bprm->mm, bprm->file);
> +
>  	/*
>  	 * Release all of the old mmap stuff
>  	 */
> 
> However I'd ask that you conform that this is OK.  If set_mm_exe_file() is
> independent of unshare_files() then we're OK.  If however there is some
> ordering dependency then we'll need to confirm that the present ordering of the
> unshare_files() and set_mm_exe_file() is correct.

No, that's fine (unshare_files() had to go up for a lot of reasons, one
of them being that it can fail and de_thread() called just above is
very much irreversible).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
