Date: Fri, 07 Apr 2006 12:10:15 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch:003/004] wait_table and zonelist initializing for memory hotadd (wait_table initialization)
In-Reply-To: <1144361104.9731.190.camel@localhost.localdomain>
References: <20060405195913.3C45.Y-GOTO@jp.fujitsu.com> <1144361104.9731.190.camel@localhost.localdomain>
Message-Id: <20060407104859.EBED.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2006-04-05 at 20:01 +0900, Yasunori Goto wrote:
> > 
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> >  static inline unsigned long wait_table_size(unsigned long pages)
> >  {
> >         unsigned long size = 1;
> > @@ -1803,6 +1804,17 @@ static inline unsigned long wait_table_s
> >  
> >         return max(size, 4UL);
> >  }
> > +#else
> > +/*
> > + * XXX: Because zone size might be changed by hot-add,
> > + *      It is hard to determin suitable size for wait_table as
> > traditional.
> > + *      So, we use maximum size now.
> > + */
> > +static inline unsigned long wait_table_size(unsigned long pages)
> > +{
> > +       return 4096UL;
> > +}
> > +#endif 
> 
> Sorry for the slow response.  My IBM email is temporarily dead.
> 
> Couple of things.  
> 
> First, is there anything useful that prepending UL to the constants does
> to the functions?  It ends up looking a little messy to me.

I would like to show that it is max size of original wait_table_size().
Original one uses 4096UL for it.

> Also, I thought you were going to put a big fat comment on there about
> doing it correctly in the future.  It would also be nice to quantify the
> wasted space in terms of bytes, just so that people get a feel for it.

Hmmm. Ok.

> Oh, and wait_table_size() needs a unit.  wait_table_size_bytes() sounds
> like a winner to me.

This size doesn't mean bytes. It is hash table entry size.
So, wait_table_hash_size() or wait_table_entry_size() might be better.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
