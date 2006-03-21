Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and
	balanced mlock-LRU semantic
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <5c49b0ed0603201552j58150a18lbf4d0a9b0406d175@mail.gmail.com>
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
	 <1142862078.3114.47.camel@laptopd505.fenrus.org>
	 <5c49b0ed0603201552j58150a18lbf4d0a9b0406d175@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 21 Mar 2006 08:10:52 +0100
Message-Id: <1142925053.3077.6.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Cc: Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-20 at 15:52 -0800, Nate Diller wrote:
> On 3/20/06, Arjan van de Ven <arjan@infradead.org> wrote:
> > > 1. Posix mlock/munlock/mlockall/munlockall.
> > >    Get mlock/munlock/mlockall/munlockall to Posix definiton: transaction-like,
> > >    just as described in the manpage(2) of mlock/munlock/mlockall/munlockall.
> > >    Thus users of mlock system call series will always have an clear map of
> > >    mlocked areas.
> > > 2. More consistent LRU semantics in Memory Management.
> > >    Mlocked pages is placed on a separate LRU list: Wired List.
> >
> > please give this a more logical name, such as mlocked list or pinned
> > list
> 
> Shaoping, thanks for doing this work, it is something I have been
> thinking about for the past few weeks.  It's especially nice to be
> able to see how many pages are pinned in this manner.
> 
> Might I suggest calling it the long_term_pinned list?  It also might
> be worth putting ramdisk pages on this list, since they cannot be
> written out in response to memory pressure.  This would eliminate the
> need for AOP_WRITEPAGE_ACTIVATE.

I like that idea



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
