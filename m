Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA03272
	for <linux-mm@kvack.org>; Sun, 3 Jan 1999 17:35:50 -0500
Subject: Re: Bug in the mmap code?
References: <m13e5skodi.fsf@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Jan 1999 16:36:43 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "03 Jan 1999 16:00:57 -0600"
Message-ID: <m1sodsj85g.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Dah.  We are calling fput everywhere in the generic code just fine.


Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
