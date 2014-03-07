Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7826B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 19:57:29 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wo20so3420679obc.5
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:57:29 -0800 (PST)
Received: from mail-oa0-x22e.google.com (mail-oa0-x22e.google.com [2607:f8b0:4003:c02::22e])
        by mx.google.com with ESMTPS id tm2si4186170oeb.42.2014.03.06.16.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 16:57:28 -0800 (PST)
Received: by mail-oa0-f46.google.com with SMTP id i7so3493356oag.33
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:57:28 -0800 (PST)
Date: Thu, 6 Mar 2014 18:57:28 -0600
From: Eric Boxer <boxerspam1@gmail.com>
Message-ID: <A607A101-8758-4DC2-A77C-245BC45D8371@gmail.com>
In-Reply-To: <1394153488.2555.4.camel@buesod1.americas.hpqcorp.net>
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>
 <20140306004521.5D13DC05@viggo.jf.intel.com>
 <1394151380.2555.3.camel@buesod1.americas.hpqcorp.net>
 <1394153488.2555.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 1/7] x86: mm: clean up tlb flushing code
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="53191978_5bd062c2_72c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: ak@linux.intel.com, akpm@linux-foundation.org, alex.shi@linaro.org, linux-mm@kvack.org, mgorman@suse.de, x86@kernel.org, Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com

--53191978_5bd062c2_72c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Eric Boxer liked your message with Boxer. On March 6, 2014 at 6:51:28 PM =
CST, Davidlohr Bueso  wrote:On Thu, 2014-03-06 at 16:16 -0800, Davidlohr =
Bueso wrote:> On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:> > =46=
rom: Dave Hansen > > > > The> > > > if (cpumask=5Fany=5Fbut(mm=5Fcpumask(=
mm), smp=5Fprocessor=5Fid()) > > > > line of code is not exactly the easi=
est to audit, especially when> > it ends up at two different indentation =
levels. This eliminates> > one of the the copy-n-paste versions. It also =
gives us a unified> > exit point for each path through this function. We =
need this in> > a minute for our tracepoint.> > > > > > Signed-off-by: Da=
ve Hansen > > ---> > > > b/arch/x86/mm/tlb.c =7C 23 +++++++++++----------=
--> > 1 file changed, 11 insertions(+), 12 deletions(-)> > > > diff -puN =
arch/x86/mm/tlb.c=7Esimplify-tlb-code arch/x86/mm/tlb.c> > --- a/arch/x86=
/mm/tlb.c=7Esimplify-tlb-code 2014-03-05 16:10:09.607047728 -0800> > +++ =
b/arch/x86/mm/tlb.c 2014-03-05 16:10:09.610047866 -0800> > =40=40 -161,23=
 +161,24 =40=40 void flush=5Ftlb=5Fcurrent=5Ftask(void)> > void flush=5Ft=
lb=5Fmm=5Frange(struct mm=5Fstruct *mm, unsigned long start,> > unsigned =
long end, unsigned long vmflag)> > =7B> > + int need=5Fflush=5Fothers=5Fa=
ll =3D 1;> > nit: this can be bool.never mind, you get rid of it later.--=
To unsubscribe from this list: send the line =22unsubscribe linux-kernel=22=
 inthe body of a message to majordomo=40vger.kernel.orgMore majordomo inf=
o at http://vger.kernel.org/majordomo-info.htmlPlease read the =46AQ at h=
ttp://www.tux.org/lkml/     
--53191978_5bd062c2_72c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><body><div>Eric Boxer liked your message with <a href=3D=22http://a=
d.apps.fm/x3NHJParL2cT9cQ9WcgT1xM8G1T=5FLUvoWYXredpuoYBLq62ptJqsuhqD23uAm=
N=5FARL=5FcKzXIyDOjqo=5F2b16qX20uaphn=46WU7uPwUiYWuOAT=46UAGQB7Cox3TWT3ZK=
jzWyP=46IlhepnEZcRklQejqpibw=22>Boxer</a>.</div><br/><br/><div><div class=
=3D=22quote=22>On March 6, 2014 at 6:51:28 PM CST, Davidlohr Bueso <david=
lohr=40hp.com> wrote:<br/><blockquote type=3D=22cite=22 style=3D=22border=
-left-style:solid;border-width:1px;margin-left:0px;padding-left:10px;=22>=
On Thu, 2014-03-06 at 16:16 -0800, Davidlohr Bueso wrote:<br />> On Wed, =
2014-03-05 at 16:45 -0800, Dave Hansen wrote:<br />> > =46rom: Dave Hanse=
n <dave.hansen=40linux.intel.com><br />> > <br />> > The<br />> > <br />>=
 > 	if (cpumask=5Fany=5Fbut(mm=5Fcpumask(mm), smp=5Fprocessor=5Fid()) < n=
r=5Fcpu=5Fids)<br />> > <br />> > line of code is not exactly the easiest=
 to audit, especially when<br />> > it ends up at two different indentati=
on levels.  This eliminates<br />> > one of the the copy-n-paste versions=
.  It also gives us a unified<br />> > exit point for each path through t=
his function.  We need this in<br />> > a minute for our tracepoint.<br /=
>> > <br />> > <br />> > Signed-off-by: Dave Hansen <dave.hansen=40linux.=
intel.com><br />> > ---<br />> > <br />> >  b/arch/x86/mm/tlb.c =7C   23 =
+++++++++++------------<br />> >  1 file changed, 11 insertions(+), 12 de=
letions(-)<br />> > <br />> > diff -puN arch/x86/mm/tlb.c=7Esimplify-tlb-=
code arch/x86/mm/tlb.c<br />> > --- a/arch/x86/mm/tlb.c=7Esimplify-tlb-co=
de	2014-03-05 16:10:09.607047728 -0800<br />> > +++ b/arch/x86/mm/tlb.c	2=
014-03-05 16:10:09.610047866 -0800<br />> > =40=40 -161,23 +161,24 =40=40=
 void flush=5Ftlb=5Fcurrent=5Ftask(void)<br />> >  void flush=5Ftlb=5Fmm=5F=
range(struct mm=5Fstruct *mm, unsigned long start,<br />> >  				unsigned=
 long end, unsigned long vmflag)<br />> >  =7B<br />> > +	int need=5Fflus=
h=5Fothers=5Fall =3D 1;<br />> <br />> nit: this can be bool.<br /><br />=
never mind, you get rid of it later.<br /><br />--<br />To unsubscribe fr=
om this list: send the line =22unsubscribe linux-kernel=22 in<br />the bo=
dy of a message to majordomo=40vger.kernel.org<br />More majordomo info a=
t  http://vger.kernel.org/majordomo-info.html<br />Please read the =46AQ =
at  http://www.tux.org/lkml/<br /></blockquote></div></div></body></html>
--53191978_5bd062c2_72c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
