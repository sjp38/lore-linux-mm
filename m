Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id B4EB36B010A
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:26:47 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so509126vbb.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 07:26:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120507171725.GB19417@google.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-4-git-send-email-gilad@benyossef.com>
	<20120503153941.GA5528@google.com>
	<CAOtvUMcJurhAKB5pbq91WCsSM7cELNOdUbANzx4gF0Cf8x4cTg@mail.gmail.com>
	<20120507171725.GB19417@google.com>
Date: Wed, 9 May 2012 17:26:46 +0300
Message-ID: <CAOtvUMcrymsv3_sN8mTmAmf1fbJYNq-k4wD4i_wBMuojGiRLRQ@mail.gmail.com>
Subject: Re: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Mon, May 7, 2012 at 8:17 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Sun, May 06, 2012 at 04:15:30PM +0300, Gilad Ben-Yossef wrote:
>> A single helper function called schedule_on_each_cpu_cond() is very
>> obvious to find to someone reading the source or documentation. On
>> the other hand figuring out that the helper functions that handle
>> cpu hotplug and cpumask allocation are there for that purpose is a
>> bit more involved.
>>
>> That was my thinking at least.
>
> Yeah, having common mechanism is nice, but I just prefer iterators /
> helpers which can be embedded in the caller to interface which takes a
> callback unless the execution context is actually asynchronous to the
> caller. =A0We don't use nested functions / scopes in kernel which makes
> those callbacks (higher order functions, lambdas, gammas, zetas
> whatever) painful to use and follow.
>
>> The way i see it, I can either obliterate on_each_cpu_cond() and out
>> its code in place in the LRU path, or fix the callback to get an
>> extra private data parameter -
>
> Unless we can code up something pretty, I vote for just open coding it
> for now. =A0If we grow more usages like this, maybe we'll be able to see
> the pattern better and come up with better abstraction.

Got you. Will do.

Thanks.
Gilad


> --
> tejun



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
