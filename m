Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A6D746B000A
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 13:51:44 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id c13so2646652ieb.23
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 10:51:44 -0800 (PST)
Date: Thu, 31 Jan 2013 04:25:35 -0600
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2 1/2] Fix wrong EOF compare
References: <1357871401-7075-1-git-send-email-minchan@kernel.org>
	<xa1tbocvby0s.fsf@mina86.com> <1358077473.32505.10@driftwood>
	<50F2F9CD.6080904@infradead.org>
In-Reply-To: <50F2F9CD.6080904@infradead.org> (from rdunlap@infradead.org on
	Sun Jan 13 12:15:41 2013)
Message-Id: <1359627935.12062.1@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>

On 01/13/2013 12:15:41 PM, Randy Dunlap wrote:
> On 01/13/13 03:44, Rob Landley wrote:
> > On 01/11/2013 08:21:55 AM, Michal Nazarewicz wrote:
> >> On Fri, Jan 11 2013, Minchan Kim <minchan@kernel.org> wrote:
> >> > The C standards allows the character type char to be singed or =20
> unsinged,
> >> > depending on the platform and compiler. Most of systems uses =20
> signed char,
> >> > but those based on PowerPC and ARM processors typically use =20
> unsigned char.
> >> > This can lead to unexpected results when the variable is used to =20
> compare
> >> > with EOF(-1). It happens my ARM system and this patch fixes it.
> >> >
> >> > Cc: Mel Gorman <mgorman@suse.de>
> >> > Cc: Andy Whitcroft <apw@shadowen.org>
> >> > Cc: Alexander Nyberg <alexn@dsv.su.se>
> >> > Cc: Michal Nazarewicz <mina86@mina86.com>
> >>
> >> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> >>
> >> > Cc: Randy Dunlap <rdunlap@infradead.org>
> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> > ---
> >> >  Documentation/page_owner.c |    7 ++++---
> >> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > My kernel tree doesn't have Documentation/page_owner.c, where do I =20
> find this file?
>=20
> It's in -mm (mmotm), so Andrew can/should merge this ...

Actually, why is a .c source file at the top level of Documentation?

Example code is nice and all, but this name doesn't say "test" or =20
"example" or anything like that, and isn't collated into a subdirectory =20
with any kind of explanatory files like all the others are.

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
