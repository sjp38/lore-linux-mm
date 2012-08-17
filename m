Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 68C586B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 20:20:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a8bfd9e8-7286-42f5-b8ef-16af00fceb8b@default>
Date: Thu, 16 Aug 2012 17:19:28 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/3] staging: zcache+ramster: move to new code base and
 re-merge
References: <1345156293-18852-1-git-send-email-dan.magenheimer@oracle.com>
 <20120816224814.GA18737@kroah.com>
 <9f2da295-4164-4e95-bbe8-bd234307b83c@default>
 <20120816230817.GA14757@kroah.com>
In-Reply-To: <20120816230817.GA14757@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com, minchan@kernel.org

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH 0/3] staging: zcache+ramster: move to new code base a=
nd re-merge
>=20
> On Thu, Aug 16, 2012 at 03:53:11PM -0700, Dan Magenheimer wrote:
> > > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > > Subject: Re: [PATCH 0/3] staging: zcache+ramster: move to new code ba=
se and re-merge
> > >
> > > On Thu, Aug 16, 2012 at 03:31:30PM -0700, Dan Magenheimer wrote:
> > > > Greg, please pull for staging-next.
> > >
> > > Pull what?
> >
> > Doh!  Sorry, I did that once before and used the same template for the
> > message.  Silly me, I meant please apply.  Will try again when my
> > head isn't fried. :-(
> >
> > > You sent patches, in a format that I can't even apply.
> > > Consider this email thread deleted :(
> >
> > Huh?  Can you explain more?  I used git format-patch and git-email
> > just as for previous patches and even checked the emails with
> > a trial send to myself.  What is un-apply-able?
>=20
> Your first patch, with no patch description, and no signed-off-by line.
>=20
> Come on, you know better...

Doh! Script error, and I completely didn't look at the content
of the delete patch, just the add patches.

I am _really_ sorry and suitably embarrassed.  Please forgive me!
=20
> On a larger note, I _really_ don't want a set of 'delete and then add it
> back' set of patches.  That destroys all of the work that people had
> done up until now on the code base.
>=20
> I understand your need, and want, to start fresh, but you still need to
> abide with the "evolve over time" model here.  Surely there is some path
> from the old to the new codebase that you can find?

While I in absolutely no way want to minimize the contribution
of others, it was very clear (even to you) that things were
not progressing very fast toward an on-by-default end-user-usable
non-hobbyist-distro-shippable zcache.  Major work needed to
be done, and you rejected a first step in that direction, here:
https://lkml.org/lkml/2012/3/16/472  It certainly seemed that
the time for major changes for zcache in staging were at an end.

In my investigation of what needed to be fixed (and we can always
quibble about what is a feature or a design flaw or a bug fix),
I found a lot of interdependency and "did it all at once"
with the intent of (1) proving the fixes were possible and (2)
completing a suitable replacement ready to propose directly into
mm, since it appeared staging was now closed.  I got very close
but ran out of time.

(My jaw dropped when I saw this response from you last week
http://lkml.indiana.edu/hypermail/linux/kernel/1208.0/02244.html )

Yes, it is always possible to retrofit a massive change into
a bunch of smaller ones, but my use of the word Sisyphean
was intentional.  It will certainly take weeks of debugging and,
to be completely honest, I don't have the patience to re-do it
and I don't think anyone else will invest the time either.

So, unless someone else steps up to retrofit, we have a choice
of the in-tree code (which I call "demo" code because that's
what it is/was) and the massive rewrite.  I'm really not
trying to present this as an ultimatum, just trying to be real.

> Also, I'd like to get some agreement from everyone else involved here,
> that this is what they all agree is the correct way forward.  I don't
> think we have that agreement yet, right?

Correct, though I think we all have roughly the same destination
in mind, and we are mostly disagreeing on tactics.  Seth says
"ship sh##it NOW and pick up the pieces later", Minchan says
"current code is very bad, Andrew will never take it, how do
we fix it", and I have invested months of my time into a monolithic
patch which I (as author of both) say is much better.  Bias noted ;-)

In any case, Minchan asked me to post my code as a formal patch
http://lkml.indiana.edu/hypermail/linux/kernel/1208.0/02466.html=20
so I have done so (however awkwardly, sorry).  Thanks for listening,
Greg, and I hope you have the wisdom of Solomon on this one.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
