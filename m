Date: Fri, 3 Oct 2003 23:41:23 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] fix split_vma vs. invalidate_mmap_range_list race
Message-Id: <20031003234123.11b2bd73.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0310040223230.27636-100000@cello.eecs.umich.edu>
References: <20031003224056.09421fb1.akpm@osdl.org>
	<Pine.LNX.4.44.0310040223230.27636-100000@cello.eecs.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>
Cc: davem@redhat.com, hch@lst.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu> wrote:
>
> 
> > 
> > It looks OK.  I updated the VM lock ranking docco to cover this.
> 
> >   *
> > + *  ->i_sem
> > + *    ->i_shared_sem		(truncate->invalidate_mmap_range)
> > + *
> 
> I don't understand how my patch introduced this new(?) ordering.

It did not: I just added this as I was reviewing the code, because it was
missing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
