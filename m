Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA05050
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 14:59:26 -0500
Date: Mon, 16 Nov 1998 19:59:01 GMT
Message-Id: <199811161959.TAA07259@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <87k910bkdl.fsf@atlas.CARNet.hr>
References: <Pine.LNX.3.96.981112143712.20473B-100000@mirkwood.dummy.home>
	<87k910bkdl.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 12 Nov 1998 23:45:42 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

>> Agreed, we should do something about that.
>> 
>> > +			age_page(page);
>> > +			age_page(page);
>> >  			age_page(page);

The real cure is to disable page aging in the page cache completely.
Now that we have disabled it for swap, it makes absolutely no sense at
all to keep it in the page cache.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
