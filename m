Date: Sun, 11 May 2003 15:15:06 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Slab corruption mm3 + davem fixes
Message-Id: <20030511151506.172eee58.akpm@digeo.com>
In-Reply-To: <1052690490.4471.2.camel@rth.ninka.net>
References: <20030511031940.97C24251B@oscar.casa.dyndns.org>
	<200305111221.26048.tomlins@cam.org>
	<1052690490.4471.2.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: tomlins@cam.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, laforge@netfilter.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
> On Sun, 2003-05-11 at 09:21, Ed Tomlinson wrote:
> > I am also seeing this on 69-bk (as of Sunday morning)
> ...
> > On May 10, 2003 11:19 pm, Ed Tomlinson wrote:
> > > I looked at my logs and found the following error in it.  My kernel is
> > > 69-mm3 with two davem fixes on it.
> ...
> > > May 10 22:41:06 oscar kernel: Call Trace:
> > > May 10 22:41:06 oscar kernel:  [__slab_error+30/32] __slab_error+0x1e/0x20
> > > May 10 22:41:06 oscar kernel:  [check_poison_obj+376/384]
> > > check_poison_obj+0x178/0x180 May 10 22:41:06 oscar kernel: 
> > > [kmalloc+221/392] kmalloc+0xdd/0x188 May 10 22:41:06 oscar kernel: 
> > > [alloc_skb+64/240] alloc_skb+0x40/0xf0 May 10 22:41:06 oscar kernel: 
> 
> Yeah, more bugs in the NAT netfilter changes.  Debugging this one
> patch is becomming a full time job :-(
> 
> This should fix it.  Rusty, you're computing checksums and mangling
> src/dst using header pointers potentially pointing to free'd skbs.
> 

Did you mean to send a one megabyte diff?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
