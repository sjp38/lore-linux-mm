Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA00416
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 10:25:50 -0400
Subject: Re: Thread implementations...
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
	<199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
	<m1pvfy3x8f.fsf@flinx.npwt.net> <qww4sx8r44b.fsf@p21491.wdf.sap-ag.de>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 26 Jun 1998 09:16:14 -0500
In-Reply-To: Christoph Rohland's message of 26 Jun 1998 09:53:08 +0200
Message-ID: <m1k964fdu9.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Christoph Rohland <hans-christoph.rohland@sap-ag.de>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "CR" == Christoph Rohland <hans-christoph.rohland@sap-ag.de> writes:

CR> I do not agree:

CR> 1) why should madvise only advise. O.K. it is a naming thing, but I
CR>    think you can find more terms which went far from the original
CR>    meaning.

Because if it only advises, you can ignore it and return success.
If it does more than advise you have to do much more error checking
and error handling.  If it turns out we want to give lots of advise in
one syscall, instead of just one piece of advise, this could be
important.


CR> 2) Would not work on shared pages.
Not perfectly.  That does appear to be the achillies heel currently of
madvise.  Multiple users of the same memory.

CR> 3) Why is IRIX more reasonable than any other implementation?
Well IRIX also sync with the sun man page and my intuition.
I am thinking in terms of swapping hints, and specific functionality
doesn't fit into that category.

CR> The functionality described in the OSF manpage greatly help
CR> transactional programs, which use loads of memory for single
CR> transactions. I do not know if it should be done with madvise, but
CR> there is at least one OS which thinks it is the right place and I
CR> would look for this functionality exactly there.

I hadn't considered the transaction case.  In fact I haven't
considered most cases. That's partly why I'm still talking.

But still there are other more portable methods to achieve a memory
reset, as I mentioned earlier.   And there isn't another even semi
portable method to achieve swapping hints.

Eric
