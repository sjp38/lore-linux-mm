Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA05751
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 16:56:50 -0500
Subject: Re: unexpected paging during large file reads in 2.1.127
References: <Pine.LNX.3.96.981112143712.20473B-100000@mirkwood.dummy.home> <87k910bkdl.fsf@atlas.CARNet.hr> <199811161959.TAA07259@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 16 Nov 1998 22:56:22 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 16 Nov 1998 19:59:01 GMT"
Message-ID: <87n25rti7t.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 12 Nov 1998 23:45:42 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> >> Agreed, we should do something about that.
> >> 
> >> > +			age_page(page);
> >> > +			age_page(page);
> >> >  			age_page(page);
> 
> The real cure is to disable page aging in the page cache completely.
> Now that we have disabled it for swap, it makes absolutely no sense at
> all to keep it in the page cache.
> 

Probably. That leaves the fastest kernel of all tested (you can feel
it, you can measure it).

But, still, I like that my system pages out, but slowly, over
time. Solaris behaves like that, and it is OK if it's not too
aggressive. Not that Solaris makes good etalon at anything, but... :)

You are still right, though, no aging at all will make many things go
faster.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	     Do not put statements in the negative form.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
