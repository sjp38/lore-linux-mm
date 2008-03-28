From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: down_spin() implementation
Date: Sat, 29 Mar 2008 00:48:21 +0100
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <20080328124517.GQ16721@parisc-linux.org> <1FE6DD409037234FAB833C420AA843ECF237C0@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECF237C0@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200803290048.22931.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Nick Piggin <nickpiggin@yahoo.com.au>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 28 March 2008, Luck, Tony wrote:
> > So it makes little sense to add this to semaphores.  Better to introduce
> > a spinaphore, as you say.
> 
> > struct {
> >   atomic_t cur;
> >   int max;
> > } ss_t;
> 
> Could this API sneak into the bottom of one or the other of
> linux/include/{spinlock,semaphore}.h ... or should it get its own
> spinaphore.h file?
>
> Or should I follow Alan's earlier advice and keep this as an ia64
> only thing (since I'll be the only user).

If you use the simple version suggested last by Willy, I think it
could even be open-coded in your TLB management code.

Should we decided to make it an official interface, I'd suggest
putting it into atomic.h, because it operates on a plain atomic_t.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
