Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30904
	for <linux-mm@kvack.org>; Wed, 22 Jul 1998 10:28:03 -0400
Date: Wed, 22 Jul 1998 11:33:18 +0100
Message-Id: <199807221033.LAA00826@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87d8b370ge.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 18 Jul 1998 15:28:17 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> I must admit, after lot of critics I made upon page aging, that I
> believe it's the right way to go, but it should be done properly.
> Performance should be better, not worse.

Let me say one thing clearly: I'm not against page ageing (I implemented
it in the first place for the swapper), I'm against the bad tuning it
introduced.  *IF* we can fix that, then keep the ageing, sure.  However,
we need to fix it _completely_.  The non-cache-ageing scheme at least
has the advantage that we understand its behaviour, so fiddling too much
this close to 2.2 is not necessarily a good idea.  2.1.110, for example,
now fails to boot for me in low memory configurations because it cannot
keep enough higher order pages free for 4k NFS to work, never mind 8k.

That's the danger: we need to introduce new schemes like this at the
beginning of the development cycle for a new kernel, not the end.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
