From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Fri, 28 Oct 2005 20:44:42 +0200
References: <1130366995.23729.38.camel@localhost.localdomain> <200510281910.39646.blaisorblade@yahoo.it> <20051028182842.GA8514@ccure.user-mode-linux.org>
In-Reply-To: <20051028182842.GA8514@ccure.user-mode-linux.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510282044.43492.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 28 October 2005 20:28, Jeff Dike wrote:
> On Fri, Oct 28, 2005 at 07:10:39PM +0200, Blaisorblade wrote:
> > It may be good when the patch is already really polished, IMHO, but not
> > for verifying what's really wrong.
> >
> > Also, you can gdb an UML running with the patch, to verify what's going
> > on.
> >
> > But I wouldn't suggest testing this with nested UMLs - using that means
> > looking for trouble.
>
> I think he's looking for test cases, not debugging this inside a UML.

> If he's debugging on hardware, then nesting UMLs doesn't come into the
> picture.
In fact, I'm suggesting debugging this with UML as debuggee kernel. I've used 
that _a lot_ for my remap_file_pages work. And then the nested UML thing 
_does_ comes into the picture.
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
