Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA04377
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 08:50:58 -0400
Date: Thu, 23 Jul 1998 13:23:25 +0100
Message-Id: <199807231223.NAA04751@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87hg08vnmt.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<199807221033.LAA00826@dax.dcs.ed.ac.uk>
	<87hg08vnmt.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Jul 1998 12:59:38 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> As promised, I did some testing and I maybe have a solution (big
> words, yeah! :)).

> As I see it, page cache seems too persistant (it grows out of bounds)
> when we age pages in it.

Not on 110, it looks.  On low memory, .110 seems to be even better than
.108 without the page ageing.  It is looking very good right now.

> I can provide thorough benchmark data, if needed.

Please do, but is this on .110?

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
