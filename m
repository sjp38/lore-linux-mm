Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA14484
	for <linux-mm@kvack.org>; Mon, 29 Jun 1998 07:42:34 -0400
Date: Mon, 29 Jun 1998 11:19:37 +0100
Message-Id: <199806291019.LAA00726@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations...
In-Reply-To: <m1k964fdu9.fsf@flinx.npwt.net>
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
	<199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
	<m1pvfy3x8f.fsf@flinx.npwt.net>
	<qww4sx8r44b.fsf@p21491.wdf.sap-ag.de>
	<m1k964fdu9.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 26 Jun 1998 09:16:14 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

>>>>>> "CR" == Christoph Rohland <hans-christoph.rohland@sap-ag.de> writes:

CR> 1) why should madvise only advise. 

> Because if it only advises, you can ignore it and return success.
> If it does more than advise you have to do much more error checking
> and error handling.  

Not necessarily; even if we do take immediate action on the advise,
within the madvise system call, we don't have to do any extra layers of
error handling.   It's more a case of "Please try to do this now / OK, I
tried."

CR> 2) Would not work on shared pages.
> Not perfectly.  That does appear to be the achillies heel currently of
> madvise.  Multiple users of the same memory.

Again, madvise is the application telling us that it KNOWS what the
access pattern is.  If the app is wrong, and the page is shared, big
deal; throw away the advise, it was duff. :)

--Stephen
