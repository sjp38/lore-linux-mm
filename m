Received: from vcmr-19.rcs.rpi.edu (vcmr-19.rcs.rpi.edu [128.113.113.12])
	by mail.rpi.edu (8.11.3/8.11.3) with ESMTP id f6KISK4130412
	for <linux-mm@kvack.org>; Fri, 20 Jul 2001 14:28:20 -0400
Received: from localhost (laprej@localhost)
	by vcmr-19.rcs.rpi.edu (8.8.5/8.8.6) with SMTP id OAA16656
	for <linux-mm@kvack.org>; Fri, 20 Jul 2001 14:27:58 -0400
Date: Fri, 20 Jul 2001 14:27:58 -0400 (EDT)
From: Justin Michael LaPre <laprej@rpi.edu>
Subject: Support for Intel 4MB Pages
Message-ID: <Pine.A41.3.96.1010720142345.25692A-100000@vcmr-19.rcs.rpi.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

beneficial to use 4MB pages.  Some people on IRC suggested the community
might appreciate such a patch.  Would this be well-accepted?  Designing it
to be general instead of just for our purposes would be more difficult,
but we would be willing to put in the time if people actually want it.
	If it were to be implemented, what would be the best strategy?  A
new memory zone?  Re-working the mm system to try and not break up chunks
of 4MB if possible?  Any comments would be greatly appreciated.  Thanks.

-Justin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
