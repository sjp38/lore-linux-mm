Subject: Re: [PATCH] OOM handling
References: <3ABDF8A6.7580BD7D@evision-ventures.com>
	<l03130321b6e3c0533688@[192.168.239.101]>
	<l03130322b6e3ced39e99@[192.168.239.101]>
From: buhr@stat.wisc.edu (Kevin Buhr)
In-Reply-To: Jonathan Morton's message of "Sun, 25 Mar 2001 17:36:21 +0100"
Date: 26 Mar 2001 15:34:31 -0600
Message-ID: <vba4rwgtdso.fsf@mozart.stat.wisc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Martin Dalecki <dalecki@evision-ventures.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton <chromi@cyberspace.org> writes:
>
> Understood - my Physics courses covered this as well, but not using the
> word "normalise".

Be that as it may, Martin's comments about normalizing are nonsense.
Rik's killer (at least in 2.4.3-pre7) produces a badness value that's
a product of badness factors of various units.  It then uses these
products only for relative comparisons, choosing the process with
maximum badness product to kill.  No normalization is necessary, nor
would it have any effect.

The reason a 256 Meg process on a 1 Gig machine was being killed had
nothing to do with normalization---it was a bug where the OOM killer
was being called long before we were reduced to last resorts.

Kevin <buhr@stat.wisc.edu>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
