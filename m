Received: from ucla.edu (pool0049-max3.ucla-ca-us.dialup.earthlink.net [207.217.13.177])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id MAA06854
	for <linux-mm@kvack.org>; Mon, 12 Jun 2000 12:22:19 -0700 (PDT)
Message-ID: <394538AE.18ACC2A5@ucla.edu>
Date: Mon, 12 Jun 2000 12:23:26 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [Fwd] VMM swap interactive performance
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is certainly my feeling too.
	I am using test1-ac14, and interactivity goes straight down the tubes
when updatedb is running in the background.  Switching windows in X
often takes many seconds.  And simply untarring the kernel source causes
about 6 megs of application pages to be swapped out. During the untar,
applications take about 5 second to respond (e.g. to start redrawing).
	It feels pretty bad...

This COULD be partially a result of shrink_mmap failing too early. 
Since a lot of pages that should be reaped, are not reaped, the system
has to resort to swapping.  Perhaps.

	But in any case, the interactive feel is pretty bad.
-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
