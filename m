Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EE8F46B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 11:19:03 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so3431827gge.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 08:19:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 12 Mar 2012 11:19:03 -0400
Message-ID: <CAFLer81iFkuyQQc8M_AR9pULQDyrMYZux2s3KPK-3kGzB2XTKw@mail.gmail.com>
Subject: ClockPro in Linux MM
From: Zheng Da <zhengda1936@gmail.com>
Content-Type: multipart/alternative; boundary=20cf305b0df431c00e04bb0d4330
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--20cf305b0df431c00e04bb0d4330
Content-Type: text/plain; charset=ISO-8859-1

Hello,

I try to understand the Linux memory management. I was told Linux uses
ClockPro to manage page cache
and http://linux-mm.org/PageReplacementDesign also says so for file pages.
But when I read the ClockPro paper,
it doesn't look the same. The Linux implementation doesn't have
non-resident pages. Other than
that, it doesn't have the same test period mentioned in the paper. I wonder
if the Linux implementation
have the same effect as ClockPro. Could anyone confirm Linux is still using
ClockPro?

Thanks,
Da

--20cf305b0df431c00e04bb0d4330
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<span class=3D"Apple-style-span" style>Hello,<div><br></div><div>I try to u=
nderstand the Linux memory management. I was told Linux uses ClockPro to ma=
nage page cache=A0</div><div>and=A0<a href=3D"http://linux-mm.org/PageRepla=
cementDesign" target=3D"_blank" style=3D"color:rgb(17,85,204)">http://linux=
-mm.org/PageReplacementDesign</a>=A0also says so for file pages. But when I=
 read the ClockPro paper,</div>
<div>it doesn&#39;t look the same. The Linux implementation doesn&#39;t hav=
e non-resident pages. Other than</div><div>that, it doesn&#39;t have the sa=
me test period mentioned in the paper. I wonder if the Linux implementation=
</div>
<div>have the same effect as ClockPro. Could anyone confirm Linux is still =
using ClockPro?</div><div><br></div><div>Thanks,</div><div>Da</div></span>

--20cf305b0df431c00e04bb0d4330--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
