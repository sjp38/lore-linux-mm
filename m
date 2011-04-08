Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF7388D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:54:37 -0400 (EDT)
Received: by eyd9 with SMTP id 9so1665670eyd.14
        for <linux-mm@kvack.org>; Fri, 08 Apr 2011 13:54:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110408202253.6D6D231C@kernel>
References: <20110408202253.6D6D231C@kernel>
Date: Fri, 8 Apr 2011 22:54:34 +0200
Message-ID: <BANLkTi=OnDX53nOZcaaMmqXRBcWicam0xg@mail.gmail.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mnazarewicz@gmail.com>
Content-Type: multipart/alternative; boundary=0016e65bb65af07b7004a06e6e03
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

--0016e65bb65af07b7004a06e6e03
Content-Type: text/plain; charset=UTF-8

On Apr 8, 2011 10:23 PM, "Dave Hansen" <dave@linux.vnet.ibm.com> wrote:
> +       if (fmt) {
> +               printk(KERN_WARNING);
> +               va_start(args, fmt);
> +               r = vprintk(fmt, args);
> +               va_end(args);
> +       }

Could we make the "printk(KERN_WARNING);" go away and require caller to
specify level?

> +       printk(KERN_WARNING);
> +       printk("%s: page allocation failure: order:%d, mode:0x%x\n",
> +                       current->comm, order, gfp_mask);

Even more so here. Why not pr_warning instead of two non-atomic calls to
printk?

--0016e65bb65af07b7004a06e6e03
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p>On Apr 8, 2011 10:23 PM, &quot;Dave Hansen&quot; &lt;<a href=3D"mailto:d=
ave@linux.vnet.ibm.com">dave@linux.vnet.ibm.com</a>&gt; wrote:<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 if (fmt) {<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNING=
);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 va_start(args, fmt)=
;<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 r =3D vprintk(fmt, =
args);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 va_end(args);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 }</p>
<p>Could we make the &quot;printk(KERN_WARNING);&quot; go away and require =
caller to specify level?=C2=A0 </p>
<p>&gt; + =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNING);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 printk(&quot;%s: page allocation failure: order=
:%d, mode:0x%x\n&quot;,<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 current-&gt;comm, order, gfp_mask);</p>
<p>Even more so here. Why not pr_warning instead of two non-atomic calls to=
 printk?</p>

--0016e65bb65af07b7004a06e6e03--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
