Subject: Re: Memory allocation in Linux (fwd)
References: <Pine.LNX.4.21.0204151414050.20877-100000@mailhost.tifr.res.in>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 19 Apr 2002 11:46:13 -0600
In-Reply-To: <Pine.LNX.4.21.0204151414050.20877-100000@mailhost.tifr.res.in>
Message-ID: <m14ri760pm.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Amit S. Jain" <amitjain@tifr.res.in> writes:

> You cannot pass address returned from vmalloc to hardware: vmalloc returns
> > a virtual mapping of memory.
> >
> >               -ben
> 
> 
>  Thanks Ben,
> 
> So wass the solution for this.....??

Call get_free_pages explicitly use the scatter gather support
in the network layer.  You should be able to pass a linked
list of pages.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
