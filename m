Subject: Re: broken VM in 2.4.10-pre9
References: <E15jnIB-0003gh-00@the-village.bc.nu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 19 Sep 2001 15:37:26 -0600
In-Reply-To: <E15jnIB-0003gh-00@the-village.bc.nu>
Message-ID: <m1elp2g8vd.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> > On September 17, 2001 06:03 pm, Eric W. Biederman wrote:
> > > In linux we have avoided reverse maps (unlike the BSD's) which tends
> > > to make the common case fast at the expense of making it more
> > > difficult to handle times when the VM system is under extreme load and
> > > we are swapping etc.
> >
> > What do you suppose is the cost of the reverse map?  I get the impression you
>
> > think it's more expensive than it is.
>
> We can keep the typical page table cost lower than now (including reverse
> maps) just by doing some common sense small cleanups to get the page struct
> down to 48 bytes on x86

While there is a size cost I suspect you will notice reverse maps
a lot more in operations like fork where having them tripples the amount
of memory that you need to copy.  So you should see a double or more
in the time it takes to do a fork.

That I think is a significant cost.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
