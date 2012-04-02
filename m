Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D04DB6B0044
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 22:21:18 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so2058098vbb.14
        for <linux-mm@kvack.org>; Sun, 01 Apr 2012 19:21:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F788675.6060604@tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311334.q2VDYGiL005854@farm-0012.internal.tilera.com>
	<CAJd=RBDEAMgDviSwugt7dHKPGXCCF5jQSDtHdXvt5VnSBmK3bA@mail.gmail.com>
	<201203311612.q2VGCqPA012710@farm-0012.internal.tilera.com>
	<CAJd=RBDqQ2jwxyVgn-WwoJfu0vOs9YUHfKxkcqUczr=cnk+8wg@mail.gmail.com>
	<4F788675.6060604@tilera.com>
Date: Mon, 2 Apr 2012 10:21:17 +0800
Message-ID: <CAJd=RBAXv+vsMTsGJwdHzG1L6TbZ2C7nTBSwmQg+M0vVczkfUw@mail.gmail.com>
Subject: Re: [PATCH v3] arch/tile: support multiple huge page sizes dynamically
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Mon, Apr 2, 2012 at 12:46 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>
> =C2=A0As it happens, I am the tile guru for this code :-)
>
I see.

>
> So does it make sense for me to push the two resulting changes through th=
e
> tile tree? =C2=A0I'd like to ask Linus to pull this stuff for 3.4 (I know=
, I'm
> late in the cycle for that), but obviously it's not much use without the
> part that you reviewed.
>
No more question:)
-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
