Received: from localhost (elowe@localhost)
	by myrile.madriver.k12.oh.us (8.9.3/8.9.3) with ESMTP id HAA39040
	for <linux-mm@kvack.org>; Wed, 11 Oct 2000 07:34:08 -0400 (EDT)
	(envelope-from elowe@myrile.madriver.k12.oh.us)
Date: Wed, 11 Oct 2000 07:34:08 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: page-cluster tuning
Message-ID: <Pine.BSF.4.10.10010110729380.38557-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Over the weekend I played with page-cluster after booting my
box with mem=8M.  I ran a kernel build and updatedb simultaneously
driving it into the swap rather heavily during I/O and found that
_both_ processes made much more progress with page-cluster set
to 8 than to 4, and the default of 2 was painfully slow because
it didn't swap agressively enough.

I have yet to do any streaming I/O while swapping tests, but
should get to it later in the week.  Would anybody like to
confirm my results that 8 appears to be an optimum value for
page-cluster in 8MB?

More to come..

--
Eric Lowe
Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
