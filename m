Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53BD890014F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 01:26:01 -0400 (EDT)
References: <20110804143844.GQ19099@suse.de> <1312526302.37390.YahooMailNeo@web162009.mail.bf1.yahoo.com> <20110805080133.GS19099@suse.de>
Message-ID: <1313040359.41174.YahooMailNeo@web162012.mail.bf1.yahoo.com>
Date: Wed, 10 Aug 2011 22:25:59 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: MMTests 0.01
In-Reply-To: <20110805080133.GS19099@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Dear Mel Gorman,=0A=A0=0AI found one problem in MMTests0.01/fraganalysis/Ma=
kefile=0A=A0=0AWhen I did "make install" here, I got the following error:=
=0Ainstall: cannot stat `record-buddyinfo': No such file or directory=0Amak=
e: *** [install-script] Error 1=0A=A0=0AI think the following line in makef=
ile need to be corrected:=0A#####INSTALL_SCRIPT =3D pagealloc-extfrag show-=
buddyinfo slab-intfrag record-buddyinfo=0A=0AINSTALL_SCRIPT =3D pagealloc-e=
xtfrag show-buddyinfo slab-intfrag record-extfrag=0A=A0=0AI corrected this =
and it works now.=0A=A0=0A=A0=0A=A0=0AThanks,=0APintu=0A=A0=0A=A0=0AFrom: M=
el Gorman <mgorman@suse.de>=0ATo: Pintu Agarwal <pintu_agarwal@yahoo.com>=
=0ACc: "linux-mm@kvack.org" <linux-mm@kvack.org>; "linux-kernel@vger.kernel=
.org" <linux-kernel@vger.kernel.org>=0ASent: Friday, 5 August 2011 1:31 PM=
=0ASubject: Re: MMTests 0.01=0A=0AOn Thu, Aug 04, 2011 at 11:38:22PM -0700,=
 Pintu Agarwal wrote:=0A> Dear Mel Gorman,=0A> =A0=0A> Thank you very much =
for this MMTest. =0A> It will be very helpful for me for all my needs.=0A> =
I was looking forward for these kind of mm test utilities.=0A> =A0=0A> Just=
 wanted to know, if any of these utilities also covers=0A> anti-fragmentati=
on represent of the=A0various page state in the form=0A> of jpeg image?=0A=
=0ANo, that particular script was not included as it needs a kernel patch=
=0Ato be really useful and depends on parts of VM Regress that were very=0A=
ugly. As I've said before, I generally use unusable free space index=0Aand =
fragmentation index if I'm trying to graph fragmentation-related=0Ainformat=
ion. To record it, I use the "extfrag" monitor in monitors/=0A. It uses oth=
er helpers of which fraganalysis/show-buddyinfo is the=0Amost important as =
it is the one that can read either /proc/buddyinfo=0Aor use /proc/kpagefrag=
s to build a more accurate picture.=0A=0A-- =0AMel Gorman=0ASUSE Labs=0A=0A=
--=0ATo unsubscribe, send a message with 'unsubscribe linux-mm' in=0Athe bo=
dy to majordomo@kvack.org.=A0 For more info on Linux MM,=0Asee: http://www.=
linux-mm.org/ .=0AFight unfair telecom internet charges in Canada: sign htt=
p://stopthemeter.ca/=0ADon't email: <a href=3Dmailto:"dont@kvack.org"> emai=
l@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
