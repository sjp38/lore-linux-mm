Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0AE796B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:22:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
Date: Fri, 27 Jul 2012 12:21:50 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <<1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCH 0/4] promote zcache from staging
>=20
> zcache is the remaining piece of code required to support in-kernel
> memory compression.  The other two features, cleancache and frontswap,
> have been promoted to mainline in 3.0 and 3.5.  This patchset
> promotes zcache from the staging tree to mainline.
>=20
> Based on the level of activity and contributions we're seeing from a
> diverse set of people and interests, I think zcache has matured to the
> point where it makes sense to promote this out of staging.

Hi Seth --

Per offline communication, I'd like to see this delayed for three
reasons:

1) I've completely rewritten zcache and will post the rewrite soon.
   The redesigned code fixes many of the weaknesses in zcache that
   makes it (IMHO) unsuitable for an enterprise distro.  (Some of
   these previously discussed in linux-mm [1].)
2) zcache is truly mm (memory management) code and the fact that
   it is in drivers at all was purely for logistical reasons
   (e.g. the only in-tree "staging" is in the drivers directory).
   My rewrite promotes it to (a subdirectory of) mm where IMHO it
   belongs.
3) Ramster heavily duplicates code from zcache.  My rewrite resolves
   this.  My soon-to-be-post also places the re-factored ramster
   in mm, though with some minor work zcache could go in mm and
   ramster could stay in staging.

Let's have this discussion, but unless the community decides
otherwise, please consider this a NACK.

Thanks,
Dan

[1] http://marc.info/?t=3D133886706700002&r=3D1&w=3D2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
