Date: Mon, 9 Oct 2000 14:44:48 -0700 (PDT)
From: jg@pa.dec.com (Jim Gettys)
Message-Id: <200010092144.OAA02051@pachyderm.pa.dec.com>
In-Reply-To: <Pine.LNX.4.10.10010091435420.1438-100000@penguin.transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Date: Mon, 9 Oct 2000 14:38:10 -0700 (PDT), Linus Torvalds <torvalds@transmeta.com>
said:

> 
> The problem is that there is no way to keep track of them afterwards.
> 
> So the process that gave X the bitmap dies. What now? Are we going to
> depend on X un-counting the resources?
> 

X has to uncount the resources already, to free the memory in the X server
allocated on behalf of that client.  X has to get this right, to be a long
lived server (properly debugged X servers last many months without problems:
unfortunately, a fair number of DDX's are buggy).

					- Jim

--
Jim Gettys
Technology and Corporate Development
Compaq Computer Corporation
jg@pa.dec.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
