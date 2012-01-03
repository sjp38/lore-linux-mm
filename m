Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 626246B004D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 02:51:41 -0500 (EST)
Received: by eekc41 with SMTP id c41so17999914eek.14
        for <linux-mm@kvack.org>; Mon, 02 Jan 2012 23:51:39 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask function
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-2-git-send-email-gilad@benyossef.com>
Date: Tue, 03 Jan 2012 08:51:15 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7hz3pbc3l0zgt@mpn-glaptop>
In-Reply-To: <1325499859-2262-2-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell
 King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Mon, 02 Jan 2012 11:24:12 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> @@ -102,6 +102,13 @@ static inline void call_function_init(void) { }
>  int on_each_cpu(smp_call_func_t func, void *info, int wait);
> /*
> + * Call a function on processors specified by mask, which might inclu=
de
> + * the local one.
> + */
> +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *=
),
> +		void *info, bool wait);
> +

on_each_cpu() returns an int.  For consistency reasons, would it make se=
nse to
make on_each_cpu_maks() to return and int?  I know that the difference i=
s that
smp_call_function() returns and int and smp_call_function_many() returns=
 void,
but to me it actually seems strange and either I'm missing something imp=
ortant
(which is likely) or this needs to get cleaned up at one point as well.

> +/*
>   * Mark the boot cpu "online" so that it can call console drivers in
>   * printk() and can access its per-cpu storage.
>   */

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
