Received: from HOKEY-POKEY-MILES.MIT.EDU (HOKEY-POKEY-MILES.MIT.EDU [18.243.0.30])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA06714
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 17:28:38 -0500
Message-Id: <199812082228.RAA24523@HOKEY-POKEY-MILES.MIT.EDU>
Subject: 2.1.131ac5 VM/MM performance in 4MB
Date: Tue, 08 Dec 1998 17:28:30 EST
From: "Ethan M. O'Connor" <zudark@MIT.EDU>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

I haven't done any quantitative measurements, but to be honest
I really don't need to... 2.1.131ac5 (which appears to include Rik van Riel
and Stephen Tweedie's latest MM patches) is _dramatically_ faster under all
circumstances I've seen than any previous kernel on a 4MB 386SX/16.
I have a feeling that percentages or multiples are fairly meaningless
to quote, but it feels easily two to three times as fast for interactivity
and program launch compared to 2.0.36. The difference is really rather
staggering. Bravo! :)

ethan o'connor
zudark@mit.edu

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
