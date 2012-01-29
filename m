Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DB8626B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 07:24:17 -0500 (EST)
Received: by vbbfd1 with SMTP id fd1so2878036vbb.14
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 04:24:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327572121-13673-2-git-send-email-gilad@benyossef.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-2-git-send-email-gilad@benyossef.com>
Date: Sun, 29 Jan 2012 14:24:16 +0200
Message-ID: <CAOtvUMc3XJ_SqpWAZnhyi6Anjd6rEGQTK_iAWJox-5Y4n4Z8hQ@mail.gmail.com>
Subject: Re: [v7 1/8] smp: introduce a generic on_each_cpu_mask function
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org

On Thu, Jan 26, 2012 at 12:01 PM, Gilad Ben-Yossef <gilad@benyossef.com> wr=
ote:
> on_each_cpu_mask calls a function on processors specified by
> cpumask, which may or may not include the local processor.
>
> You must not call this function with disabled interrupts or
> from a hardware interrupt handler or from a bottom half handler.
>
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>
> CC: Chris Metcalf <cmetcalf@tilera.com>
...
> ---
> =A0include/linux/smp.h | =A0 22 ++++++++++++++++++++++
> =A0kernel/smp.c =A0 =A0 =A0 =A0| =A0 29 +++++++++++++++++++++++++++++
> =A02 files changed, 51 insertions(+), 0 deletions(-)
>


Milton made the very sensible comment that while adding on_each_cpu() in th=
e
arch generic code and removing the two arch specific instances from tile an=
d arm
in separate patches is good for review, it will break bisect.

He suggested I squash  them into a single commit when it goes in.

Since you picked the patch set into linux-mm, will now be a good time for t=
hat?

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
