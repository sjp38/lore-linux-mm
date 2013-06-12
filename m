Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5336D6B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 20:54:41 -0400 (EDT)
Date: Tue, 11 Jun 2013 17:54:32 -0700
From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [checkpatch] - Confusion
References: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
 <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
 <1370890140.99216.YahooMailNeo@web160102.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
In-Reply-To: <1370890140.99216.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Message-ID: <8a2ec29d-e6d8-44ed-a70d-2273848706ce@VA3EHSMHS029.ehs.local>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>
Cc: anish singh <anish198519851985@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Pintu,

On Mon, Jun 10, 2013 at 11:49:00AM -0700, PINTU KUMAR wrote:
> >________________________________
> > From: anish singh <anish198519851985@gmail.com>
> >To: PINTU KUMAR <pintu_agarwal@yahoo.com> =

> >Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; "linu=
x-mm@kvack.org" <linux-mm@kvack.org> =

> >Sent: Sunday, 9 June 2013 10:58 PM
> >Subject: Re: [checkpatch] - Confusion
> > =

> >
> >On Mon, Jun 10, 2013 at 11:21 AM, PINTU KUMAR <pintu_agarwal@yahoo.com> =
wrote:
> >> Hi,
> >>
> >> I wanted to submit my first patch.
> >> But I have some confusion about the /scripts/checkpatch.pl errors.
> >>
> >> After correcting some checkpatch errors, when I run checkpatch.pl, it =
showed me 0 errors.
> >> But when I create patches are git format-patch, it is showing me 1 err=
or.
> >did=C2=A0 you run the checkpatch.pl on the file which gets created
> >after git format-patch?
> >If yes, then I think it is not necessary.You can use git-am to apply
> >your own patch on a undisturbed file and if it applies properly then
> >you are good to go i.e. you can send your patch.
> =

> Yes, first I ran checkpatch directly on the file(mm/page_alloc.c) and fix=
ed all the errors.
> It showed me (0) errors.
> Then I created a patch using _git format-patch_ and ran checkpatch again =
on the created patch.
> But now it is showing me 1 error.
> According to me this error is false positive (irrelevant), because I did =
not change anything related to the error and also the similar change alread=
y exists somewhere else too.
> Do you mean, shall I go ahead and submit the patch with this 1 error??
> ERROR: need consistent spacing around '*' (ctx:WxV)
> =

> #153: FILE: mm/page_alloc.c:5476:
> +int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
Rather a shot into the dark, but it looks like checkpatch is
misinterpreting 'ctl_table' as an arithmetic operand instead of a type.
I don't know how checkpatch learns about types created by typedefs, but
my guess is, that this line
	typedef struct ctl_table ctl_table; (include/linux/sysctl.h)
is not correctly picked up by checkpatch.
So, I assume this actually is a false positive.

	S=C3=B6ren


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
