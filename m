Message-ID: <3D744BE8.4EB2DFB7@zip.com.au>
Date: Mon, 02 Sep 2002 22:43:04 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: About the free page pool
References: <3D73CB28.D2F7C7B0@zip.com.au> <218D9232-BEBF-11D6-A3BE-000393829FA4@cs.amherst.edu> <3D740C35.9E190D04@zip.com.au> <20020903051204.GG18114@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Mon, Sep 02, 2002 at 06:11:17PM -0700, Andrew Morton wrote:
> > Note that the kernel statically allocates about 10M when it boots.  This
> > is basically a bug, and fixing it is a matter of running around shouting
> > at people.  This will happen ;)  This is the low-hanging fruit.
> 
> Are you referring to boot-time allocations using get_free_pages()
> instead of bootmem? Killing those off would be nice, yes. It limits
> the size of some hash tables on larger machines where "proportional
> to memory" means "bigger than MAX_ORDER". (Changing the algorithms to
> not use gargantuan hash tables might also be an interesting exercise
> but one I've not got the bandwidth to take on.)

Nope.  I'm referring to 1.5 megabytes lost to anonymous kmallocs,
two or three megabytes of biovec mempools, etc.  And that's with
NR_CPUS=4, and that's excluding all the statically allocated
array[NR_CPUS]s.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
