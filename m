Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06452
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 13:43:01 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> 	<199807221033.LAA00826@dax.dcs.ed.ac.uk> 	<87hg08vnmt.fsf@atlas.CARNet.hr> <199807231712.SAA13485@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 19:42:49 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 23 Jul 1998 18:12:49 +0100"
Message-ID: <87ogugmpk6.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 23 Jul 1998 12:59:38 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > As I see it, page cache seems too persistant (it grows out of bounds)
> > when we age pages in it.
> 
> > One wrong way of fixing it is to limit page cache size, IMNSHO.
> 
> I_my_NSHO, it's an awful way to fix it: adding yet another rule to the
> VM is not progress, it's making things worse!
> 

Good, we agree. :)

> > I tried the other way, to age page cache harder, and it looks like it
> > works very well. Patch is simple, so simple that I can't understand
> > nobody suggested (something like) it yet.
> 
> It has been suggested before, and that's why a lot of people have
> reported great success by having page ageing removed: it essentially
> lets pages age faster by limiting the number of ageing passes required
> to remove a page (essentially this just reduces the age value down to
> the page's single PG_referenced bit).
> 
> And yes, it should work fine.
> 

Yep! Exactly that.

If only my english was better to explain it as easily and precisely as
you are doing. :)

As I already said (or at least tried to :)) there's nothing wrong with
the idea of page aging, it's just that current implementation is not
very good. So I would like page aging to stay, but with my or some
similar change that will make things work well and smooth.

Thanks to Benjamin, I'm going to download Werners patch and see how
does his idea perform. In a minute. :)

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	  If you don't think women are explosive, drop one!
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
