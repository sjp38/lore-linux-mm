Date: Mon, 2 Sep 2002 22:43:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: About the free page pool
Message-ID: <20020903054330.GH18114@holomorphy.com>
References: <3D73CB28.D2F7C7B0@zip.com.au> <218D9232-BEBF-11D6-A3BE-000393829FA4@cs.amherst.edu> <3D740C35.9E190D04@zip.com.au> <20020903051204.GG18114@holomorphy.com> <3D744BE8.4EB2DFB7@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D744BE8.4EB2DFB7@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Are you referring to boot-time allocations using get_free_pages()
>> instead of bootmem? Killing those off would be nice, yes. It limits
>> the size of some hash tables on larger machines where "proportional
>> to memory" means "bigger than MAX_ORDER". (Changing the algorithms to
>> not use gargantuan hash tables might also be an interesting exercise
>> but one I've not got the bandwidth to take on.)

On Mon, Sep 02, 2002 at 10:43:04PM -0700, Andrew Morton wrote:
> Nope.  I'm referring to 1.5 megabytes lost to anonymous kmallocs,
> two or three megabytes of biovec mempools, etc.  And that's with
> NR_CPUS=4, and that's excluding all the statically allocated
> array[NR_CPUS]s.

Slightly different then. I don't know of anyone regularly testing 2.5.x
on 4MB machines, which might need a bit of help on this front if more
memory than they have is flushed down the toilet at boot.

I've got a collection of ancient toasters but the ports aren't booting,
and for reasons far deeper than this. 4MB bochs/x86 laptop? No time. =(

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
