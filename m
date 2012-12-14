Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CDE486B005D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 09:49:31 -0500 (EST)
Date: Fri, 14 Dec 2012 14:49:27 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on
 mmap
Message-ID: <20121214144927.GS4939@ZenIV.linux.org.uk>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
 <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Fri, Dec 14, 2012 at 03:14:50AM -0800, Andy Lutomirski wrote:

> > Wait a minute.  get_user_pages() relies on ->mmap_sem being held.  Unless
> > I'm seriously misreading your patch it removes that protection.  And yes,
> > I'm aware of execve-related exception; it's in special circumstances -
> > bprm->mm is guaranteed to be not shared (and we need to rearchitect that
> > area anyway, but that's a separate story).
> 
> Unless I completely screwed up the patch, ->mmap_sem is still held for
> read (it's downgraded from write).  It's just not held for write
> anymore.

Huh?  I'm talking about the call of get_user_pages() in aio_setup_ring().
With your patch it's done completely outside of ->mmap_sem, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
