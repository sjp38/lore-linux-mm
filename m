Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06113
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 13:16:41 -0400
Date: Thu, 23 Jul 1998 18:12:49 +0100
Message-Id: <199807231712.SAA13485@dax.dcs.ed.ac.uk>
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

> As I see it, page cache seems too persistant (it grows out of bounds)
> when we age pages in it.

> One wrong way of fixing it is to limit page cache size, IMNSHO.

I_my_NSHO, it's an awful way to fix it: adding yet another rule to the
VM is not progress, it's making things worse!

> I tried the other way, to age page cache harder, and it looks like it
> works very well. Patch is simple, so simple that I can't understand
> nobody suggested (something like) it yet.

It has been suggested before, and that's why a lot of people have
reported great success by having page ageing removed: it essentially
lets pages age faster by limiting the number of ageing passes required
to remove a page (essentially this just reduces the age value down to
the page's single PG_referenced bit).

And yes, it should work fine.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
