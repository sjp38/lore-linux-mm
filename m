Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id CC3676B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 17:43:20 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
Date: Fri, 27 Jul 2012 14:42:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
In-Reply-To: <20120727205932.GA12650@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> Sent: Friday, July 27, 2012 3:00 PM
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On Fri, Jul 27, 2012 at 12:21:50PM -0700, Dan Magenheimer wrote:
> > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > Subject: [PATCH 0/4] promote zcache from staging
> > >
> > > zcache is the remaining piece of code required to support in-kernel
> > > memory compression.  The other two features, cleancache and frontswap=
,
> > > have been promoted to mainline in 3.0 and 3.5.  This patchset
> > > promotes zcache from the staging tree to mainline.
> > >
> > > Based on the level of activity and contributions we're seeing from a
> > > diverse set of people and interests, I think zcache has matured to th=
e
> > > point where it makes sense to promote this out of staging.
> >
> > Hi Seth --
> >
> > Per offline communication, I'd like to see this delayed for three
> > reasons:
> >
> > 1) I've completely rewritten zcache and will post the rewrite soon.
> >    The redesigned code fixes many of the weaknesses in zcache that
> >    makes it (IMHO) unsuitable for an enterprise distro.  (Some of
> >    these previously discussed in linux-mm [1].)
> > 2) zcache is truly mm (memory management) code and the fact that
> >    it is in drivers at all was purely for logistical reasons
> >    (e.g. the only in-tree "staging" is in the drivers directory).
> >    My rewrite promotes it to (a subdirectory of) mm where IMHO it
> >    belongs.
> > 3) Ramster heavily duplicates code from zcache.  My rewrite resolves
> >    this.  My soon-to-be-post also places the re-factored ramster
> >    in mm, though with some minor work zcache could go in mm and
> >    ramster could stay in staging.
> >
> > Let's have this discussion, but unless the community decides
> > otherwise, please consider this a NACK.

Hi Konrad --
=20
> Hold on, that is rather unfair. The zcache has been in staging
> for quite some time - your code has not been posted. Part of
> "unstaging" a driver is for folks to review the code - and you
> just said "No, mine is better" without showing your goods.

Sorry, I'm not trying to be unfair.  However, I don't see the point
of promoting zcache out of staging unless it is intended to be used
by real users in a real distro.  There's been a lot of discussion,
onlist and offlist, about what needs to be fixed in zcache and not
much visible progress on fixing it.  But fixing it is where I've spent
most of my time over the last couple of months.

If IBM or some other company or distro is eager to ship and support
zcache in its current form, I agree that "promote now, improve later"
is a fine approach.  But promoting zcache out of staging simply because
there is urgency to promote zsmalloc+zram out of staging doesn't
seem wise.  At a minimum, it distracts reviewers/effort from what IMHO
is required to turn zcache into an enterprise-ready kernel feature.

I can post my "goods" anytime.  In its current form it is better
than the zcache in staging (and, please remember, I wrote both so
I think I am in a good position to compare the two).
I have been waiting until I think the new zcache is feature complete
before asking for review, especially since the newest features
should demonstrate clearly why the rewrite is necessary and
beneficial.  But I can post* my current bits if people don't
believe they exist and/or don't mind reviewing non-final code.
(* Or I can put them in a publicly available git tree.)

> There is a third option - which is to continue the promotion
> of zcache from staging, get reviews, work on them ,etc, and
> alongside of that you can work on fixing up (or ripping out)
> zcache1 with zcache2 components as they make sense. Or even
> having two of them - an enterprise and an embedded version
> that will eventually get merged together. There is nothing
> wrong with modifying a driver once it has left staging.

Minchan and Seth can correct me if I am wrong, but I believe
zram+zsmalloc, not zcache, is the target solution for embedded.
The limitations of zsmalloc aren't an issue for zram but they are
for zcache, and this deficiency was one of the catalysts for the
rewrite.  The issues are explained in more detail in [1],
but if any point isn't clear, I'd be happy to explain further.

However, I have limited time for this right now and I'd prefer
to spend it finishing the code. :-}

So, as I said, I am still a NACK, but if there are good reasons
to duplicate effort and pursue the "third option", let's discuss
them.

Thanks,
Dan

[1] http://marc.info/?t=3D133886706700002&r=3D1&w=3D2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
