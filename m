Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1527F6B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:28:10 -0400 (EDT)
Message-ID: <BLU165-W36430597C0DF39473213B8FF2F0@phx.gbl>
Content-Type: multipart/alternative;
	boundary="_c058eb12-408f-4944-b239-23bdedb827c3_"
From: Mark Petersen <mpete_06@hotmail.com>
Subject: RE: [Bugme-new] [Bug 41552] New: Performance of writing and reading
 from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4
 to 2.6.37 (and beyond)
Date: Mon, 22 Aug 2011 15:28:08 -0500
In-Reply-To: <20110822195651.GB15087@redhat.com>
References: 
 <bug-41552-10286@https.bugzilla.kernel.org/>,<20110822122443.c04839c8.akpm@linux-foundation.org>,<BLU165-W518E4E2216B3E0FE0248EFFF2F0@phx.gbl>,<20110822195651.GB15087@redhat.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com
Cc: akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org, axboe@kernel.dk, linux-mm@kvack.org, linux-scsi@vger.kernel.org

--_c058eb12-408f-4944-b239-23bdedb827c3_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


The writes we are performing are SCSI commands directly to the device=2C on=
e sector at a time.  The only thing we changed between our updates was the =
Kernel itself=2C which we leave everything in there at its default value if=
 it is enabled (we disable a great many things we don't need).  The latest =
version I tried that still showed the issue was v3.0.1.

Thanks=2C
Mark

> Date: Mon=2C 22 Aug 2011 15:56:51 -0400
> From: vgoyal@redhat.com
> To: mpete_06@hotmail.com
> CC: akpm@linux-foundation.org=3B bugme-daemon@bugzilla.kernel.org=3B axbo=
e@kernel.dk=3B linux-mm@kvack.org=3B linux-scsi@vger.kernel.org
> Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and read=
ing from multiple drives decreases by 40% when going from Linux Kernel 2.6.=
36.4 to 2.6.37 (and beyond)
>=20
> On Mon=2C Aug 22=2C 2011 at 02:49:56PM -0500=2C Mark Petersen wrote:
> >=20
> > The majority of the slowdown we found is coming during the writing as w=
e were doing limited reading for the purpose of the testing.  It may be tha=
t it happens in both areas=2C but we did not do extensive testing with the =
reading portion of it.
>=20
> What kind of writes these are? Write slowdown by 40%. Somehow now a days
> barriers/flush/fua comes to my mind. Any changes there w.r.t your setup?
>=20
> Recently Jeff moyer and Mike Snitzer had discovered and fixed a slowdown
> in a dm-multipath and disks not having write caches. I guess that's not
> your setup. Though mentioning it does not harm.
>=20
> Thanks
> Vivek
>=20
> =20
> >=20
> > > Date: Mon=2C 22 Aug 2011 12:24:43 -0700
> > > From: akpm@linux-foundation.org
> > > To: mpete_06@hotmail.com
> > > CC: bugme-daemon@bugzilla.kernel.org=3B axboe@kernel.dk=3B vgoyal@red=
hat.com=3B linux-mm@kvack.org=3B linux-scsi@vger.kernel.org
> > > Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and =
reading from multiple drives decreases by 40% when going from Linux Kernel =
2.6.36.4 to 2.6.37 (and beyond)
> > >=20
> > >=20
> > > (switched to email.  Please respond via emailed reply-to-all=2C not v=
ia the
> > > bugzilla web interface).
> > >=20
> > > On Mon=2C 22 Aug 2011 15:20:41 GMT
> > > bugzilla-daemon@bugzilla.kernel.org wrote:
> > >=20
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=3D41552
> > > >=20
> > > >            Summary: Performance of writing and reading from multipl=
e
> > > >                     drives decreases by 40% when going from Linux K=
ernel
> > > >                     2.6.36.4 to 2.6.37 (and beyond)
> > > >            Product: IO/Storage
> > > >            Version: 2.5
> > > >     Kernel Version: 2.6.37
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: normal
> > > >           Priority: P1
> > > >          Component: SCSI
> > > >         AssignedTo: linux-scsi@vger.kernel.org
> > > >         ReportedBy: mpete_06@hotmail.com
> > > >         Regression: No
> > > >=20
> > > >=20
> > > > We have an application that will write and read from every sector o=
n a drive.=20
> > > > The application can perform these tasks on multiple drives at the s=
ame time.=20
> > > > It is designed to run on top of the Linux Kernel=2C which we period=
ically update
> > > > so that we can get the latest device drivers.  When performing the =
last update
> > > > from 2.6.33.2 to 2.6.37=2C we found that the performance of a set o=
f drives
> > > > decreased by some 40% (took 3 hours and 11 minutes to write and rea=
d from 5
> > > > drives on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was=
 able to
> > > > determine that the issue was in the 2.6.37 Kernel as I was able to =
run it with
> > > > the 2.6.36.4 kernel=2C and it had the better performance.   After s=
eeing that I/O
> > > > throttling was introduced in the 2.6.37 Kernel=2C I naturally suspe=
cted that.=20
> > > > However=2C by default=2C all the throttling was turned off (I attac=
hed the actual
> > > > .config that was used to build the kernel).  I then tried to turn o=
n the
> > > > throttling and set it to a high number to see what would happen.  W=
hen I did
> > > > that=2C I was able to reduce the time from 3 hours and 11 minutes t=
o 2 hours and
> > > > 50 minutes.  There seems to be something there that changed that is=
 impacting
> > > > performance on multiple drives.  When we do this same test with onl=
y one drive=2C
> > > > the performance is identical between the systems.  This issue still=
 occurs on
> > > > Kernel 3.0.2.
> > > >=20
> > >=20
> > > Are you able to determine whether this regression is due to slower
> > > reading=2C to slower writing or to both?
> > >=20
> > > Thanks.
> >  		 	   		 =20
 		 	   		  =

--_c058eb12-408f-4944-b239-23bdedb827c3_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style><!--
.hmmessage P
{
margin:0px=3B
padding:0px
}
body.hmmessage
{
font-size: 10pt=3B
font-family:Tahoma
}
--></style>
</head>
<body class=3D'hmmessage'><div dir=3D'ltr'>
The writes we are performing are SCSI commands directly to the device=2C on=
e sector at a time.&nbsp=3B The only thing we changed between our updates w=
as the Kernel itself=2C which we leave everything in there at its default v=
alue if it is enabled (we disable a great many things we don't need).&nbsp=
=3B The latest version I tried that still showed the issue was v3.0.1.<br><=
br>Thanks=2C<br>Mark<br><br><div>&gt=3B Date: Mon=2C 22 Aug 2011 15:56:51 -=
0400<br>&gt=3B From: vgoyal@redhat.com<br>&gt=3B To: mpete_06@hotmail.com<b=
r>&gt=3B CC: akpm@linux-foundation.org=3B bugme-daemon@bugzilla.kernel.org=
=3B axboe@kernel.dk=3B linux-mm@kvack.org=3B linux-scsi@vger.kernel.org<br>=
&gt=3B Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and=
 reading from multiple drives decreases by 40% when going from Linux Kernel=
 2.6.36.4 to 2.6.37 (and beyond)<br>&gt=3B <br>&gt=3B On Mon=2C Aug 22=2C 2=
011 at 02:49:56PM -0500=2C Mark Petersen wrote:<br>&gt=3B &gt=3B <br>&gt=3B=
 &gt=3B The majority of the slowdown we found is coming during the writing =
as we were doing limited reading for the purpose of the testing.  It may be=
 that it happens in both areas=2C but we did not do extensive testing with =
the reading portion of it.<br>&gt=3B <br>&gt=3B What kind of writes these a=
re? Write slowdown by 40%. Somehow now a days<br>&gt=3B barriers/flush/fua =
comes to my mind. Any changes there w.r.t your setup?<br>&gt=3B <br>&gt=3B =
Recently Jeff moyer and Mike Snitzer had discovered and fixed a slowdown<br=
>&gt=3B in a dm-multipath and disks not having write caches. I guess that's=
 not<br>&gt=3B your setup. Though mentioning it does not harm.<br>&gt=3B <b=
r>&gt=3B Thanks<br>&gt=3B Vivek<br>&gt=3B <br>&gt=3B  <br>&gt=3B &gt=3B <br=
>&gt=3B &gt=3B &gt=3B Date: Mon=2C 22 Aug 2011 12:24:43 -0700<br>&gt=3B &gt=
=3B &gt=3B From: akpm@linux-foundation.org<br>&gt=3B &gt=3B &gt=3B To: mpet=
e_06@hotmail.com<br>&gt=3B &gt=3B &gt=3B CC: bugme-daemon@bugzilla.kernel.o=
rg=3B axboe@kernel.dk=3B vgoyal@redhat.com=3B linux-mm@kvack.org=3B linux-s=
csi@vger.kernel.org<br>&gt=3B &gt=3B &gt=3B Subject: Re: [Bugme-new] [Bug 4=
1552] New: Performance of writing and reading from multiple drives decrease=
s by 40% when going from Linux Kernel 2.6.36.4 to 2.6.37 (and beyond)<br>&g=
t=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B (switc=
hed to email.  Please respond via emailed reply-to-all=2C not via the<br>&g=
t=3B &gt=3B &gt=3B bugzilla web interface).<br>&gt=3B &gt=3B &gt=3B <br>&gt=
=3B &gt=3B &gt=3B On Mon=2C 22 Aug 2011 15:20:41 GMT<br>&gt=3B &gt=3B &gt=
=3B bugzilla-daemon@bugzilla.kernel.org wrote:<br>&gt=3B &gt=3B &gt=3B <br>=
&gt=3B &gt=3B &gt=3B &gt=3B https://bugzilla.kernel.org/show_bug.cgi?id=3D4=
1552<br>&gt=3B &gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B &gt=3B        =
    Summary: Performance of writing and reading from multiple<br>&gt=3B &gt=
=3B &gt=3B &gt=3B                     drives decreases by 40% when going fr=
om Linux Kernel<br>&gt=3B &gt=3B &gt=3B &gt=3B                     2.6.36.4=
 to 2.6.37 (and beyond)<br>&gt=3B &gt=3B &gt=3B &gt=3B            Product: =
IO/Storage<br>&gt=3B &gt=3B &gt=3B &gt=3B            Version: 2.5<br>&gt=3B=
 &gt=3B &gt=3B &gt=3B     Kernel Version: 2.6.37<br>&gt=3B &gt=3B &gt=3B &g=
t=3B           Platform: All<br>&gt=3B &gt=3B &gt=3B &gt=3B         OS/Vers=
ion: Linux<br>&gt=3B &gt=3B &gt=3B &gt=3B               Tree: Mainline<br>&=
gt=3B &gt=3B &gt=3B &gt=3B             Status: NEW<br>&gt=3B &gt=3B &gt=3B =
&gt=3B           Severity: normal<br>&gt=3B &gt=3B &gt=3B &gt=3B           =
Priority: P1<br>&gt=3B &gt=3B &gt=3B &gt=3B          Component: SCSI<br>&gt=
=3B &gt=3B &gt=3B &gt=3B         AssignedTo: linux-scsi@vger.kernel.org<br>=
&gt=3B &gt=3B &gt=3B &gt=3B         ReportedBy: mpete_06@hotmail.com<br>&gt=
=3B &gt=3B &gt=3B &gt=3B         Regression: No<br>&gt=3B &gt=3B &gt=3B &gt=
=3B <br>&gt=3B &gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B &gt=3B We have=
 an application that will write and read from every sector on a drive. <br>=
&gt=3B &gt=3B &gt=3B &gt=3B The application can perform these tasks on mult=
iple drives at the same time. <br>&gt=3B &gt=3B &gt=3B &gt=3B It is designe=
d to run on top of the Linux Kernel=2C which we periodically update<br>&gt=
=3B &gt=3B &gt=3B &gt=3B so that we can get the latest device drivers.  Whe=
n performing the last update<br>&gt=3B &gt=3B &gt=3B &gt=3B from 2.6.33.2 t=
o 2.6.37=2C we found that the performance of a set of drives<br>&gt=3B &gt=
=3B &gt=3B &gt=3B decreased by some 40% (took 3 hours and 11 minutes to wri=
te and read from 5<br>&gt=3B &gt=3B &gt=3B &gt=3B drives on 2.6.37 versus 2=
 hours and 12 minutes on 2.6.33.3).  I was able to<br>&gt=3B &gt=3B &gt=3B =
&gt=3B determine that the issue was in the 2.6.37 Kernel as I was able to r=
un it with<br>&gt=3B &gt=3B &gt=3B &gt=3B the 2.6.36.4 kernel=2C and it had=
 the better performance.   After seeing that I/O<br>&gt=3B &gt=3B &gt=3B &g=
t=3B throttling was introduced in the 2.6.37 Kernel=2C I naturally suspecte=
d that. <br>&gt=3B &gt=3B &gt=3B &gt=3B However=2C by default=2C all the th=
rottling was turned off (I attached the actual<br>&gt=3B &gt=3B &gt=3B &gt=
=3B .config that was used to build the kernel).  I then tried to turn on th=
e<br>&gt=3B &gt=3B &gt=3B &gt=3B throttling and set it to a high number to =
see what would happen.  When I did<br>&gt=3B &gt=3B &gt=3B &gt=3B that=2C I=
 was able to reduce the time from 3 hours and 11 minutes to 2 hours and<br>=
&gt=3B &gt=3B &gt=3B &gt=3B 50 minutes.  There seems to be something there =
that changed that is impacting<br>&gt=3B &gt=3B &gt=3B &gt=3B performance o=
n multiple drives.  When we do this same test with only one drive=2C<br>&gt=
=3B &gt=3B &gt=3B &gt=3B the performance is identical between the systems. =
 This issue still occurs on<br>&gt=3B &gt=3B &gt=3B &gt=3B Kernel 3.0.2.<br=
>&gt=3B &gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=
=3B Are you able to determine whether this regression is due to slower<br>&=
gt=3B &gt=3B &gt=3B reading=2C to slower writing or to both?<br>&gt=3B &gt=
=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B Thanks.<br>&gt=3B &gt=3B  		 	   		  <b=
r></div> 		 	   		  </div></body>
</html>=

--_c058eb12-408f-4944-b239-23bdedb827c3_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
