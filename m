Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A968D6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:07:42 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default>
Date: Thu, 27 Sep 2012 15:07:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <50609794.8030508@linux.vnet.ibm.com>
 <b34c65c9-4b25-431d-8b82-cbe911126be9@default>
 <5064B647.3000906@linux.vnet.ibm.com>
In-Reply-To: <5064B647.3000906@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>=20
> On 09/24/2012 02:17 PM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> >
> > Once again, you have completely ignored a reasonable
> > compromise proposal.  Why?
>=20
> We have users who are interested in zcache and we had hoped for a path
> that didn't introduce an additional 6-12 month delay.  I am talking
> with our team to determine a compromise that resolves this, but also
> gets this feature into the hands of users that they can work with.
> I'll be away from email until next week, but I wanted to get something
> out to the mailing list before I left.  I need a couple days to give a
> more definite answer.

Hi Seth --

James Bottomley's estimate of the additional 6-12 month
addition to the acceptance cycle was (quote) "every time I've
seen a rewrite done".  Especially with zsmalloc available
as an option in zcache2 (see separately-posted patch),
zcache2 is _really_ _not_ a rewrite, certainly not for
frontswap-centric workloads, which is I think where your
efforts have always been focused (and, I assume, your
future users).  I suspect if you walk through the code
paths in zcache2+zsmalloc, you'll find they are nearly
identical to zcache1, other than some very minor cleanups,
and some changes where Mel gave some feedback which would
need to be cleaned up in zcache1 before promotion anyway
(and happen to already have been cleaned up in zcache2).
The more invasive design changes are all on the zbud paths.

Of course, I'm of the opinion that neither zcache1 nor
zcache2 would be likely to be promoted for at least another
cycle or two, so if you go with zcache2+zsmalloc as the compromise
and it still takes six months for promotion, I hope you don't
blame that on the "rewrite". ;-)

Anyway, looking forward (hopefully) to working with you on
a good compromise.  It would be nice to get back to coding
and working together on a single path forward for zcache
as there is a lot of work to do!

Have a great weekend!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
