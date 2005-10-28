From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Fri, 28 Oct 2005 19:55:09 +0200
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org>
In-Reply-To: <20051028034616.GA14511@ccure.user-mode-linux.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510281955.09615.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>, Theodore Ts'o <tytso@mit.edu>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Oct 27, 2005 at 06:42:36PM -0700, Badari Pulavarty wrote:
> > Like Andrea mentioned MADV_DONTNEED should be able to do what JVM
> > folks want. If they want more than that, get in touch with me.
> > While doing MADV_REMOVE, I will see if I can satsify their needs also.

> Well, I asked if what he wanted was simply walking all of the page
> tables and marking the indicated pages as "clean",
This idea sounds interesting and kludgy enough :-) .
> but he claimed that 
> anything that involved walking the pages tables would be too slow.
> But it may be that he was assuming this would be as painful as
> munmap(), when of course it wouldn't be.

I am curious which is the difference between the two. I know that we must also 
walk the vma tree, and that since we bundle the pointers in the vma the 
spatial locality is very poor, but I still don't get this huge loss.

Apart for the CONFIG_PREEMPT excess case, which was just pointed out on LKML:

http://lkml.org/lkml/2005/10/27/215

(possibly point it out to your Java people, and see what they say).
> I don't know if they've 
> actually benchmarked MADV_DONTNEED or not.

-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
