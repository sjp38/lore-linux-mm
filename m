Date: Mon, 24 Apr 2006 18:01:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page host virtual assist patches.
Message-Id: <20060424180138.52e54e5c.akpm@osdl.org>
In-Reply-To: <20060424123412.GA15817@skybase>
References: <20060424123412.GA15817@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
>  The basic idea of host virtual assist (hva) is to give a host system
>  which virtualizes the memory of its guest systems on a per page basis
>  usage information for the guest pages. The host can then use this
>  information to optimize the management of guest pages, in particular
>  the paging. This optimizations can be used for unused (free) guest
>  pages, for clean page cache pages, and for clean swap cache pages.

This is pretty significant stuff.  It sounds like something which needs to
be worked through with other possible users - UML, Xen, vware, etc.

How come the reclaim has to be done in the host?  I'd have thought that a
much simpler approach would be to perform a host->guest upcall saying
either "try to free up this many pages" or "free this page" or "free this
vector of pages"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
