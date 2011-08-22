Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 312346B016B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 15:49:59 -0400 (EDT)
Message-ID: <BLU165-W518E4E2216B3E0FE0248EFFF2F0@phx.gbl>
Content-Type: multipart/alternative;
	boundary="_a9d98a8a-164d-43e3-ab30-f3c1acda5b90_"
From: Mark Petersen <mpete_06@hotmail.com>
Subject: RE: [Bugme-new] [Bug 41552] New: Performance of writing and reading
 from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4
 to 2.6.37 (and beyond)
Date: Mon, 22 Aug 2011 14:49:56 -0500
In-Reply-To: <20110822122443.c04839c8.akpm@linux-foundation.org>
References: 
 <bug-41552-10286@https.bugzilla.kernel.org/>,<20110822122443.c04839c8.akpm@linux-foundation.org>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bugme-daemon@bugzilla.kernel.org, axboe@kernel.dk, vgoyal@redhat.com, linux-mm@kvack.org, linux-scsi@vger.kernel.org

--_a9d98a8a-164d-43e3-ab30-f3c1acda5b90_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


The majority of the slowdown we found is coming during the writing as we we=
re doing limited reading for the purpose of the testing.  It may be that it=
 happens in both areas=2C but we did not do extensive testing with the read=
ing portion of it.

> Date: Mon=2C 22 Aug 2011 12:24:43 -0700
> From: akpm@linux-foundation.org
> To: mpete_06@hotmail.com
> CC: bugme-daemon@bugzilla.kernel.org=3B axboe@kernel.dk=3B vgoyal@redhat.=
com=3B linux-mm@kvack.org=3B linux-scsi@vger.kernel.org
> Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and read=
ing from multiple drives decreases by 40% when going from Linux Kernel 2.6.=
36.4 to 2.6.37 (and beyond)
>=20
>=20
> (switched to email.  Please respond via emailed reply-to-all=2C not via t=
he
> bugzilla web interface).
>=20
> On Mon=2C 22 Aug 2011 15:20:41 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D41552
> >=20
> >            Summary: Performance of writing and reading from multiple
> >                     drives decreases by 40% when going from Linux Kerne=
l
> >                     2.6.36.4 to 2.6.37 (and beyond)
> >            Product: IO/Storage
> >            Version: 2.5
> >     Kernel Version: 2.6.37
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: SCSI
> >         AssignedTo: linux-scsi@vger.kernel.org
> >         ReportedBy: mpete_06@hotmail.com
> >         Regression: No
> >=20
> >=20
> > We have an application that will write and read from every sector on a =
drive.=20
> > The application can perform these tasks on multiple drives at the same =
time.=20
> > It is designed to run on top of the Linux Kernel=2C which we periodical=
ly update
> > so that we can get the latest device drivers.  When performing the last=
 update
> > from 2.6.33.2 to 2.6.37=2C we found that the performance of a set of dr=
ives
> > decreased by some 40% (took 3 hours and 11 minutes to write and read fr=
om 5
> > drives on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was abl=
e to
> > determine that the issue was in the 2.6.37 Kernel as I was able to run =
it with
> > the 2.6.36.4 kernel=2C and it had the better performance.   After seein=
g that I/O
> > throttling was introduced in the 2.6.37 Kernel=2C I naturally suspected=
 that.=20
> > However=2C by default=2C all the throttling was turned off (I attached =
the actual
> > .config that was used to build the kernel).  I then tried to turn on th=
e
> > throttling and set it to a high number to see what would happen.  When =
I did
> > that=2C I was able to reduce the time from 3 hours and 11 minutes to 2 =
hours and
> > 50 minutes.  There seems to be something there that changed that is imp=
acting
> > performance on multiple drives.  When we do this same test with only on=
e drive=2C
> > the performance is identical between the systems.  This issue still occ=
urs on
> > Kernel 3.0.2.
> >=20
>=20
> Are you able to determine whether this regression is due to slower
> reading=2C to slower writing or to both?
>=20
> Thanks.
 		 	   		  =

--_a9d98a8a-164d-43e3-ab30-f3c1acda5b90_
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
The majority of the slowdown we found is coming during the writing as we we=
re doing limited reading for the purpose of the testing.&nbsp=3B It may be =
that it happens in both areas=2C but we did not do extensive testing with t=
he reading portion of it.<br><br><div>&gt=3B Date: Mon=2C 22 Aug 2011 12:24=
:43 -0700<br>&gt=3B From: akpm@linux-foundation.org<br>&gt=3B To: mpete_06@=
hotmail.com<br>&gt=3B CC: bugme-daemon@bugzilla.kernel.org=3B axboe@kernel.=
dk=3B vgoyal@redhat.com=3B linux-mm@kvack.org=3B linux-scsi@vger.kernel.org=
<br>&gt=3B Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing=
 and reading from multiple drives decreases by 40% when going from Linux Ke=
rnel 2.6.36.4 to 2.6.37 (and beyond)<br>&gt=3B <br>&gt=3B <br>&gt=3B (switc=
hed to email.  Please respond via emailed reply-to-all=2C not via the<br>&g=
t=3B bugzilla web interface).<br>&gt=3B <br>&gt=3B On Mon=2C 22 Aug 2011 15=
:20:41 GMT<br>&gt=3B bugzilla-daemon@bugzilla.kernel.org wrote:<br>&gt=3B <=
br>&gt=3B &gt=3B https://bugzilla.kernel.org/show_bug.cgi?id=3D41552<br>&gt=
=3B &gt=3B <br>&gt=3B &gt=3B            Summary: Performance of writing and=
 reading from multiple<br>&gt=3B &gt=3B                     drives decrease=
s by 40% when going from Linux Kernel<br>&gt=3B &gt=3B                     =
2.6.36.4 to 2.6.37 (and beyond)<br>&gt=3B &gt=3B            Product: IO/Sto=
rage<br>&gt=3B &gt=3B            Version: 2.5<br>&gt=3B &gt=3B     Kernel V=
ersion: 2.6.37<br>&gt=3B &gt=3B           Platform: All<br>&gt=3B &gt=3B   =
      OS/Version: Linux<br>&gt=3B &gt=3B               Tree: Mainline<br>&g=
t=3B &gt=3B             Status: NEW<br>&gt=3B &gt=3B           Severity: no=
rmal<br>&gt=3B &gt=3B           Priority: P1<br>&gt=3B &gt=3B          Comp=
onent: SCSI<br>&gt=3B &gt=3B         AssignedTo: linux-scsi@vger.kernel.org=
<br>&gt=3B &gt=3B         ReportedBy: mpete_06@hotmail.com<br>&gt=3B &gt=3B=
         Regression: No<br>&gt=3B &gt=3B <br>&gt=3B &gt=3B <br>&gt=3B &gt=
=3B We have an application that will write and read from every sector on a =
drive. <br>&gt=3B &gt=3B The application can perform these tasks on multipl=
e drives at the same time. <br>&gt=3B &gt=3B It is designed to run on top o=
f the Linux Kernel=2C which we periodically update<br>&gt=3B &gt=3B so that=
 we can get the latest device drivers.  When performing the last update<br>=
&gt=3B &gt=3B from 2.6.33.2 to 2.6.37=2C we found that the performance of a=
 set of drives<br>&gt=3B &gt=3B decreased by some 40% (took 3 hours and 11 =
minutes to write and read from 5<br>&gt=3B &gt=3B drives on 2.6.37 versus 2=
 hours and 12 minutes on 2.6.33.3).  I was able to<br>&gt=3B &gt=3B determi=
ne that the issue was in the 2.6.37 Kernel as I was able to run it with<br>=
&gt=3B &gt=3B the 2.6.36.4 kernel=2C and it had the better performance.   A=
fter seeing that I/O<br>&gt=3B &gt=3B throttling was introduced in the 2.6.=
37 Kernel=2C I naturally suspected that. <br>&gt=3B &gt=3B However=2C by de=
fault=2C all the throttling was turned off (I attached the actual<br>&gt=3B=
 &gt=3B .config that was used to build the kernel).  I then tried to turn o=
n the<br>&gt=3B &gt=3B throttling and set it to a high number to see what w=
ould happen.  When I did<br>&gt=3B &gt=3B that=2C I was able to reduce the =
time from 3 hours and 11 minutes to 2 hours and<br>&gt=3B &gt=3B 50 minutes=
.  There seems to be something there that changed that is impacting<br>&gt=
=3B &gt=3B performance on multiple drives.  When we do this same test with =
only one drive=2C<br>&gt=3B &gt=3B the performance is identical between the=
 systems.  This issue still occurs on<br>&gt=3B &gt=3B Kernel 3.0.2.<br>&gt=
=3B &gt=3B <br>&gt=3B <br>&gt=3B Are you able to determine whether this reg=
ression is due to slower<br>&gt=3B reading=2C to slower writing or to both?=
<br>&gt=3B <br>&gt=3B Thanks.<br></div> 		 	   		  </div></body>
</html>=

--_a9d98a8a-164d-43e3-ab30-f3c1acda5b90_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
