Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 31DE46B13F2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 15:33:17 -0500 (EST)
Received: by vcbf13 with SMTP id f13so1832992vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:33:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328898816.25989.33.camel@laptop>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
	<CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	<4F2AAEB9.9070302@tilera.com>
	<1328898816.25989.33.camel@laptop>
Date: Fri, 10 Feb 2012 22:33:14 +0200
Message-ID: <CAOtvUMcBpWRj3CmvaARH727YMKgEepS7sOaseUdTBRHq9P6oUw@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

[Sent originally to Peter only by some weird gmail quirk. Re sending to all=
]

On Fri, Feb 10, 2012 at 8:33 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
>> At Tilera we have been supporting a "dataplane" mode (aka Zero Overhead
>> Linux - the marketing name). =A0This is configured on a per-cpu basis, a=
nd in
>> addition to setting isolcpus for those nodes, also suppresses various
>> things that might otherwise run (soft lockup detection, vmstat work,
>> etc.).
>
> See that's wrong.. it starts being wrong by depending on cpuisol and
> goes from there.

Actually, correct me if I'm wrong Chris, but I don't think the idea is
to adopt Tilera dataplane mode to mainline but rather treat it as a
reference -

It was develop to answer a specific need, scratch a personal itch, if you
will, and was probably never designed for mass mainline consumption and
it shows.

At the same time its code doing something similar in spirit to what we aim =
to
and has real word users. We would be foolish to ignore it.

So, a good reference (for the good and bad), not merge request. Right Chris=
? :-)

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
