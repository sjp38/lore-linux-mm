Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA26576
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 11:51:31 -0400
Date: Thu, 25 Jun 1998 12:32:35 +0100
Message-Id: <199806251132.MAA00848@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations...
In-Reply-To: <199806250353.NAA17617@vindaloo.atnf.CSIRO.AU>
References: <m1u35a4fz8.fsf@flinx.npwt.net>
	<Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
	<199806250353.NAA17617@vindaloo.atnf.CSIRO.AU>
Sender: owner-linux-mm@kvack.org
To: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Cc: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 25 Jun 1998 13:53:36 +1000, Richard Gooch
<Richard.Gooch@atnf.CSIRO.AU> said:

> This may be true, but my point is that we *need* a decent madvise(2)
> implementation. It will be use to a greater range of applications than
> sendfile(2).

Not necessarily; we may be able to detect a lot of the relevant access
patterns ourselves.  Ingo has had a swap prediction algorithm for a
while, and we talked at Usenix about a number of other things we can do
to tune vm performance automatically.  2.3 ought to be a great deal
better.  madvise() may still have merit, but we really ought to be
aiming at making the vm system as self-tuning as possible.

--Stephen
