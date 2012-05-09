Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3CB136B0109
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:26:11 -0400 (EDT)
Received: by qafl39 with SMTP id l39so426558qaf.9
        for <linux-mm@kvack.org>; Wed, 09 May 2012 07:26:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205081033450.27713@router.home>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-6-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1205071024550.1060@router.home>
	<4FA823A7.9000801@gmail.com>
	<alpine.DEB.2.00.1205071438240.2215@router.home>
	<CAOtvUMf95gmZ4ZTSpTb+5NZdEiDTg_CPtp3L2_notdz+dZWG6A@mail.gmail.com>
	<alpine.DEB.2.00.1205081033450.27713@router.home>
Date: Wed, 9 May 2012 17:26:08 +0300
Message-ID: <CAOtvUMfGkjTwPX7fk_uBvFyd2EpcoksLJoNET-6Ox6y=JN+LeA@mail.gmail.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Tue, May 8, 2012 at 6:34 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 May 2012, Gilad Ben-Yossef wrote:
>
>> > But this would still mean that the vmstat update thread would run on a=
n
>> > arbitrary cpu. If I have a sacrificial lamb processor for OS processin=
g
>> > then I would expect the vmstat update thread to stick to that processo=
r
>> > and avoid to run on the other processor that I would like to be as fre=
e
>> > from OS noise as possible.
>> >
>>
>> OK, what about -
>>
>> - We pick a scapegoat cpu (the first to come up gets the job).
>> - We add a knob to let user designate another cpu for the job.
>> - If scapegoat cpus goes offline, the cpu processing the off lining is
>> the new scapegoat.
>>
>> Does this makes better sense?
>
> Sounds good. The first that comes up. If the cpu is isolated then the
> first non isolated cpu is picked.
>

OK, will do.

Thanks,
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
