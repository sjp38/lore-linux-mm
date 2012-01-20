Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CDA386B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 17:58:16 -0500 (EST)
Received: by bkbzx1 with SMTP id zx1so1141293bkb.14
        for <linux-mm@kvack.org>; Fri, 20 Jan 2012 14:58:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201201180602.04269.vapier@gentoo.org>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <201201180518.31407.vapier@gentoo.org> <20120118104749.GG15447@linux.vnet.ibm.com>
 <201201180602.04269.vapier@gentoo.org>
From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 20 Jan 2012 17:57:54 -0500
Message-ID: <CAMjpGUc+V-mrQcBcpyTvhCihYUtd=4Q4Wr6DTsaUwC0JJpBROA@mail.gmail.com>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step exception.
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Anton Arapov <anton@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jan 18, 2012 at 06:01, Mike Frysinger wrote:
> On Wednesday 18 January 2012 05:47:49 Srikar Dronamraju wrote:
>> > On Wednesday 18 January 2012 04:02:32 Srikar Dronamraju wrote:
>> > > > =C2=A0 Can we use existing SET_IP() instead of set_instruction_poi=
nter() ?
>> > >
>> > > Oleg had already commented about this in one his uprobes reviews.
>> > >
>> > > The GET_IP/SET_IP available in include/asm-generic/ptrace.h doesnt w=
ork
>> > > on all archs. Atleast it doesnt work on powerpc when I tried it.
>> >
>> > so migrate the arches you need over to it.
>>
>> One question that could be asked is why arent we using instruction_point=
er
>> instead of GET_IP since instruction_pointer is being defined in 25
>> places and with references in 120 places.
>
> i think you misunderstand the point. =C2=A0{G,S}ET_IP() is the glue betwe=
en the
> arch's pt_regs struct and the public facing API. =C2=A0the only people wh=
o should
> be touching those macros are the ptrace core. =C2=A0instruction_pointer()=
 and
> instruction_pointer_set() are the API that asm/ptrace.h exports to the re=
st of
> the tree.

Srikar: does that make sense ?  i'm happy to help with improving
asm-generic/ptrace.h.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
