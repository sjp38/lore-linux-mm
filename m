Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA05895
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 09:51:07 -0400
Date: Wed, 19 Aug 1998 13:08:29 +0100
Message-Id: <199808191208.NAA00888@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory overcommitment
In-Reply-To: <Pine.LNX.4.00.9808181124250.6395-100000@chris.atenasio.net>
References: <199808171833.TAA03492@dax.dcs.ed.ac.uk>
	<Pine.LNX.4.00.9808181124250.6395-100000@chris.atenasio.net>
Sender: owner-linux-mm@kvack.org
To: chrisa@ultranet.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Nicolas Devillard <ndevilla@mygale.org>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 18 Aug 1998 11:52:06 -0400 (EDT), Chris Atenasio
<root@lilo.dyn.ml.org> said:

>> If you can suggest a good algorithm for selecting processes to kill,
>> we'd love to hear about it.  The best algorithm will not be the same for
>> all users.

> How bout: if(no_more_ram) kill(process_using_most_ram());

Very simplistic: on many systems, that will mean starting gcc takes out
the X server. :-(

> Of course to be useful it would have to add together the usage of
> multiple instances of a program of the same uid(and then kill all of
> them too!).  Furthermore you might even want to kill uid 0 progs last.

Certainly.

One thing on the agenda for consideration in 2.3 is resident set size
limits and quotas, which will allow us to cleanly reserve enough swap
and physical memory for specific uses.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
