Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09434
	for <linux-mm@kvack.org>; Thu, 28 Jan 1999 13:25:21 -0500
Date: Thu, 28 Jan 1999 18:25:08 GMT
Message-Id: <199901281825.SAA03425@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.95.990128101220.32418I-100000@penguin.transmeta.com>
References: <199901281807.SAA03328@dax.scot.redhat.com>
	<Pine.LNX.3.95.990128101220.32418I-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 28 Jan 1999 10:17:37 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> I'd much rather just use some stale "struct task_struct" data.

The problem isn't the risk of using stale data: it is the risk of using
complete garbage if the task_struct page gets reused.  The procfs code
does check that tsk->mm is non-zero before following the pointers, but
if there is a non-zero address there then it _will_ be dereferenced
regardless.

> What we _might_ do in /proc, is to just increment the usage count for the
> (double) page that contains the task structure,

That would certainly take care of it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
