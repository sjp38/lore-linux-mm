Message-ID: <46A85D95.509@kingswood-consulting.co.uk>
Date: Thu, 26 Jul 2007 09:38:45 +0100
From: Frank Kingswood <frank@kingswood-consulting.co.uk>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	<200707102015.44004.kernel@kolivas.org>	<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	<46A57068.3070701@yahoo.com.au>	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	<46A58B49.3050508@yahoo.com.au>	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	<46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de>
In-Reply-To: <p73abtkrz37.fsf@bingen.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> One simple way to fix this would be to implement a fadvise() flag
> that puts the dentry/inode on a "soon to be expired" list if there
> are no other references. Then if a dentry allocation needs more
> memory try to reuse dentries from that list (or better queue) first. Any other
> access will remove the dentry from the list. 
> 
> Disadvantage would be that the userland would need to be patched,
> but I guess it's better than adding very dubious heuristics to the
> kernel.

Are you going to change every single large memory application in the 
world? As I wrote before, it is *not* about updatedb, but about all 
applications that use a lot of memory, and then terminate.

Frank

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
