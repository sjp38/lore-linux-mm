Date: Mon, 07 Oct 2002 11:43:46 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Breakout struct page
Message-ID: <528550000.1034016226@flay>
In-Reply-To: <20021007193036.A25200@infradead.org>
References: <1165733025.1033777103@[10.10.2.3]> <20021007193036.A25200@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Sat, Oct 05, 2002 at 12:18:23AM -0700, Martin J. Bligh wrote:
>> This very boring patch breaks out struct page into it's own header
>> file. This should allow you to do struct page arithmetic in other
>> header files using static inlines instead of horribly complex macros 
>> ... by just including <linux/struct_page.h>, which avoids dependency
>> problems.
>> 
>> (inlined to read, attatched for lower probability of mangling)
> 
> I don't like a struct_page.h in addition to page-flags.h.  I had a patch
> for early 2.5 that create <linux/page.h> with struct page and stuff that
> depends only on it (Test/Set/etc macros).  IHMO that's a nicer split,
> but people may flame me for this..

I really don't care how it breaks out, as long as I can get something that
uses inlines rather than macros ... at least 4 people have run into problems
with this, and it's just getting worse.

> I'm inclinde to resubmit that one after feature freeze.

Yeah, I got my hand slapped (correctly ;-)) for that one already ;-) 
Definitely a post-freeze thingy.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
