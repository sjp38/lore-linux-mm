Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41EB66B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:39:21 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id l75so892634vke.20
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 03:39:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x125sor82984vkg.163.2018.04.18.03.39.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 03:39:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180418091943.GW17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com> <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz> <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
 <20180417190044.GK17484@dhcp22.suse.cz> <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
 <20180418090722.GV17484@dhcp22.suse.cz> <20180418091943.GW17484@dhcp22.suse.cz>
From: Li Wang <liwang@redhat.com>
Date: Wed, 18 Apr 2018 18:39:19 +0800
Message-ID: <CAEemH2evD8Gk6y_q41ygBZVwu--U9oKvnPh8xsrb5R27oLCBDA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Content-Type: multipart/alternative; boundary="001a1143db8846cb59056a1d113c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

--001a1143db8846cb59056a1d113c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 18, 2018 at 5:19 PM, Michal Hocko <mhocko@suse.com> wrote:

> On Wed 18-04-18 11:07:22, Michal Hocko wrote:
> > On Tue 17-04-18 16:09:33, Zi Yan wrote:
> [...]
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index f65dd69e1fd1..32afa4723e7f 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct *mm,
> nodemask_t task_nodes,
> > >                         if (err)
> > >                                 goto out;
> > >                 }
> > > +               /* Move to next page (i+1), after we have saved page
> status (until i) */
> > > +               start =3D i + 1;
> > >                 current_node =3D NUMA_NO_NODE;
> > >         }
> > >  out_flush:
> > >
> > > Feel free to check it by yourselves.
> >
> > Yes, you are right. I never update start if the last page in the range
> > fails and so we overwrite the whole [start, i] range. I wish the code
> > wasn't that ugly and subtle but considering how we can fail in differen=
t
> > ways and that we want to batch as much as possible I do not see an easy
> > way.
> >
> > Care to send the patch? I would just drop the comment.
>
> Hmm, thinking about it some more. An alternative would be to check for
> list_empty on the page list. It is a bit larger diff but maybe that
> would be tiny bit cleaner because there is simply no point to call
> do_move_pages_to_node on an empty list in the first place.
>

=E2=80=8BHi Michal, Zi

I tried your patch separately, both of them works fine to me.


--=20
Li Wang
liwang@redhat.com

--001a1143db8846cb59056a1d113c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:arial,he=
lvetica,sans-serif"><br></div><div class=3D"gmail_extra"><br><div class=3D"=
gmail_quote">On Wed, Apr 18, 2018 at 5:19 PM, Michal Hocko <span dir=3D"ltr=
">&lt;<a href=3D"mailto:mhocko@suse.com" target=3D"_blank">mhocko@suse.com<=
/a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:=
0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">=
<span class=3D"gmail-">On Wed 18-04-18 11:07:22, Michal Hocko wrote:<br>
&gt; On Tue 17-04-18 16:09:33, Zi Yan wrote:<br>
</span><span class=3D"gmail-">[...]<br>
&gt; &gt; diff --git a/mm/migrate.c b/mm/migrate.c<br>
</span><span class=3D"gmail-">&gt; &gt; index f65dd69e1fd1..32afa4723e7f 10=
0644<br>
&gt; &gt; --- a/mm/migrate.c<br>
&gt; &gt; +++ b/mm/migrate.c<br>
&gt; &gt; @@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct *=
mm, nodemask_t task_nodes,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0if (err)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br=
>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Move t=
o next page (i+1), after we have saved page status (until i) */<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0start =3D=
 i + 1;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0curr=
ent_node =3D NUMA_NO_NODE;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;=C2=A0 out_flush:<br>
&gt; &gt; <br>
&gt; &gt; Feel free to check it by yourselves.<br>
&gt; <br>
&gt; Yes, you are right. I never update start if the last page in the range=
<br>
&gt; fails and so we overwrite the whole [start, i] range. I wish the code<=
br>
&gt; wasn&#39;t that ugly and subtle but considering how we can fail in dif=
ferent<br>
&gt; ways and that we want to batch as much as possible I do not see an eas=
y<br>
&gt; way.<br>
&gt; <br>
&gt; Care to send the patch? I would just drop the comment.<br>
<br>
</span>Hmm, thinking about it some more. An alternative would be to check f=
or<br>
list_empty on the page list. It is a bit larger diff but maybe that<br>
would be tiny bit cleaner because there is simply no point to call<br>
do_move_pages_to_node on an empty list in the first place.<br></blockquote>=
<div><br><div style=3D"font-family:arial,helvetica,sans-serif" class=3D"gma=
il_default">=E2=80=8BHi Michal, Zi<br><br></div><div style=3D"font-family:a=
rial,helvetica,sans-serif" class=3D"gmail_default">I tried your patch separ=
ately<span style=3D"color:rgb(51,51,51);font-family:arial;font-size:18px;fo=
nt-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font=
-weight:normal;letter-spacing:normal;text-align:start;text-indent:0px;text-=
transform:none;white-space:normal;word-spacing:0px;background-color:rgb(255=
,255,255);text-decoration-style:initial;text-decoration-color:initial;displ=
ay:inline;float:none"></span>, both of them works fine to me.<br></div></di=
v></div><br clear=3D"all"><br>-- <br><div class=3D"gmail_signature">Li Wang=
<br><a href=3D"mailto:liwang@redhat.com" target=3D"_blank">liwang@redhat.co=
m</a></div>
</div></div>

--001a1143db8846cb59056a1d113c--
