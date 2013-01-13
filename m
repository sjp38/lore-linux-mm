Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2F3746B0071
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 09:25:26 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id l10so3195441oag.22
        for <linux-mm@kvack.org>; Sun, 13 Jan 2013 06:25:25 -0800 (PST)
Date: Sun, 13 Jan 2013 05:44:33 -0600
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2 1/2] Fix wrong EOF compare
References: <1357871401-7075-1-git-send-email-minchan@kernel.org>
	<xa1tbocvby0s.fsf@mina86.com>
In-Reply-To: <xa1tbocvby0s.fsf@mina86.com> (from mina86@mina86.com on Fri
	Jan 11 08:21:55 2013)
Message-Id: <1358077473.32505.10@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgMinchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Randy Dunlap <rdunlap@infradead.org>

On 01/11/2013 08:21:55 AM, Michal Nazarewicz wrote:
> On Fri, Jan 11 2013, Minchan Kim <minchan@kernel.org> wrote:
> > The C standards allows the character type char to be singed or =20
> unsinged,
> > depending on the platform and compiler. Most of systems uses signed =20
> char,
> > but those based on PowerPC and ARM processors typically use =20
> unsigned char.
> > This can lead to unexpected results when the variable is used to =20
> compare
> > with EOF(-1). It happens my ARM system and this patch fixes it.
> >
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Andy Whitcroft <apw@shadowen.org>
> > Cc: Alexander Nyberg <alexn@dsv.su.se>
> > Cc: Michal Nazarewicz <mina86@mina86.com>
>=20
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>=20
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/page_owner.c |    7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)

My kernel tree doesn't have Documentation/page_owner.c, where do I find =20
this file?

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
