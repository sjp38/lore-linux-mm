Received: from dax.scot.redhat.com (root@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA27691
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 04:35:21 -0500
Date: Tue, 19 Jan 1999 18:02:06 GMT
Message-Id: <199901191802.SAA05794@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <Pine.LNX.3.96.990116141939.701A-100000@laser.bogus>
References: <19990116115459.A7544@hexagon>
	<Pine.LNX.3.96.990116141939.701A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 16 Jan 1999 14:22:10 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Setting an high limit for the cache when we are low memory is easy doable.
> Comments from other mm guys?

Horrible --- smells like the old problem of "oh, our VM is hopeless at
tuning performance itself, so let's rely on magic numbers to constrain
it to reasonable performance".  I'd much much much much rather see a VM
which manages to work well without having to be constrained by tricks
like that (although by all means supply extra boundary limits for use in
special cases: just don't enable them on a default system).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
