Received: from ucla.edu (pool0012-max1.ucla-ca-us.dialup.earthlink.net [207.217.13.12])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id JAA04819
	for <linux-mm@kvack.org>; Fri, 12 May 2000 09:28:52 -0700 (PDT)
Message-ID: <391B5FE6.E83B419D@ucla.edu>
Date: Thu, 11 May 2000 18:35:34 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: [DATAPOINT] pre7-final slow - tries to keep 10M/64Mb free
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My experience with pre7 has not been very good.

I have 64Mb RAM - the system started swapping out when I had 15MB free.

It appears to be trying to shrink the page cache even when there is no
memory pressure.  Unlike pre7-9, pre7-final as a small page cache, and
doesn't swap out that much.  LIke pre7-9, however, it is only fair to
middling at swapping out the right pages.

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
