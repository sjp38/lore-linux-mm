Date: Wed, 2 Jul 2003 14:07:03 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: What to expect with the 2.6 VM
In-Reply-To: <461030000.1057165809@flay>
Message-ID: <Pine.LNX.4.44.0307021406040.31191-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jul 2003, Martin J. Bligh wrote:

> Maybe I'm just taking this out of context, and it's twisting my brain,
> but as far as I know, the nonlinear vma's *are* backed by pte_chains.

They are, but IMHO they shouldn't be.  The nonlinear vmas are used
only for database shared memory segments and other "bypass the VM"
applications, so I don't see any reason why we need to complicate
things hopelessly in order to deal with corner cases like truncate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
