Subject: Re: John Fremlin's swap patch
References: <393D134F.D1F93FD@ucla.edu>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 07 Jun 2000 18:08:39 +0100
In-Reply-To: Benjamin Redelings I's message of "Tue, 06 Jun 2000 08:05:52 -0700"
Message-ID: <m2g0qpa06g.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Redelings I <bredelin@ucla.edu> writes:

> Your analysis of the problems with the current use of swap_cnt seems
> accurate - though i don't know much about cache miss speeds and such.  I
> guess the problem won't fully be solved until the swapping routine is
> based on pages instead of processes, and can scan pages on the inactive
> list only.

I agree. My patch was just a quick hack, the root of the problem is to
get a good way of finding pages to swap out.

I agree that going through the set of pages that can be discarded is
more reasonable (and logically less complex though I haven't got a
clear picture of how difficult it is to implement).

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
