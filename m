Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3DF9A6B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 19:08:41 -0500 (EST)
Received: by eaal1 with SMTP id l1so2819756eaa.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 16:08:39 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: decode GFP flags in oom killer output.
References: <20120307233939.GB5574@redhat.com> <op.watq2ixr3l0zgt@mpn-glaptop>
 <20120308000233.GA10695@redhat.com>
Date: Thu, 08 Mar 2012 01:08:38 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.watr0ors3l0zgt@mpn-glaptop>
In-Reply-To: <20120308000233.GA10695@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 08 Mar 2012 01:02:33 +0100, Dave Jones <davej@redhat.com> wrote:=


> On Thu, Mar 08, 2012 at 12:48:08AM +0100, Michal Nazarewicz wrote:
> > >  static void dump_header(struct task_struct *p, gfp_t gfp_mask, in=
t order,
> > >  			struct mem_cgroup *memcg, const nodemask_t *nodemask)
> > >  {
> > > +	char gfp_string[80];
> >
> > For ~0, the string will be 256 characters followed by a NUL byte byt=
e at the end.
> > This combination may make no sense, but the point is that you need t=
o take length
> > of the buffer into account, probably by using snprintf() and a count=
er.
>
> alternatively, we could just use a bigger buffer here.

Allocating 257 bytes on stack does not seem like a good idea especially =
inside of
OOM killer, where probably quite a bit of the stack was already consumed=
 prior to
reaching this function.

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
