Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77EFF9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 19:33:01 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p8TNWwic005797
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 16:32:58 -0700
Received: from yie30 (yie30.prod.google.com [10.243.66.30])
	by wpaz9.hot.corp.google.com with ESMTP id p8TNWA7Z010092
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 16:32:57 -0700
Received: by yie30 with SMTP id 30so2412772yie.25
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 16:32:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANsGZ6Y-s8myrSZTyPNry0e29QczE2es6be0O1i0ro=zuz9hmA@mail.gmail.com>
References: <1316693805.10571.25.camel@dabdike> <20110926131027.GA14964@tiehlicka.suse.cz>
 <1317147379.9186.19.camel@dabdike.hansenpartnership.com> <20110929115419.GF21113@tiehlicka.suse.cz>
 <CANsGZ6Y-s8myrSZTyPNry0e29QczE2es6be0O1i0ro=zuz9hmA@mail.gmail.com>
From: Paul Turner <pjt@google.com>
Date: Thu, 29 Sep 2011 16:32:27 -0700
Message-ID: <CAPM31RJbaOMSbSRBv=jV8eiwNCb=dJQYjER6BmMSOdK=xwCY2A@mail.gmail.com>
Subject: Re: Proposed memcg meeting at October Kernel Summit/European LinuxCon
 in Prague
Content-Type: multipart/alternative; boundary=000e0cd598c2b493ae04ae1ced6c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, Tim Hockin <thockin@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

--000e0cd598c2b493ae04ae1ced6c
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Sep 29, 2011 at 2:30 PM, Hugh Dickins <hughd@google.com> wrote:

> On Thu, Sep 29, 2011 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Tue 27-09-11 13:16:19, James Bottomley wrote:
> > > On Mon, 2011-09-26 at 15:10 +0200, Michal Hocko wrote:
> > > > On Thu 22-09-11 12:16:47, James Bottomley wrote:
> > > > > Hi All,
> > > >
> > > > Hi,
> > > >
> > > > >
> > > > > One of the major work items that came out of the Plumbers
> conference
> > > > > containers and Cgroups meeting was the need to work on memcg:
> > > > >
> > > > >
> http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/tracks/105
> > > > >
> > > > > (see etherpad and presentations)
> > > > >
> > > > > Since almost everyone will be either at KS or LinuxCon, I thought
> doing
> > > > > a small meeting on the Wednesday of Linux Con (so those at KS who
> might
> > > > > not be staying for the whole of LinuxCon could attend) might be a
> good
> > > > > idea.  The object would be to get all the major players to agree on
> > > > > who's doing what.  You can see Parallels' direction from the
> patches
> > > > > Glauber has been posting.  Google should shortly be starting work
> on
> > > > > other aspects of the memgc as well.
> > > > >
> > > > > As a precursor to the meeting (and actually a requirement to make
> it
> > > > > effective) we need to start posting our preliminary patches and
> design
> > > > > ideas to the mm list (hint, Google people, this means you).
> > > > >
> > > > > I think I've got all of the interested parties in the To: field,
> but I'm
> > > > > sending this to the mm list just in case I missed anyone.  If
> everyone's
> > > > > OK with the idea (and enough people are going to be there) I'll get
> the
> > > > > Linux Foundation to find us a room.
> > > >
> > > > I am not going to be at KS but I am in Prague. I would be happy to
> meet
> > > > as well if it is possible.
> > >
> > > Certainly.
> >
> > OK, then add me as well.
>
> Please include Ying Han and Hugh Dickins; but regrettably, scheduling
> issues will prevent Greg Thelen from attending.
>
> Thanks,
> Hugh
>

Count me in as well,

Thanks James!

- Paul

--000e0cd598c2b493ae04ae1ced6c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Sep 29, 2011 at 2:30 PM, Hugh Di=
ckins <span dir=3D"ltr">&lt;<a href=3D"mailto:hughd@google.com">hughd@googl=
e.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<div class=3D"HOEnZb"><div class=3D"h5">On Thu, Sep 29, 2011 at 4:54 AM, Mi=
chal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>&gt; wro=
te:<br>
&gt; On Tue 27-09-11 13:16:19, James Bottomley wrote:<br>
&gt; &gt; On Mon, 2011-09-26 at 15:10 +0200, Michal Hocko wrote:<br>
&gt; &gt; &gt; On Thu 22-09-11 12:16:47, James Bottomley wrote:<br>
&gt; &gt; &gt; &gt; Hi All,<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Hi,<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; One of the major work items that came out of the Plumbe=
rs conference<br>
&gt; &gt; &gt; &gt; containers and Cgroups meeting was the need to work on =
memcg:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; <a href=3D"http://www.linuxplumbersconf.org/2011/ocw/ev=
ents/LPC2011MC/tracks/105" target=3D"_blank">http://www.linuxplumbersconf.o=
rg/2011/ocw/events/LPC2011MC/tracks/105</a><br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; (see etherpad and presentations)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Since almost everyone will be either at KS or LinuxCon,=
 I thought doing<br>
&gt; &gt; &gt; &gt; a small meeting on the Wednesday of Linux Con (so those=
 at KS who might<br>
&gt; &gt; &gt; &gt; not be staying for the whole of LinuxCon could attend) =
might be a good<br>
&gt; &gt; &gt; &gt; idea. =A0The object would be to get all the major playe=
rs to agree on<br>
&gt; &gt; &gt; &gt; who&#39;s doing what. =A0You can see Parallels&#39; dir=
ection from the patches<br>
&gt; &gt; &gt; &gt; Glauber has been posting. =A0Google should shortly be s=
tarting work on<br>
&gt; &gt; &gt; &gt; other aspects of the memgc as well.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; As a precursor to the meeting (and actually a requireme=
nt to make it<br>
&gt; &gt; &gt; &gt; effective) we need to start posting our preliminary pat=
ches and design<br>
&gt; &gt; &gt; &gt; ideas to the mm list (hint, Google people, this means y=
ou).<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I think I&#39;ve got all of the interested parties in t=
he To: field, but I&#39;m<br>
&gt; &gt; &gt; &gt; sending this to the mm list just in case I missed anyon=
e. =A0If everyone&#39;s<br>
&gt; &gt; &gt; &gt; OK with the idea (and enough people are going to be the=
re) I&#39;ll get the<br>
&gt; &gt; &gt; &gt; Linux Foundation to find us a room.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I am not going to be at KS but I am in Prague. I would be ha=
ppy to meet<br>
&gt; &gt; &gt; as well if it is possible.<br>
&gt; &gt;<br>
&gt; &gt; Certainly.<br>
&gt;<br>
&gt; OK, then add me as well.<br>
<br>
</div></div>Please include Ying Han and Hugh Dickins; but regrettably, sche=
duling<br>
issues will prevent Greg Thelen from attending.<br>
<br>
Thanks,<br>
<span class=3D"HOEnZb"><font color=3D"#888888">Hugh<br>
</font></span></blockquote></div><br><div>Count me in as well,=A0</div><div=
><br></div><div>Thanks James!</div><div><br></div><div>- Paul</div>

--000e0cd598c2b493ae04ae1ced6c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
