Received: from dax.scot.redhat.com (root@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA01422
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 14:37:58 -0500
Date: Mon, 1 Feb 1999 13:07:37 GMT
Message-Id: <199902011307.NAA02346@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901300701.AAA08206@chelm.cs.nmt.edu>
References: <199901261645.QAA03883@dax.scot.redhat.com>
	<199901300701.AAA08206@chelm.cs.nmt.edu>
Sender: owner-linux-mm@kvack.org
To: yodaiken@chelm.cs.nmt.edu
Cc: "Stephen C. Tweedie" <sct@redhat.com>, alan@lxorguk.ukuu.org.uk, mingo@chiara.csoma.elte.hu, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 30 Jan 1999 00:01:00 -0700 (MST), yodaiken@chelm.cs.nmt.edu
said:

>> The idea was to decide what region to hand out, _then_ to clear it.
>> Standard best-fit algorithms apply when carving up the region.

> If clearing involves remapping kernel address space, then its a rather
> complex process. 

No, that is the whole point behind restricting such allocations to a
zone containing only swappable objects.  There will be no
non-relocatable objects there, and we can simply swap out each page in
the selected contiguous zone.  

_If_ we expect to do this often then we will want to keep the relocated
pages in memory, but for solving the current problem --- driver
initialisation --- that is not so important and we can rely on the
existing page swap code to just get rid of the data which is in the way.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
