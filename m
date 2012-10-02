Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 761A06B0044
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 14:18:26 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <771b722f-3036-451a-a416-e6ab5b4a05f7@default>
Date: Tue, 2 Oct 2012 11:17:51 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <50609794.8030508@linux.vnet.ibm.com>
 <b34c65c9-4b25-431d-8b82-cbe911126be9@default>
 <5064B647.3000906@linux.vnet.ibm.com>
 <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default>
 <506B2C4B.3080508@linux.vnet.ibm.com>
In-Reply-To: <506B2C4B.3080508@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>=20
> On 09/27/2012 05:07 PM, Dan Magenheimer wrote:
> > Of course, I'm of the opinion that neither zcache1 nor
> > zcache2 would be likely to be promoted for at least another
> > cycle or two, so if you go with zcache2+zsmalloc as the compromise
> > and it still takes six months for promotion, I hope you don't
> > blame that on the "rewrite". ;-)
> >
> > Anyway, looking forward (hopefully) to working with you on
> > a good compromise.  It would be nice to get back to coding
> > and working together on a single path forward for zcache
> > as there is a lot of work to do!
>=20
> We want to see zcache moving forward so that it can get out of staging
> and into the hands of end users.  From the direction the discussion
> has taken, replacing zcache with the new code appears to be the right
> compromise for the situation.  Moving to the new zcache code resets
> the clock so I would like to know that we're all on the same track...
>=20
> 1- Promotion must be the top priority, focus needs to be on making the
> code production ready rather than adding more features.

Agreed.

> 2- The code is in the community and development must be done in
> public, no further large private rewrites.

Agreed.

> 3- Benchmarks need to be agreed on, Mel has suggested some of the
> MMTests. We need a way to talk about performance so we can make
> comparisions, avoid regressions, and talk about promotion criteria.
> They should be something any developer can run.

Agreed.

> 4- Let's investigate breaking ramster out of zcache so that zcache
> remains a separately testable building block; Konrad was looking at
> this I believe.  RAMSTer adds another functional mode for zcache and
> adds to the difficulty of validating patches.  Not every developer
> has a cluster of machines to validate RAMSter.

In zcache2 (which is now in Linus' 3.7-rc0 tree in the ramster directory),
ramster is already broken out.  It can be disabled either at compile-time
(simply by not specifying CONFIG_RAMSTER) or at run-time (by using
"zcache" as the kernel boot parameter instead of "ramster").

So... also agreed.  RAMster will not be allowed to get in the
way of promotion or performance as long as any reasonable attempt
is made to avoid breaking the existing hooks to RAMster.
(This only because I expect future functionality to also
use these hooks so would like to avoid breaking them, if possible.)

Does this last clarification work for you, Seth?

If so, <shake hands> and move forward?  What do you see as next steps?

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
