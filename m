Received: from ucla.edu (ts18-96.dialup.bol.ucla.edu [164.67.35.105])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id NAA23522
	for <linux-mm@kvack.org>; Sat, 3 Mar 2001 13:13:03 -0800 (PST)
Message-ID: <3AA15E3C.39BD9A82@ucla.edu>
Date: Sat, 03 Mar 2001 13:12:28 -0800
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [PATCH] ac7: page_launder() & refill_inactive() changes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
Content-Type: text/plain; charset=big5
Content-Transfer-Encoding: 7bit

Hi Marcelo:
	In the patch you provided, have you perhaps reverse the sense of this
test:

+                       if (try_to_free_buffers(page, wait))
+                               flushed_pages++;

Should this have a NOT (!) instead?

+                       if (!try_to_free_buffers(page, wait))
+                               flushed_pages++;

BTW, has anyone done any MM benchmarks of the 2.4.2-ac? against Linus's
tree?

-BenRI
-- 
"...assisted of course by pride, for we teach them to describe the
 Creeping Death, as Good Sense, or Maturity, or Experience." 
- "The Screwtape Letters"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
