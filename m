Subject: Re: Swapping for diskless nodes
Date: Thu, 9 Aug 2001 16:13:11 +0100 (BST)
In-Reply-To: <OF452D802E.BE93E657-ON85256AA3.004E8422@pok.ibm.com> from "Bulent Abali" at Aug 09, 2001 10:26:22 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15UrUl-0007Rn-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

> Last time I checked swapping over nbd required patching the network stack.
> Because swapping occurs when memory is low and when memory is low TCP
> doesn't do what you expect it to do...

Its a case of having sufficient memory in the atomic pools. Its possible to
do some ugly quick kernel hack to make the pool commit less likely to be a 
problem.

Ultimately its an insoluble problem, neither SunOS, Solaris or NetBSD are
infallible, they just never fail for any normal situation, and thats good
enough for me as a solution
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
