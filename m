Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id DD5496B0075
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 14:55:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <006139fe-542e-46f0-8b6c-b05efeb232d6@default>
Date: Thu, 14 Mar 2013 11:54:35 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
 <20130313151359.GA3130@linux.vnet.ibm.com>
 <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
 <514104D5.9020700@linux.vnet.ibm.com> <5141BC5D.9050005@oracle.com>
 <20130314132046.GA3172@linux.vnet.ibm.com>
In-Reply-To: <20130314132046.GA3172@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Jennings <rcj@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
> Sent: Thursday, March 14, 2013 7:21 AM
> To: Bob
> Cc: Seth Jennings; Dan Magenheimer; minchan@kernel.org; Nitin Gupta; Konr=
ad Wilk; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org; Bob Liu; Luigi Semenzato; Mel Gorman
> Subject: Re: zsmalloc limitations and related topics
>=20
> * Bob (bob.liu@oracle.com) wrote:
> > On 03/14/2013 06:59 AM, Seth Jennings wrote:
> > >On 03/13/2013 03:02 PM, Dan Magenheimer wrote:
> > >>>From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
> > >>>Subject: Re: zsmalloc limitations and related topics
> > >>
> <snip>
> > >>Yes.  And add pageframe-reclaim to this list of things that
> > >>zsmalloc should do but currently cannot do.
> > >
> > >The real question is why is pageframe-reclaim a requirement?  What
> > >operation needs this feature?
> > >
> > >AFAICT, the pageframe-reclaim requirements is derived from the
> > >assumption that some external control path should be able to tell
> > >zswap/zcache to evacuate a page, like the shrinker interface.  But thi=
s
> > >introduces a new and complex problem in designing a policy that doesn'=
t
> > >shrink the zpage pool so aggressively that it is useless.
> > >
> > >Unless there is another reason for this functionality I'm missing.
> > >
> >
> > Perhaps it's needed if the user want to enable/disable the memory
> > compression feature dynamically.
> > Eg, use it as a module instead of recompile the kernel or even
> > reboot the system.

It's worth thinking about: Under what circumstances would a user want
to turn off compression?  While unloading a compression module should
certainly be allowed if it makes a user comfortable, in my opinion,
if a user wants to do that, we have done our job poorly (or there
is a bug).

> To unload zswap all that is needed is to perform writeback on the pages
> held in the cache, this can be done by extending the existing writeback
> code.

Actually, frontswap supports this directly.  See frontswap_shrink.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
