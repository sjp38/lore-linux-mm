Date: Fri, 28 Oct 2005 22:51:19 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051029025119.GA14998@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com> <20051028184235.GC8514@ccure.user-mode-linux.org> <1130544201.23729.167.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130544201.23729.167.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 28, 2005 at 05:03:21PM -0700, Badari Pulavarty wrote:
> Here is the update on the patch.
> 
> I found few bugs in my shmem_truncate_range() (surprise!!)
> 	- BUG_ON(subdir->nr_swapped > offset);
> 	- freeing up the "subdir" while it has some more entries
> 	swapped.
> 
> I wrote some tests to force swapping and working out the bugs.
> I haven't tried your test yet, since its kind of intimidating :(

Well, then send me the patch since I don't find this the least bit 
intimidating :-)

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
