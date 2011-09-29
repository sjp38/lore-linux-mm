Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD2259000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 17:30:16 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8TLU8Eo008530
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:30:09 -0700
Received: from vcbf11 (vcbf11.prod.google.com [10.220.20.139])
	by wpaz33.hot.corp.google.com with ESMTP id p8TLTdac032073
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:30:07 -0700
Received: by vcbf11 with SMTP id f11so1397370vcb.25
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:30:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110929115419.GF21113@tiehlicka.suse.cz>
References: <1316693805.10571.25.camel@dabdike>
	<20110926131027.GA14964@tiehlicka.suse.cz>
	<1317147379.9186.19.camel@dabdike.hansenpartnership.com>
	<20110929115419.GF21113@tiehlicka.suse.cz>
Date: Thu, 29 Sep 2011 14:30:03 -0700
Message-ID: <CANsGZ6Y-s8myrSZTyPNry0e29QczE2es6be0O1i0ro=zuz9hmA@mail.gmail.com>
Subject: Re: Proposed memcg meeting at October Kernel Summit/European LinuxCon
 in Prague
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, Paul Turner <pjt@google.com>, Tim Hockin <thockin@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On Thu, Sep 29, 2011 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 27-09-11 13:16:19, James Bottomley wrote:
> > On Mon, 2011-09-26 at 15:10 +0200, Michal Hocko wrote:
> > > On Thu 22-09-11 12:16:47, James Bottomley wrote:
> > > > Hi All,
> > >
> > > Hi,
> > >
> > > >
> > > > One of the major work items that came out of the Plumbers conferenc=
e
> > > > containers and Cgroups meeting was the need to work on memcg:
> > > >
> > > > http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/tracks/1=
05
> > > >
> > > > (see etherpad and presentations)
> > > >
> > > > Since almost everyone will be either at KS or LinuxCon, I thought d=
oing
> > > > a small meeting on the Wednesday of Linux Con (so those at KS who m=
ight
> > > > not be staying for the whole of LinuxCon could attend) might be a g=
ood
> > > > idea. =C2=A0The object would be to get all the major players to agr=
ee on
> > > > who's doing what. =C2=A0You can see Parallels' direction from the p=
atches
> > > > Glauber has been posting. =C2=A0Google should shortly be starting w=
ork on
> > > > other aspects of the memgc as well.
> > > >
> > > > As a precursor to the meeting (and actually a requirement to make i=
t
> > > > effective) we need to start posting our preliminary patches and des=
ign
> > > > ideas to the mm list (hint, Google people, this means you).
> > > >
> > > > I think I've got all of the interested parties in the To: field, bu=
t I'm
> > > > sending this to the mm list just in case I missed anyone. =C2=A0If =
everyone's
> > > > OK with the idea (and enough people are going to be there) I'll get=
 the
> > > > Linux Foundation to find us a room.
> > >
> > > I am not going to be at KS but I am in Prague. I would be happy to me=
et
> > > as well if it is possible.
> >
> > Certainly.
>
> OK, then add me as well.

Please include Ying Han and Hugh Dickins; but regrettably, scheduling
issues will prevent Greg Thelen from attending.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
