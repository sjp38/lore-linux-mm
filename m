Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 7FB806B0044
	for <linux-mm@kvack.org>; Sun,  6 May 2012 09:16:38 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4024464vbb.14
        for <linux-mm@kvack.org>; Sun, 06 May 2012 06:16:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA36045.9080504@linux.vnet.ibm.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-4-git-send-email-gilad@benyossef.com>
	<4FA36045.9080504@linux.vnet.ibm.com>
Date: Sun, 6 May 2012 16:16:37 +0300
Message-ID: <CAOtvUMegjdS_Oz40QaziLrkezCGThqx=RMMY-cuyuEU-GQAQUw@mail.gmail.com>
Subject: Re: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Fri, May 4, 2012 at 7:51 AM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> On 05/03/2012 08:25 PM, Gilad Ben-Yossef wrote:
>

>> =A0/**
>> + * schedule_on_each_cpu_cond - execute a function synchronously on each
>> + * online CPU for which the supplied condition function returns true
>> + * @func: the function to run on the selected CPUs
>> + * @cond_func: the function to call to select the CPUs
>> + *
>> + * schedule_on_each_cpu_cond() executes @func on each online CPU for
>> + * @cond_func returns true using the system workqueue and blocks until
>
> =A0 =A0^^^
> (for) which

Thanks!

I'll fix this and the other typo in the next iteration.

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
