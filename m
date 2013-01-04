Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 42BAD6B006E
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 14:53:52 -0500 (EST)
MIME-Version: 1.0
Message-ID: <ea7e4623-0983-4b1d-9d0d-8a523669adca@default>
Date: Fri, 4 Jan 2013 11:53:37 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH] drivers/staging/zcache: remove (old) zcache
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

Since Seth Jennings has moved on to zswap [1], I believe further
effort on the older version of zcache has been abandoned.
Unless there are objections, I can submit a patch to
Greg to remove drivers/staging/zcache and, at some point,
follow up with a patch to re-invert drivers/staging/ramster
so that the newer version of zcache (aka zcache2) becomes
drivers/staging/zcache, with ramster as a subdirectory.

If I've missed anyone on the cc list who possibly cares about
the old version of zcache, kindly forward.

Greg, assuming no objections, do you want an official patch,
i.e. removing each individual line of each file in
drivers/staging/zcache?  Or will you just do a git rm?
If the latter and you need a SOB, I am the original author so:
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>=20

[1] https://lkml.org/lkml/2012/12/12/310=20

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
