Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id ED6BE6B0062
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 12:28:07 -0500 (EST)
MIME-Version: 1.0
Message-ID: <59a1d7ee-e5dc-4923-8544-605c35c632af@default>
Date: Wed, 12 Dec 2012 09:27:55 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zswap: compressed swap caching
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20121211220148.GA12821@kroah.com> <50C8B0EA.6040205@linux.vnet.ibm.com>
In-Reply-To: <50C8B0EA.6040205@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 0/8] zswap: compressed swap caching
>=20
> On 12/11/2012 04:01 PM, Greg Kroah-Hartman wrote:
> > On Tue, Dec 11, 2012 at 03:55:58PM -0600, Seth Jennings wrote:
> >> Zswap Overview:
> >
> > <snip>
> >
> > Why are you sending this right at the start of the merge window, when
> > all of the people who need to review it are swamped with other work?
>=20
> Yes, sorry, poor timing :-/
>=20
> I'm just looking for early feedback from those that are not swamped
> doing merge window stuff.

Hi Seth --

Related, are you now comfortable with abandoning "zcache1" and
moving "zcache2" (now in drivers/staging/ramster in 3.7) to become
the one-and-only in-tree drivers/staging/zcache (with ramster
as a subdirectory and build option)?  It would be nice to get
rid of that artificial and confusing distinction as soon as possible,
especially if, due to zswap, you have no plans to continue to
maintain/enhance/promote zcache1 anymore.

If so, I'll work with Konrad to generate a drivers/staging
patch for Greg (post-window :-).

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
