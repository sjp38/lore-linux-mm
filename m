Received: from ucla.edu (pool0048-max2.ucla-ca-us.dialup.earthlink.net [207.217.13.112])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id IAA19380
	for <linux-mm@kvack.org>; Tue, 4 Jul 2000 08:17:56 -0700 (PDT)
Message-ID: <396200BF.94E0938@ucla.edu>
Date: Tue, 04 Jul 2000 08:20:31 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: 2.4.0-test3-pre2: corruption in mm?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

the middle of one file, /var/lib/dpkg/status, was what seemed to be a
chunk of another file, /var/lib/dpkg/available.  I didn't check to see
if /var/lib/dpkg/available was missing any pieces, but that looks like
it could be corruption.

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
