Received: from chris.atenasio.net (d187.dial-2.cmb.ma.ultra.net [209.6.65.187])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA00295
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 11:53:14 -0400
Date: Tue, 18 Aug 1998 11:52:06 -0400 (EDT)
From: Chris Atenasio <root@lilo.dyn.ml.org>
Reply-To: chrisa@ultranet.com
Subject: Re: memory overcommitment
In-Reply-To: <199808171833.TAA03492@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.4.00.9808181124250.6395-100000@chris.atenasio.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Nicolas Devillard <ndevilla@mygale.org>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>


> If you can suggest a good algorithm for selecting processes to kill,
> we'd love to hear about it.  The best algorithm will not be the same for
> all users.

How bout: if(no_more_ram) kill(process_using_most_ram());

Of course to be useful it would have to add together the usage of multiple
instances of a program of the same uid(and then kill all of them too!).
Furthermore you might even want to kill uid 0 progs last.  This way hopefully an
attacker mallocing way too much or starting a fork bomb would be the one that
gets shafted.  (Maybe even write an interface to pass the offending uid to a
userspace program which can then invalidate that user account, send mail, do
cool things etc.)  Then what if you(the admin)C do something evil?
Well... don't!

- Chris
--------------------------------------------------------------------------------
Chris Atenasio (chrisa@ultranet.com) -- Friends dont let friends use Windows.
Send me mail with subject "send pgp key" or "word of the day" for autoresponse.


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
