Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9C3626B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:21:57 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8fa37327-17ff-4734-9007-40412b18d0fb@default>
Date: Fri, 17 Aug 2012 15:21:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5021795A.5000509@linux.vnet.ibm.com> <5024067F.3010602@linux.vnet.ibm.com>
 <2e9ccb4f-1339-4c26-88dd-ea294b022127@default>
 <50254F69.2000409@linux.vnet.ibm.com>
In-Reply-To: <50254F69.2000409@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On 08/09/2012 03:20 PM, Dan Magenheimer wrote
> > I also wonder if you have anything else unusual in your
> > test setup, such as a fast swap disk (mine is a partition
> > on the same rotating disk as source and target of the kernel build,
> > the default install for a RHEL6 system)?
>=20
> I'm using a normal SATA HDD with two partitions, one for
> swap and the other an ext3 filesystem with the kernel source.
>=20
> > Or have you disabled cleancache?
>=20
> Yes, I _did_ disable cleancache.  I could see where having
> cleancache enabled could explain the difference in results.

Sorry to beat a dead horse, but I meant to report this
earlier in the week and got tied up by other things.

I finally got my test scaffold set up earlier this week
to try to reproduce my "bad" numbers with the RHEL6-ish
config file.

I found that with "make -j28" and "make -j32" I experienced
__DATA CORRUPTION__.  This was repeatable.

The type of error led me to believe that the problem was
due to concurrency of cleancache reclaim.  I did not try
with cleancache disabled to prove/support this theory
but it is consistent with the fact that you (Seth) have not
seen a similar problem and has disabled cleancache.

While this problem is most likely in my code and I am
suitably chagrined, it re-emphasizes the fact that
the current zcache in staging is 20-month old "demo"
code.  The proposed new zcache codebase handles concurrency
much more effectively.

I'll be away from email for a few days now.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
