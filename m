Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA06464
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 21:24:39 -0400
Date: Tue, 6 Apr 1999 03:23:53 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5 
In-Reply-To: <199904052337.TAA32120@pincoya.inf.utfsm.cl>
Message-ID: <Pine.LNX.4.05.9904060317550.6341-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Horst von Brand <vonbrand@inf.utfsm.cl>
Cc: Mark Hemment <markhe@sco.COM>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Horst von Brand wrote:

>So what? One wakes up, finds the same pointer it stashed away ==> Installs
>new page (changing pointer) via short way. Second wakes up, finds pointer
>changed ==> goes long way to do its job.
>
>Or am I overlooking something stupid?

What if the page that was at the start of the chain gets removed, the page
that we are allocing gets inserted and then the same page that gets
released before will be inserted again?


	page0 -> page1

remove page 0

	page1

anoher piece of code need ourpage and go to alloc it -> insert ourpage

	ourpage -> page1

insert page0 again

	page0 -> ourpage -> page1

Now we have alloced memory succesfully for ourpage and we are going to
insert it. page0 is still here and if we don't take the slow way we'll add
it twice:

	ourpage -> page0 -> ourpage -> page1

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
