From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Slab corruption mm3 + davem fixes
Date: Mon, 12 May 2003 03:44:50 -0400
References: <20030511031940.97C24251B@oscar.casa.dyndns.org> <20030511151506.172eee58.akpm@digeo.com> <1052692449.4471.4.camel@rth.ninka.net>
In-Reply-To: <1052692449.4471.4.camel@rth.ninka.net>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200305120344.50347.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>, Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, laforge@netfilter.org
List-ID: <linux-mm.kvack.org>

On May 11, 2003 06:34 pm, David S. Miller wrote:
> > > Yeah, more bugs in the NAT netfilter changes.  Debugging this one
> > > patch is becomming a full time job :-(

But you do it well...  Looks like this fixes the slab problems here with
69-bk from Sunday am.

> > > This should fix it.  Rusty, you're computing checksums and mangling
> > > src/dst using header pointers potentially pointing to free'd skbs.
> >
> > Did you mean to send a one megabyte diff?
>
> Let's try this again, here is the correct patch :-)

Thanks
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
