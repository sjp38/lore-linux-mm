Received: by rv-out-0910.google.com with SMTP id f1so707587rvb.26
        for <linux-mm@kvack.org>; Sun, 30 Mar 2008 16:24:29 -0700 (PDT)
Message-ID: <86802c440803301624r4601eae2g5bacc54f69c032db@mail.gmail.com>
Date: Sun, 30 Mar 2008 16:24:29 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
In-Reply-To: <20080330210843.GB13383@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182122.GA28327@sgi.com>
	 <86802c440803301341i5d116b0en362a51f6d8550482@mail.gmail.com>
	 <20080330210843.GB13383@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 30, 2008 at 2:08 PM, Jack Steiner <steiner@sgi.com> wrote:
> > >   unsigned int get_apic_id(void)
>  > >   {
>  > >  -       return (apic_read(APIC_ID) >> 24) & 0xFFu;
>  > >  +       unsigned int id;
>  > >  +
>  > >  +       preempt_disable();
>  > >  +       id = apic_read(APIC_ID);
>  > >  +       if (uv_system_type >= UV_X2APIC)
>  > >  +               id  |= __get_cpu_var(x2apic_extra_bits);
>  > >  +       else
>  > >  +               id = (id >> 24) & 0xFFu;;
>  > >  +       preempt_enable();
>  > >  +       return id;
>  > >
>  >
>  > you can not shift id here.
>  >
>  > GET_APIC_ID will shift that again.
>  >
>  > you apic id will be 0 for all cpu
>  >
>
>  I think this is fixed in the patch that I submitted on Friday. I
>  had to rework the GET_APIC_ID() changes because of the unification
>  of -32 & -64 apic code. I think the new code is much cleaner...

i think Ingo already put you Friday's version in x86.git#latest.

that is wrong too with extra shift.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
