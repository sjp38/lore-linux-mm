Date: Wed, 27 Oct 2004 17:31:11 -0400
From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
Message-ID: <20041027213111.GA13627@havoc.gtf.org>
References: <58cb370e041027074676750027@mail.gmail.com> <417FBB6D.90401@pobox.com> <1246230000.1098892359@[10.10.2.4]> <1246750000.1098892883@[10.10.2.4]> <417FCE4E.4080605@pobox.com> <20041027142914.197c72ed.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041027142914.197c72ed.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bzolnier@gmail.com, rddunlap@osdl.org, wli@holomorphy.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2004 at 02:29:14PM -0700, Andrew Morton wrote:
> spose so.  The scatterlist API is being a bit silly there.

Well, it depends on your perspective :)

Each scatterlist entry is supposed to map to a physical segment to be
passed to h/w.  Hardware S/G tables just want to see a addr/len pair,
and don't care about machine page size.  scatterlist follows a similar
model.

dma_map_sg() and other helpers create a favorable situation, where >90%
of the drivers don't have to care about the VM-size details.
Unfortunately those drivers that need need to do their own data transfer
(like ATA's PIO, instead of DMA) need direct access to each member of an
s/g list.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
