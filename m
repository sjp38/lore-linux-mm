Date: Mon, 22 Nov 2004 14:27:10 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH]: 2/4 mm/swap.c cleanup
In-Reply-To: <16801.6313.996546.52706@gargle.gargle.HOWL>
Message-ID: <Pine.LNX.4.44.0411221419100.2867-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux-Kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2004, Nikita Danilov wrote:
> Andrew Morton writes:
>  > 
>  > Sorry, this looks more like a dirtyup to me ;)
> 
> Don't tell me you are not great fan on comma operator abuse. :)
> 
> Anyway, idea is that by hiding complexity it loop macro, we get rid of a
> maze of pvec-loops in swap.c all alike.
> 
> Attached is next, more typeful variant. Compilebootentested.

You're scaring me, Nikita.  Those loops in mm/swap.c are easy to follow,
whyever do you want to obfuscate them with your own macro maze?

Ingenious for_each macros make sense where it's an idiom which is going
to be useful to many across the tree; but these are just a few instances
in a single source file.

Please find a better outlet for your talents!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
