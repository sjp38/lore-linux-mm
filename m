From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GPL question: using large contiguous memory in proprietary driver.
Date: Wed, 15 Oct 2008 22:26:00 +1100
References: <3f43f78b0810141456r159d71e7h9763e50e7dbc0c51@mail.gmail.com> <48F5193B.1010601@nortel.com> <3f43f78b0810141639w4ec50a08tdc847b16ebcea5be@mail.gmail.com>
In-Reply-To: <3f43f78b0810141639w4ec50a08tdc847b16ebcea5be@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810152226.00668.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kaz Kylheku <kkylheku@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
Cc: Chris Friesen <cfriesen@nortel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 15 October 2008 10:39, Kaz Kylheku wrote:
> On Tue, Oct 14, 2008 at 3:12 PM, Chris Friesen <cfriesen@nortel.com> wrote:
> > Kaz Kylheku wrote:
> >> I have the following question. Suppose that some proprietary driver
> >> (otherwise completely clean, based only on non-GPL symbols)
> >
> > The fact that it's not using GPL symbols does not actually mean that the
> > driver is not a derivative work of the kernel (and thus subject to the
> > GPL).
>
> One more thing. Here is another question.

I don't know if there are any lawyers on this list, and definitely you
shouldn't take this kind of advice from answers here.


> Suppose that this proprietary driver can be moved entirely into user
> space. It still needs the contiguous buffer, but it can
> map it using mmap, given the address.

The kernel carries a license that states:

'NOTE! This copyright does *not* cover user programs that use kernel
 services by normal system calls - this is merely considered normal use
 of the kernel, and does *not* fall under the heading of "derived work".'

Which could be relevant.


> Can this proprietary user-space application read the address
> of this buffer from a custom /proc entry?
>
> Or does this dependency make it a derived work of the kernel?

I would be careful if you were to explicitly modify the kernel you
distribute with the driver in order to allow your driver to live
in userspace. No idea whether that is safe.

However, we do have this pagemap proc API existing in the kernel
which is a kernel service that can be used with a normal system
call. It returns the page frame number that a given virtual address
is mapped to. (God knows WTF that is supposed to be a remotely good
idea for the kernel to export, but there you have it.)

Whether that helps you or allows you to comply with your obligations,
I don't know.

Or, as an alternative, why not instead run the gauntlet with your
other licensor and tell them their license isn't acceptable because
your product contains code with incompatible restrictions?!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
