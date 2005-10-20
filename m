Date: Thu, 20 Oct 2005 13:27:57 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
Message-ID: <20051020172757.GB6590@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain> <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com> <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com> <1129651502.23632.63.camel@localhost.localdomain> <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com> <1129747855.8716.12.camel@localhost.localdomain> <20051019204732.GA9922@localhost.localdomain> <1129821065.16301.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1129821065.16301.5.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, dvhltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 20, 2005 at 08:11:05AM -0700, Badari Pulavarty wrote:
> Initial plan was to use invalidate_inode_pages2_range(). But it didn't
> really do what we wanted. So we ended up using truncate_inode_pages().
> If it really works, then I plan to add truncate_inode_pages2_range()
> to which works on a range of pages, instead of the whole file.
> madvise(DONTNEED) followed by madvise(DISCARD) should be able to drop
> all the pages in the given range.
> 
> Does this make sense ? Does this seem like right approach ?

Works for me.  I obviously have no idea about the wider vm implications of 
this - that would be Hugh's territory :-)

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
