Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CF1236B0083
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:00:34 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <731b6638-8c8c-4381-a00f-4ecd5a0e91ae@default>
Date: Tue, 8 May 2012 07:00:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
 <1336027242-372-4-git-send-email-minchan@kernel.org>
 <4FA28EFD.5070002@vflare.org> <4FA33E89.6080206@kernel.org>
 <alpine.LFD.2.02.1205071038090.2851@tux.localdomain>
 <4FA7C2BC.2090400@vflare.org> <4FA87837.3050208@kernel.org>
In-Reply-To: <4FA87837.3050208@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> > zcache can potentially create a lot of pools, so the latter will save
> > some memory.
>=20
>=20
> Dumb question.
> Why should we create pool per user?
> What's the problem if there is only one pool in system?

zcache doesn't use zsmalloc for cleancache pages today, but
that's Seth's plan for the future.  Then if there is a
separate pool for each cleancache pool, when a filesystem
is umount'ed, it isn't necessary to walk through and delete
all pages one-by-one, which could take quite awhile.

ramster needs one pool for each client (i.e. machine in the
cluster) for frontswap pages for the same reason, and
later, for cleancache pages, one per mounted filesystem
per client

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
