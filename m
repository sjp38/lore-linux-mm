Message-ID: <393D134F.D1F93FD@ucla.edu>
Date: Tue, 06 Jun 2000 08:05:52 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: John Fremlin's swap patch
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John, I haven't had a chance to test your patch yet, but I will be
sure to try it when I get the chance.

Your analysis of the problems with the current use of swap_cnt seems
accurate - though i don't know much about cache miss speeds and such.  I
guess the problem won't fully be solved until the swapping routine is
based on pages instead of processes, and can scan pages on the inactive
list only.

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
