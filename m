Date: Tue, 8 Jun 2004 12:25:43 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: What happened to try_to_swap_out()?
In-Reply-To: <40C5D43F.4060601@ammasso.com>
Message-ID: <Pine.LNX.4.44.0406081224590.23676-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <timur.tabi@ammasso.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2004, Timur Tabi wrote:

> it's something about that function swapping out reserved pages, which I 
> presume it shouldn't do.  Because of this bug, we had to implement a 
> work-around in our driver.

Looks like the bug is in your driver, not the VM.

The VMA that maps such pages should be set VM_RESERVED
(or whatever the name of that flag was)

> Also, I noticed that RedHat 9.0 doesn't have try_to_swap_out() either. 
> I guess they ported some 2.6 code to 2.4.  Can anyone corroborate that?

Yes.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
