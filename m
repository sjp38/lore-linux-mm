Message-ID: <42161FBF.70200@sgi.com>
Date: Fri, 18 Feb 2005 11:02:55 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
 II
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> <m1vf8yf2nu.fsf@muc.de> <42114279.5070202@sgi.com> <20050215121404.GB25815@muc.de> <421241A2.8040407@sgi.com> <20050215214831.GC7345@wotan.suse.de> <4212C1A9.1050903@sgi.com> <20050217235437.GA31591@wotan.suse.de>
In-Reply-To: <20050217235437.GA31591@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andi Kleen <ak@muc.de>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> You and Robin mentioned some problems with "double migration"
> with that, but it's still not completely clear to me what
> problem you're solving here. Perhaps that needs to be reexamined.
> 
> 
There is one other case where Robin and I have talked about double
migration.  That is the case where the set of old nodes and new
nodes overlap.  If one is not careful, and the system call interface
is assumed to be something like:

page_migrate(pid, old_node, new_node);

then if one is not careful (and depending on what the complete list
of old_nodes and new_nodes are), then if one does something like:

page_migrate(pid, 1, 2);
page_migrate(pid, 2, 3);

then you can end up actually moving pages from node 1 to node 2,
only to move them again from node 2 to node 3.  This is another
form of double migration that we have worried about avoiding.

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
