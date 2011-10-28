Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 258756B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 04:43:33 -0400 (EDT)
Received: by gyf3 with SMTP id 3so4519014gyf.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 01:43:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110272307110.14619@router.home>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
	<1319384922-29632-5-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1110272307110.14619@router.home>
Date: Fri, 28 Oct 2011 10:43:31 +0200
Message-ID: <CAOtvUMdjtork2uPTWWCT-bRLP2AAR+DA2_nxG-8MQe83MT=Vew@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Fri, Oct 28, 2011 at 6:10 AM, Christoph Lameter <cl@gentwo.org> wrote:
> On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:
>
>> +/* Which CPUs have per cpu pages =A0*/
>> +cpumask_var_t cpus_with_pcp;
>> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
>
> This increases the cache footprint of a hot vm path. Is it possible to do
> the same than what you did for slub? Run a loop over all zones when
> draining to check for remaining pcp pages and build the set of cpus
> needing IPIs temporarily while draining?
>

Sounds like a good idea. I will give it a shot.

Thanks,
Gilad




--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
