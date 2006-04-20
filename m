Date: Thu, 20 Apr 2006 16:46:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage address space op to
 shmem
Message-Id: <20060420164625.5009e935.akpm@osdl.org>
In-Reply-To: <1145548859.5214.9.camel@localhost.localdomain>
References: <1145548859.5214.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
>
>  Add migratepage address space op to shmem
> 
>  Basic problem:  pages of a shared memory segment can only be
>  migrated once.
> 
>  In 2.6.16 through 2.6.17-rc1, shared memory mappings do not
>  have a migratepage address space op.  Therefore, migrate_pages()
>  falls back to default processing.

This sounds to me like a bugfix-for-2.6.17 rather than a "PATCH
2.6.17-rc1-mm3"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
