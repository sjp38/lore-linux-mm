Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A62196B016C
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 08:43:59 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so9385284wgb.26
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 05:43:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111212090033.GQ14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
	<20111209115513.GA19994@infradead.org>
	<20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
	<m262hop5kc.fsf@firstfloor.org>
	<20111210221345.GG14273@dastard>
	<20111211000036.GH24062@one.firstfloor.org>
	<20111211230511.GH14273@dastard>
	<20111212023130.GI24062@one.firstfloor.org>
	<20111212043657.GO14273@dastard>
	<20111212051311.GJ24062@one.firstfloor.org>
	<20111212090033.GQ14273@dastard>
Date: Mon, 12 Dec 2011 08:43:57 -0500
Message-ID: <CAAnfqPC0Ed=PDUOowGTEZyfqHFjB3Jj2YNAaxuYqA2+wVb6tSA@mail.gmail.com>
Subject: Re: XFS causing stack overflow
From: "Ryan C. England" <ryan.england@corvidtec.com>
Content-Type: multipart/alternative; boundary=001517475488934bdb04b3e553a8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com

--001517475488934bdb04b3e553a8
Content-Type: text/plain; charset=ISO-8859-1

Is it possible to apply this patch to my current installation?  We use this
box in production and the reboots that we're experiencing are an
inconvenience.

Is there is a walkthrough on how to apply this patch?  If not, could your
provide the steps necessary to apply successfully?  I would greatly
appreciate it.

Thank you

On Mon, Dec 12, 2011 at 4:00 AM, Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Dec 12, 2011 at 06:13:11AM +0100, Andi Kleen wrote:
> > > It's ~180 bytes, so it's not really that small.
> >
> > Quite small compared to what real code uses. And also fixed
> > size.
> >
> > >
> > > > is on the new stack. ISTs are not used for interrupts, only for
> > > > some special exceptions.
> > >
> > > IST = ???
> >
> > That's a hardware mechanism on x86-64 to switch stacks
> > (Interrupt Stack Table or somesuch)
> >
> > With ISTs it would have been possible to move the the pt_regs too,
> > but the software mechanism is somewhat simpler.
> >
> > > at the top of the stack frame? Is the stack unwinder walking back
> > > across the interrupt stack to the previous task stack?
> >
> > Yes, the unwinder knows about all the extra stacks (interrupt
> > and exception stacks) and crosses them as needed.
> >
> > BTW I suppose it wouldn't be all that hard to add more stacks and
> > switch to them too, similar to what the 32bit do_IRQ does.
> > Perhaps XFS could just allocate its own stack per thread
> > (or maybe only if it detects some specific configuration that
> > is known to need much stack)
>
> That's possible, but rather complex, I think.
> > It would need to be per thread if you could sleep inside them.
>
> Yes, we'd need to sleep, do IO, possibly operate within a
> transaction context, etc, and a workqueue handles all these cases
> without having to do anything special. Splitting the stack at a
> logical point is probably better, such as this patch:
>
> http://oss.sgi.com/archives/xfs/2011-07/msg00443.html
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
>



-- 
Ryan C. England
Corvid Technologies <http://www.corvidtec.com/>
office: 704-799-6944 x158
cell:    980-521-2297

--001517475488934bdb04b3e553a8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Is it possible to apply this patch to my current installation? =A0We use th=
is box in production and the reboots that we&#39;re experiencing are an inc=
onvenience.<div><br></div><div>Is there is a walkthrough on how to apply th=
is patch? =A0If not, could your provide the steps=A0necessary=A0to apply su=
ccessfully? =A0I would greatly appreciate it.</div>
<div><br></div><div>Thank you<br><br><div class=3D"gmail_quote">On Mon, Dec=
 12, 2011 at 4:00 AM, Dave Chinner <span dir=3D"ltr">&lt;<a href=3D"mailto:=
david@fromorbit.com">david@fromorbit.com</a>&gt;</span> wrote:<br><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Mon, Dec 12, 2011 at 06:13:11AM =
+0100, Andi Kleen wrote:<br>
&gt; &gt; It&#39;s ~180 bytes, so it&#39;s not really that small.<br>
&gt;<br>
&gt; Quite small compared to what real code uses. And also fixed<br>
&gt; size.<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; &gt; is on the new stack. ISTs are not used for interrupts, only =
for<br>
&gt; &gt; &gt; some special exceptions.<br>
&gt; &gt;<br>
&gt; &gt; IST =3D ???<br>
&gt;<br>
&gt; That&#39;s a hardware mechanism on x86-64 to switch stacks<br>
&gt; (Interrupt Stack Table or somesuch)<br>
&gt;<br>
&gt; With ISTs it would have been possible to move the the pt_regs too,<br>
&gt; but the software mechanism is somewhat simpler.<br>
&gt;<br>
&gt; &gt; at the top of the stack frame? Is the stack unwinder walking back=
<br>
&gt; &gt; across the interrupt stack to the previous task stack?<br>
&gt;<br>
&gt; Yes, the unwinder knows about all the extra stacks (interrupt<br>
&gt; and exception stacks) and crosses them as needed.<br>
&gt;<br>
&gt; BTW I suppose it wouldn&#39;t be all that hard to add more stacks and<=
br>
&gt; switch to them too, similar to what the 32bit do_IRQ does.<br>
&gt; Perhaps XFS could just allocate its own stack per thread<br>
&gt; (or maybe only if it detects some specific configuration that<br>
&gt; is known to need much stack)<br>
<br>
</div></div>That&#39;s possible, but rather complex, I think.<br>
<div class=3D"im">&gt; It would need to be per thread if you could sleep in=
side them.<br>
<br>
</div>Yes, we&#39;d need to sleep, do IO, possibly operate within a<br>
transaction context, etc, and a workqueue handles all these cases<br>
without having to do anything special. Splitting the stack at a<br>
logical point is probably better, such as this patch:<br>
<br>
<a href=3D"http://oss.sgi.com/archives/xfs/2011-07/msg00443.html" target=3D=
"_blank">http://oss.sgi.com/archives/xfs/2011-07/msg00443.html</a><br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
Cheers,<br>
<br>
Dave.<br>
--<br>
Dave Chinner<br>
<a href=3D"mailto:david@fromorbit.com">david@fromorbit.com</a><br>
</div></div></blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>=
<div>Ryan C. England</div><div><a href=3D"http://www.corvidtec.com/" target=
=3D"_blank">Corvid Technologies</a></div>office: 704-799-6944 x158<br>cell:=
=A0=A0=A0 980-521-2297<br>

</div>

--001517475488934bdb04b3e553a8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
