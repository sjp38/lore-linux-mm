Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA09981
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 07:03:47 -0500
Date: Tue, 17 Nov 1998 12:00:37 GMT
Message-Id: <199811171200.MAA01162@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <87lnlb5d2t.fsf@atlas.CARNet.hr>
References: <199811161959.TAA07259@dax.scot.redhat.com>
	<Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home>
	<199811162305.XAA07996@dax.scot.redhat.com>
	<87lnlb5d2t.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "David J. Fred" <djf@ic.net>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 17 Nov 1998 02:21:14 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> "Stephen C. Tweedie" <sct@redhat.com> writes:

>> No, we don't.  We don't evict just-read-in data, because we mark such
>> pages as PG_Referenced.  It takes two complete shrink_mmap() passes
>> before we can evict such pages.

> I didn't find this in the source (in fact, add_to_page_cache clears
> PG_referenced bit, if I understood source correctly). But, see below.

You didn't understand the source correctly. :)  There is an extra
bracket you missed:

	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);

We clear PG_uptodate and PG_error, but we _set_ PG_referenced.

> I must agree entirely, because with small patch you can find below,
> performance is very very good. Thanks to marking readahead pages as
> referenced, I've been able to see exact behaviour that I wanted for a
> long time. 

Excellent.  

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
