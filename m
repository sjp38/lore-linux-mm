Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11950
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 09:50:40 -0500
Date: Fri, 4 Dec 1998 14:49:11 GMT
Message-Id: <199812041449.OAA04573@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
In-Reply-To: <98Dec4.104023gmt.66305@gateway.ukaea.org.uk>
References: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
	<98Dec4.104023gmt.66305@gateway.ukaea.org.uk>
Sender: owner-linux-mm@kvack.org
To: Neil Conway <nconway.list@ukaea.org.uk>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Jean-Michel.Vansteene@bull.net, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 4 Dec 1998 10:41:15 +0000, Neil Conway
<nconway.list@ukaea.org.uk> said:

>> (although the 2.1.130+my patch seems to work very well
>> with extremely high swap throughput)

> Since the poster didn't say otherwise, perhaps this test was performed
> with buffermem/pagecache.min_percent set to their default values, which
> IIRC add up to 13% of physical RAM (in fact that's PHYSICAL ram, not 13%
> of available RAM).  So take a 1024MB machine, with (say) roughly 16MB
> used by the kernel and kernel-data.  Then subtract 0.13*1024 (133MB !!)
> and you're left with a paltry 875MB or so.  (This assumes that the
> poster had modified his kernel to handle the full 1024MB btw).

I know.  That's why relying on fixed margins to ensure good
performance is wrong: the system really ought to be self-tuning.
We may yet get it right for 2.2: there are people working on this.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
