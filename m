Date: Tue, 12 Aug 2003 15:42:01 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: Re: removing clean mapped pages
In-Reply-To: <Pine.GSO.4.51.0308121522570.23513@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.GSO.4.51.0308121541290.23513@aria.ncl.cs.columbia.edu>
References: <Pine.GSO.4.51.0308121522570.23513@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


 I meant a clean mapped frame.

Thanks,
Raghu

On Tue, 12 Aug 2003, Raghu R. Arur wrote:

>  Hi,
>
>    How does a frame, mapped to a disk file gets released to the free list.
> I do not see any place in shrink_cache() nor in try_to_swap_out() such a
> page getting released.
> What am i missing over here ?
>
>  Thanks,
>  Raghu
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
