Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 62CD36B00C7
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 20:47:03 -0400 (EDT)
Received: by iwn33 with SMTP id 33so5990018iwn.14
        for <linux-mm@kvack.org>; Sun, 12 Sep 2010 17:47:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201009121942.53543.rjw@sisk.pl>
References: <20100912163200.GA4098@barrios-desktop>
	<201009121942.53543.rjw@sisk.pl>
Date: Mon, 13 Sep 2010 09:47:02 +0900
Message-ID: <AANLkTimzby23QO4w0o1vSHnin9AakoG+cp9zd6a8T6FA@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: check all_unreclaimable in direct reclaim path
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 2:42 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Sunday, September 12, 2010, Minchan Kim wrote:
>> Adnrew, Please drop my old version and merge this verstion.
>> (old : vmscan-check-all_unreclaimable-in-direct-reclaim-path.patch)
>>
>> =A0* Changelog from v2
>> =A0 =A0* remove inline - suggested by Andrew
>> =A0 =A0* add function desription - suggeseted by Adnrew
>>
>> =3D=3D CUT HERE =3D=3D
>
> For the record, this commit:
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dco=
mmit;h=3D6715045ddc7472a22be5e49d4047d2d89b391f45
>
> is reported to fix the problem without the $subject patch (see
> http://lkml.org/lkml/2010/9/11/129). =A0So, I'm not sure if it's still ne=
cessary
> to special case this particular situation?


I didn't follow your patch.
If your patch can fix the problem, We don't need new overhead direct
reclaim without big benefit. So I don't care of dropping this patch.

We need agreement of another author KOSAKI.

Thanks for the information, Rafael. :)
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
