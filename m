Received: from ucla.edu (tetraloop.genetics.ucla.edu [149.142.163.32])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id KAA00980
	for <linux-mm@kvack.org>; Wed, 5 Jul 2000 10:23:23 -0700 (PDT)
Message-ID: <39636E66.CE21C296@ucla.edu>
Date: Wed, 05 Jul 2000 10:20:38 -0700
From: Benjamin Redelings <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: nice vmm test case
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Anyway, the swap_cnt in vmscan.c looks suspicious, maybe it's
> initiliazed too high?

The swap_cnt in vmscan.c is almost meaningless.  It is basically the
number of pages in a process that have not been scanned in the current
iteration. (where one iteration means that we scan all processes).

However, as (I think) John Fremlin has pointed out, sorting processes to
swap by this value is pointless.  

vmscan.c goes through all the pages (at least on my machine) pretty
fast, and that not all pages are found on the first iteration. If that
were NOT the case we would be in BIG trouble, because it would never
scan small processes until all the big ones had been scanned.  Also,
swap_cnt is not update when the RSS changes...
	This indicates that John's patch should be worth trying out...

We are eagerly awaiting patches for active/inactive lists :) :)

-BenRI
P.S. Please correct me if I'm wrong...
--
"For nature does not give virtue,
 It is an art to become good." - Seneca
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
