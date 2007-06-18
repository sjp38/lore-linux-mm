Date: Mon, 18 Jun 2007 09:45:29 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] mm: More __meminit annotations.
Message-ID: <20070618074529.GA21222@uranus.ravnborg.org>
References: <20070618045229.GA31635@linux-sh.org> <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 02:49:24PM +0900, Yasunori Goto wrote:
> >  }
> >  
> > -static inline unsigned long zone_absent_pages_in_node(int nid,
> > +static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> >  						unsigned long zone_type,
> >  						unsigned long *zholes_size)
> >  {
> 
> I thought __meminit is not effective for these static functions,
> because they are inlined function. So, it depends on caller's 
> defenition. Is it wrong? 

As we do not _know_ if a given function is inline or not it definitely
makes sense to mark them as __meminit.
If the compiler then decides to inline the function we are all clear and
no problems. If the compiler decides not to inline the function we will
properly discard the code after init has completed so again all clear.

And btw. some people (including myself) consider it a bug that gcc inline
a function that is forced to a specific section into a function that belongs
to another section. Now gcc people has another view but that may change.
So again defining a function as __meminit makes sense no matter the
section marker.

For the technical merit whay a function is marker inline in the first place.
It must be assumed this is a hot path where it is benificial to do so.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
