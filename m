Subject: Re: broken VM in 2.4.10-pre9
Date: Wed, 19 Sep 2001 20:45:55 +0100 (BST)
In-Reply-To: <20010919093828Z17304-2759+92@humbolt.nl.linux.org> from "Daniel Phillips" at Sep 19, 2001 11:45:44 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15jnIB-0003gh-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On September 17, 2001 06:03 pm, Eric W. Biederman wrote:
> > In linux we have avoided reverse maps (unlike the BSD's) which tends
> > to make the common case fast at the expense of making it more
> > difficult to handle times when the VM system is under extreme load and
> > we are swapping etc.
>
> What do you suppose is the cost of the reverse map?  I get the impression you
> think it's more expensive than it is.

We can keep the typical page table cost lower than now (including reverse
maps) just by doing some common sense small cleanups to get the page struct
down to 48 bytes on x86

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
