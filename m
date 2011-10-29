Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 160F56B002D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2011 11:29:44 -0400 (EDT)
Received: by ywa17 with SMTP id 17so5986594ywa.14
        for <linux-mm@kvack.org>; Sat, 29 Oct 2011 08:29:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4EAAD351.70805@redhat.com>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
	<1319385413-29665-5-git-send-email-gilad@benyossef.com>
	<4EAAD351.70805@redhat.com>
Date: Sat, 29 Oct 2011 17:29:41 +0200
Message-ID: <CAOtvUMd8Z_jbs__+cVG2+ZkPZLqGkJGym402RMRYGDDjT73bkg@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Fri, Oct 28, 2011 at 6:07 PM, Rik van Riel <riel@redhat.com> wrote:
> On 10/23/2011 11:56 AM, Gilad Ben-Yossef wrote:
>>
>> Use a cpumask to track CPUs with per-cpu pages in any zone
>> and only send an IPI requesting CPUs to drain these pages
>> to the buddy allocator if they actually have pages.
>
>> +/* Which CPUs have per cpu pages =A0*/
>> +cpumask_var_t cpus_with_pcp;
>> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
>
> Does the flushing happen so frequently that it is worth keeping this
> state on a per-cpu basis, or would it be better to check each CPU's
> pcp info and assemble a cpumask at flush time like done in patch 5?
>

No, I don't  believe it is frequent at all. I will try to re-work the
patch as suggested.

Thanks,
Gilad

>

>
> --
> All rights reversed
>



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
