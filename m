Subject: Re: broken VM in 2.4.10-pre9
Date: Thu, 20 Sep 2001 13:57:02 +0100 (BST)
In-Reply-To: <20010920112110Z16256-2757+869@humbolt.nl.linux.org> from "Daniel Phillips" at Sep 20, 2001 01:28:31 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15k3O2-0005Fr-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On September 20, 2001 12:04 am, Alan Cox wrote:
> > Reverse mappings make linear aging easier to do but are not critical (we
> > can walk all physical pages via the page map array).
>
> But you can't pick up the referenced bit that way, so no up aging, only
> down.

#1 If you really wanted to you could update a referenced bit in the page
struct in the fault handling path.

#2 If a page is referenced multiple times by different processes is the
behaviour of multiple upward aging actually wrong.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
