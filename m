Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 687796B005C
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 03:12:22 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so16758525vbb.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 00:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v7hz3pbc3l0zgt@mpn-glaptop>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-2-git-send-email-gilad@benyossef.com>
	<op.v7hz3pbc3l0zgt@mpn-glaptop>
Date: Tue, 3 Jan 2012 10:12:21 +0200
Message-ID: <CAOtvUMdk6DdcHK3Rp8ctwa8BqkF9YLwa09PHTUFCE53VdAY_6A@mail.gmail.com>
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask function
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

2012/1/3 Michal Nazarewicz <mina86@mina86.com>:
> On Mon, 02 Jan 2012 11:24:12 +0100, Gilad Ben-Yossef <gilad@benyossef.com=
>
> wrote:
>>
>> @@ -102,6 +102,13 @@ static inline void call_function_init(void) { }
>> =A0int on_each_cpu(smp_call_func_t func, void *info, int wait);
>> /*
>> + * Call a function on processors specified by mask, which might include
>> + * the local one.
>> + */
>> +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *info, bool wait);
>> +
>
>
> on_each_cpu() returns an int. =A0For consistency reasons, would it make s=
ense
> to
> make on_each_cpu_maks() to return and int? =A0I know that the difference =
is
> that
> smp_call_function() returns and int and smp_call_function_many() returns
> void,
> but to me it actually seems strange and either I'm missing something
> important
> (which is likely) or this needs to get cleaned up at one point as well.
>

I'd say we should go the other way around - kill the return value on
on_each_cpu()

The return value is always a hard coded zero and we have some code that tes=
ts
for that return value. Silly...

It looks like it's there for hysterical reasons to me :-)

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
