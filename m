Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEA59000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:39:05 -0400 (EDT)
Received: by ywe9 with SMTP id 9so5526100ywe.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 01:39:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317022114.9084.53.camel@twins>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-5-git-send-email-gilad@benyossef.com>
	<1317022114.9084.53.camel@twins>
Date: Mon, 26 Sep 2011 11:39:03 +0300
Message-ID: <CAOtvUMf9Vk_e3kAbSxXH4J86f1sgouYX50wkMnahaCq+YAGEvQ@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 10:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
> On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
>> +static inline void inc_pcp_count(int cpu, struct per_cpu_pages *pcp, in=
t count)
>> +{
>> + =A0 =A0 =A0 if (unlikely(!total_cpu_pcp_count))
>
> =A0 =A0 =A0 =A0if (unlikely(!__this_cpu_read(total_cpu_pco_count))
>

Thanks for the feedback. I will correct this and the comment style in
the next spin of the patch.

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
