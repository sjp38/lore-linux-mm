Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA0B6B0005
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:38:04 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id x12-v6so13093759ybp.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 07:38:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x4-v6sor1279295ywj.8.2018.11.14.07.38.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 07:38:03 -0800 (PST)
MIME-Version: 1.0
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz> <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
 <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
In-Reply-To: <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Wed, 14 Nov 2018 23:37:49 +0800
Message-ID: <CAJtqMcZr-UUBBzYZpbJ_+j-8Thg1GMy6G2=fnmoMgmgpS-Ojmw@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Content-Type: multipart/alternative; boundary="0000000000003bbada057aa1b8c2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0000000000003bbada057aa1b8c2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Mike,
Glad to get your reply.I am sorry for late reply because i am on business
trip today.I will tell more detail about the issue i met later.
And because i have no experience how to send a kernel patch correctly,so it
may takes some time for me to learn that before i resend the patch.

Best regards

On Wed, Nov 14, 2018 at 2:05 AM Mike Kravetz <mike.kravetz@oracle.com>
wrote:

> On 11/13/18 7:12 AM, Yongkai Wu wrote:
> > Dear Maintainer,
> > Actually i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When
> the issue first happen,
> > i just can know that it happen in free_huge_page() when doing soft
> offline huge page.
> > But because page->mapping is set to null,i can not get any further
> information how the issue happen.
> >
> > So i modified the code as the patch show,and apply the new code to our
> produce line and wait some time,
> > then the issue come again.And this time i can know the whole file path
> which trigger the issue by using
> > crash tool to get the inode=E3=80=81dentry and so on,that help me to fi=
nd a way
> to reproduce the issue quite easily
> > and finally found the root cause and solve it.
>
> Thank you for the information and the patch.
>
> As previously stated by Michal, please add some additional information to
> the
> change log (commit message) and fix the formatting of the patch.
>
> Can you tell us more about the root cause of your issue?  What was the
> issue?
> How could you reproduce it?  How did you solve it?
> --
> Mike Kravetz
>

--0000000000003bbada057aa1b8c2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Dear Mike,<div>Glad to get your reply.I a=
m sorry for late reply because i am on business trip today.I will tell more=
 detail about the issue i met later.</div><div>And because i have no experi=
ence how to send a kernel patch correctly,so it may takes some=C2=A0time fo=
r me to learn that before i resend the patch.</div><div><br></div><div>Best=
 regards</div></div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">O=
n Wed, Nov 14, 2018 at 2:05 AM Mike Kravetz &lt;<a href=3D"mailto:mike.krav=
etz@oracle.com">mike.kravetz@oracle.com</a>&gt; wrote:<br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">On 11/13/18 7:12 AM, Yongkai Wu wrote:<br>
&gt; Dear Maintainer,<br>
&gt; Actually i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When =
the issue first happen,<br>
&gt; i just can know that it happen in free_huge_page() when doing soft off=
line huge page.<br>
&gt; But because page-&gt;mapping is set to null,i can not get any further =
information how the issue happen.<br>
&gt; <br>
&gt; So i modified the code as the patch show,and apply the new code to our=
 produce line and wait some time,<br>
&gt; then the issue come again.And this time i can know the whole file path=
 which trigger the issue by using <br>
&gt; crash tool to get the inode=E3=80=81dentry and so on,that help me to f=
ind a way to reproduce the issue quite easily<br>
&gt; and finally found the root cause and solve it.<br>
<br>
Thank you for the information and the patch.<br>
<br>
As previously stated by Michal, please add some additional information to t=
he<br>
change log (commit message) and fix the formatting of the patch.<br>
<br>
Can you tell us more about the root cause of your issue?=C2=A0 What was the=
 issue?<br>
How could you reproduce it?=C2=A0 How did you solve it?<br>
-- <br>
Mike Kravetz<br>
</blockquote></div>

--0000000000003bbada057aa1b8c2--
