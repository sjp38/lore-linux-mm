Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA18967
	for <linux-mm@kvack.org>; Wed, 18 Nov 1998 17:51:13 -0500
Subject: Re: unexpected paging during large file reads in 2.1.127
References: <199811161959.TAA07259@dax.scot.redhat.com> <Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home> <199811162305.XAA07996@dax.scot.redhat.com> <87lnlb5d2t.fsf@atlas.CARNet.hr> <199811171200.MAA01162@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 18 Nov 1998 23:50:07 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 17 Nov 1998 12:00:37 GMT"
Message-ID: <87d86kwr8g.fsf@atlas.CARNet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "David J. Fred" <djf@ic.net>
List-ID: <linux-mm.kvack.org>


"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 17 Nov 1998 02:21:14 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > "Stephen C. Tweedie" <sct@redhat.com> writes:
> 
> >> No, we don't.  We don't evict just-read-in data, because we mark such
> >> pages as PG_Referenced.  It takes two complete shrink_mmap() passes
> >> before we can evict such pages.
> 
> > I didn't find this in the source (in fact, add_to_page_cache clears
> > PG_referenced bit, if I understood source correctly). But, see below.
> 
> You didn't understand the source correctly. :)  There is an extra
> bracket you missed:
> 
> 	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);
> 
> We clear PG_uptodate and PG_error, but we _set_ PG_referenced.

Oops. My apologies. You're right, of course.

That makes one line in my patch superfluous.

Although I have some experience in LISP, it looks like I still have
trouble counting parentheses (LISP = Lost In Stupid Parentheses). :)

Still, a small comment above that line would be extremely helpful.

> 
> > I must agree entirely, because with small patch you can find below,
> > performance is very very good. Thanks to marking readahead pages as
> > referenced, I've been able to see exact behaviour that I wanted for a
> > long time. 
> 
> Excellent.  
> 

Pleasure is all mine. :)

I mean, bits from the patch are coming exclusively from you.

I'm really looking forward to their integration in the mainstream,
because performance improvement is so dramatic that I expect lots of
comments on the linux-kernel list telling that "latest 2.1.xxx is so
much faster".

Thanks for your good work!
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	"Luke... Luke... Use the MOUSE, Luke" - Obi Wan Gates
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
