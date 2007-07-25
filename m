Date: Wed, 25 Jul 2007 13:50:12 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: -mm merge plans for 2.6.23
Message-ID: <20070725115012.GB27498@elte.hu>
References: <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com> <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com> <20070725113401.GA23341@elte.hu> <46A736C9.4090701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A736C9.4090701@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Valdis.Kletnieks@vt.edu, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Rene Herman <rene.herman@gmail.com> wrote:

> > and the fact is: updatedb discards a considerable portion of the 
> > cache completely unnecessarily: on a reasonably complex box no way 
> > do all the inodes and dentries fit into all of RAM, so we just trash 
> > everything.
> 
> Okay, but unless I've now managed to really quite horribly confuse 
> myself, that wouldn't have anything to do with _swap_ prefetch would 
> it?

it's connected: it would remove updatedb from the VM picture altogether. 
(updatedb would just cycle through the files with leaving minimal cache 
disturbance.)

hence swap-prefetch could concentrate on the cases where it makes sense 
to start swap prefetching _without_ destroying other, already cached 
content: such as when a large app exits and frees gobs of memory back 
into the buddy allocator. _That_ would be a definitive "no costs and 
side-effects" point for swap-prefetch to kick in, and it would eliminate 
this pretty artificial (and unnecessary) 'desktop versus server' 
controversy and would turn it into a 'helps everyone' feature.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
