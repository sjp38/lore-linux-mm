Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5656B00B2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:52:34 -0500 (EST)
Received: by yenm12 with SMTP id m12so1418610yen.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:52:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4ECC4E1B.9050405@tilera.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<4ECC4E1B.9050405@tilera.com>
Date: Wed, 23 Nov 2011 08:52:31 +0200
Message-ID: <CAOtvUMdj--5O6xB6zzrk+kYDASHWxxRMAkN2K-2z3z5hSwzcyw@mail.gmail.com>
Subject: Re: [PATCH v4 0/5] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

Hi

On Wed, Nov 23, 2011 at 3:36 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 11/22/2011 6:08 AM, Gilad Ben-Yossef wrote:
>> We have lots of infrastructure in place to partition a multi-core system=
 such that we have a group of CPUs that are dedicated to
>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
>
> I think this kind of work is very important as more and more processing
> moves to isolated cpus that need protection from miscellaneous kernel
> interrupts. =A0Keep at it! :-)

Thank you very much. I believe it also has some small contribution to
keeping idle CPUs idle in a multi-core system. I consider this my
personal carbon offset effort :-)

My current plan is to take a look at each invocation of on_each_cpu in
core kernel code and see if it makes sense to give it a similar
treatment.

Thanks,
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
