Date: Wed, 27 Oct 2004 10:36:48 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
Message-ID: <30640000.1098898608@flay>
In-Reply-To: <417FC5CB.9040204@pobox.com>
References: <58cb370e041027074676750027@mail.gmail.com> <417FBB6D.90401@pobox.com> <1246230000.1098892359@[10.10.2.4]> <417FC5CB.9040204@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "Randy.Dunlap" <rddunlap@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> Unfortunately, it's not.
> 
> The block layer just tells us "it's a contiguous run of memory", which implies nothing really about the allocation size.
> 
> Bart and I (and others?) essentially need a "page+1" thing (for 2.4.x too!), that won't break in the face of NUMA/etc.
> 
> Alternatively (or additionally), we may need to make sure the block layer doesn't merge across zones or NUMA boundaries or whatnot.


The latter would be rather more efficient. I don't know how often you 
end up doing each operation though ... the page+1 vs the attemtped merge.
Depends on the ratio,  I guess.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
