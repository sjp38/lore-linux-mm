Received: from ucla.edu (pool0031-max8.ucla-ca-us.dialup.earthlink.net [207.217.14.223])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id QAA28048
	for <linux-mm@kvack.org>; Fri, 5 May 2000 16:01:51 -0700 (PDT)
Message-ID: <39128155.F881ACC5@ucla.edu>
Date: Fri, 05 May 2000 01:07:49 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: [DATAPOINT] pre7-6 will not swap
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
	I just compiled pre7-6.  It seems more useable than pre7-5.  However,
it basically does not swap.  The first time there is any memory
pressure, it swaps 32 pages (128k), and it never swaps again. 
	In similar circumstances, pre7-4 has gotten up to 30Mb swapped.  There
are many unused daemons running in my 64Mb RAM.

	I also reverted to
  count = nr_threads / (priority +1)
 	though I didn't check carefully what this did.  Anyway, it doesn't
seem to make a difference.	

</datapoint>

-BenRI

UP PPro, IDE, 64MB RAM
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
