Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA19877
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 15:21:19 -0500
Date: Wed, 13 Jan 1999 20:21:08 GMT
Message-Id: <199901132021.UAA06949@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Why don't shared anonymous mappings work?
In-Reply-To: <m1ww2zeifc.fsf@flinx.ccr.net>
References: <199901061523.IAA14788@nyx10.nyx.net>
	<m1d84sgoyj.fsf@flinx.ccr.net>
	<m1ww2zeifc.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Colin Plumb <colin@nyx.net>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 06 Jan 1999 23:55:03 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> And of course the last reason I just thought of, which is probably the
> real reason.  Currenlty anonymous pages if the are writable are
> assumed to have exactly one mapping, or if it is in the swap cache the
> page is assumed to be read only.

> So reusing the swap inode could be a real problem.

Yes.  The _only_ reason we can't do anonymous pages right now is the
VM's assumption that all swap cache pages are read-only.  Once we relax
that, the only thing left is the initialisation of anonymous page ptes
(remembering that when we fill in a demand-zero anonymous shared page,
we will have to update that page's pte in every mm which shares the
page).  Other than that, allowing writable swap-cache pages is all that
is required.  It's just too much of a potential destabiliser to add this
close to 2.2.0.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
