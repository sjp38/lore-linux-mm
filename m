Date: Thu, 20 Apr 2006 16:51:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage address space op to shmem
In-Reply-To: <20060420164625.5009e935.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604201651360.19049@schroedinger.engr.sgi.com>
References: <1145548859.5214.9.camel@localhost.localdomain>
 <20060420164625.5009e935.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2006, Andrew Morton wrote:

> >  In 2.6.16 through 2.6.17-rc1, shared memory mappings do not
> >  have a migratepage address space op.  Therefore, migrate_pages()
> >  falls back to default processing.
> 
> This sounds to me like a bugfix-for-2.6.17 rather than a "PATCH
> 2.6.17-rc1-mm3"?

Correct.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
