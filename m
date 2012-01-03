Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D1A366B0062
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 03:57:57 -0500 (EST)
Received: by eekc41 with SMTP id c41so18036734eek.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 00:57:56 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask function
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-2-git-send-email-gilad@benyossef.com>
 <op.v7hz3pbc3l0zgt@mpn-glaptop>
 <CAOtvUMdk6DdcHK3Rp8ctwa8BqkF9YLwa09PHTUFCE53VdAY_6A@mail.gmail.com>
Date: Tue, 03 Jan 2012 09:57:35 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7h259ad3l0zgt@mpn-glaptop>
In-Reply-To: <CAOtvUMdk6DdcHK3Rp8ctwa8BqkF9YLwa09PHTUFCE53VdAY_6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

> 2012/1/3 Michal Nazarewicz <mina86@mina86.com>:
>> on_each_cpu() returns an int.  For consistency reasons, would it make=
 sense
>> to make on_each_cpu_maks() to return and int?  I know that the differ=
ence
>> is that smp_call_function() returns and int and smp_call_function_man=
y()
>> returns void, but to me it actually seems strange and either I'm miss=
ing
>> something important (which is likely) or this needs to get cleaned up=
 at
>> one point as well.

On Tue, 03 Jan 2012 09:12:21 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> I'd say we should go the other way around - kill the return value on
> on_each_cpu()
>
> The return value is always a hard coded zero and we have some code tha=
t tests
> for that return value. Silly...
>
> It looks like it's there for hysterical reasons to me :-)

That might be right.  Of course, this goes deeper then on_each_cpu() sin=
ce
some of the smp_call_function functions have an int return value, but I
couldn't find an instance when they return non-zero.

I'd offer to volunteer to do the clean-up but I have too little experien=
ce
in IPI to say with confidence that we in fact can and want to drop the =E2=
=80=9Cint=E2=80=9D
return value from all of those functions.

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
