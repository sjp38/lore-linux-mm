Date: Fri, 4 Apr 2003 16:58:37 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030404165837.A21390@redhat.com>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain> <20030404105417.3a8c22cc.akpm@digeo.com> <20030404214547.GB16293@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030404214547.GB16293@dualathlon.random>; from andrea@suse.de on Fri, Apr 04, 2003 at 11:45:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2003 at 11:45:47PM +0200, Andrea Arcangeli wrote:
> Maybe I'm missing something, I'm curious to hear what you think and what
> other cases needs this syscall even after 1) and 2) are fixed.

It's useful for UML and emulators that simulate page tables too.

		-ben
-- 
Junk email?  <a href="mailto:aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
