Message-ID: <39708418.2221DB9E@ucla.edu>
Date: Sat, 15 Jul 2000 08:32:40 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: test5-pre1 VM best its EVER been!
References: <m13DObS-000OVtC@amadeus.home.nl>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan@ucla.edu, van@ucla.edu, de@ucla.edu, Ven@ucla.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I am much less happy. My 128Mb system will not stop freeing memory (from the
> buffer/page caches) until at least 16 Mb is really free. This means I
> typically end up with 400kb buffer and 20M cached, which could be much
> higher.....
	This is the same problem that I had with test3.  So I guess its still
there, but is only visible on systems with more memory than mine.
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
