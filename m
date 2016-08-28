Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4A583090
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 01:50:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so21070621wme.1
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 22:50:06 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id r192si12779034lfr.2.2016.08.27.22.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 22:50:04 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id b199so81213852lfe.0
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 22:50:04 -0700 (PDT)
From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Subject: Re: OOM detection regressions since 4.7
Date: Sun, 28 Aug 2016 07:50:01 +0200
References: <20160822093249.GA14916@dhcp22.suse.cz> <20160823074339.GB23577@dhcp22.suse.cz> <20160825071103.GC4230@dhcp22.suse.cz>
In-Reply-To: <20160825071103.GC4230@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201608280750.02034.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thursday 25 of August 2016, Michal Hocko wrote:
> On Tue 23-08-16 09:43:39, Michal Hocko wrote:
> > On Mon 22-08-16 15:05:17, Andrew Morton wrote:
> > > On Mon, 22 Aug 2016 15:42:28 +0200 Michal Hocko <mhocko@kernel.org>=20
wrote:
> > > > Of course, if Linus/Andrew doesn't like to take those compaction
> > > > improvements this late then I will ask to merge the partial revert =
to
> > > > Linus tree as well and then there is not much to discuss.
> > >=20
> > > This sounds like the prudent option.  Can we get 4.8 working
> > > well-enough, backport that into 4.7.x and worry about the fancier stu=
ff
> > > for 4.9?
> >=20
> > OK, fair enough.
> >=20
> > I would really appreciate if the original reporters could retest with
> > this patch on top of the current Linus tree.
>=20
> Any luck with the testing of this patch?

Here my "rm -rf && cp -al" 10x in parallel test finished without OOM, so

Tested-by: Arkadiusz Mi=C5=9Bkiewicz <arekm@maven.pl>

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
