Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 570586B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 22:19:19 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so98059wgb.26
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 19:19:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120125170054.affb676b.akpm@linux-foundation.org>
References: <CAJd=RBDVxT5Pc2HZjz15LUb7xhFbztpFmXqLXVB3nCoQLKHiHg@mail.gmail.com>
	<20120123170354.82b9f127.akpm@linux-foundation.org>
	<CAJd=RBByNhLSiBtyaYOHeMRQpXmAO=hEKTOanPTzrb2gRZTOSg@mail.gmail.com>
	<20120125170054.affb676b.akpm@linux-foundation.org>
Date: Thu, 26 Jan 2012 11:19:17 +0800
Message-ID: <CAJd=RBCv1F3oWpnEbqrvOaRzg_G6Xj_PPHP8v6OADL=vH2pt8g@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: fix malused nr_reclaimed in shrinking zone
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi Andrew

On Thu, Jan 26, 2012 at 9:00 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> I'm thinking we have a bit of code rot happening here. =C2=A0This comment=
:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * On large memory=
 systems, scan >> priority can become
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * really large. T=
his is fine for the starting priority;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * we want to put =
equal scanning pressure on each zone.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * However, if the=
 VM has a harder time of freeing pages,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * with multiple p=
rocesses reclaiming pages, the total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * freeing target =
can get unreasonably large.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>
> seems to have little to do with the code which it is trying to
> describe. =C2=A0Or at least, I'm not sure this is the best we can possibl=
y
> do :(
>

Try to do it soon 8-)

>
> Also, your email client is adding MIME goop to the emails which mine
> (sylpheed) is unable to decrypt. =C2=A0It turns "=3D" into "=3D3D" everyw=
here.
> This:
>
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: quoted-printable
>
> I blame sylpheed for this, but if you can make it stop, that would make
> my life easier, and perhaps others.
>

More care will take gmail later on.

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
