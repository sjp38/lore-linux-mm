Subject: Re: Swapping for diskless nodes
Date: Thu, 9 Aug 2001 23:46:29 +0100 (BST)
In-Reply-To: <Pine.LNX.4.33L.0108091756420.1439-100000@duckman.distro.conectiva> from "Rik van Riel" at Aug 09, 2001 05:57:10 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15UyZR-0008IH-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 9 Aug 2001, Alan Cox wrote:
> 
> > Ultimately its an insoluble problem, neither SunOS, Solaris or
> > NetBSD are infallible, they just never fail for any normal
> > situation, and thats good enough for me as a solution
> 
> Memory reservations, with reservations on a per-socket
> basis, can fix the problem.

Only a probabalistic subset of the problem. But yes enough to make it "work"
except where mathematicians and crazy people are concerned. Do not NFS swap
on a BGP4 router with no fixed route to the server..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
