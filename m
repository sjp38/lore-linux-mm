Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 612416B0184
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 18:13:43 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p9DMDdIk012686
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:13:40 -0700
Received: from vwm42 (vwm42.prod.google.com [10.241.20.42])
	by hpaq11.eem.corp.google.com with ESMTP id p9DM9GHi003355
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:13:38 -0700
Received: by vwm42 with SMTP id 42so794672vwm.8
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:13:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1318539490.3018.58.camel@dabdike.int.hansenpartnership.com>
References: <1316693805.10571.25.camel@dabdike>
	<20110926131027.GA14964@tiehlicka.suse.cz>
	<1317147379.9186.19.camel@dabdike.hansenpartnership.com>
	<20110929115419.GF21113@tiehlicka.suse.cz>
	<CANsGZ6Y-s8myrSZTyPNry0e29QczE2es6be0O1i0ro=zuz9hmA@mail.gmail.com>
	<CALWz4iw0HLtjkQPy7FRGyi4Ocm7+gtRujJWU_bWHbYK9fUSv5A@mail.gmail.com>
	<1318428864.3027.10.camel@dabdike.int.hansenpartnership.com>
	<CALWz4iwOA3AgSDoiVSHBGc81SLNBPu=yy2GF1hwU_9xDhvpfSg@mail.gmail.com>
	<1318539490.3018.58.camel@dabdike.int.hansenpartnership.com>
Date: Thu, 13 Oct 2011 15:13:37 -0700
Message-ID: <CALWz4izo0W9D7N5fh+hC_hTkR32_1kBH4FvUQL8S++k=wG8R0w@mail.gmail.com>
Subject: Re: Proposed memcg meeting at October Kernel Summit/European LinuxCon
 in Prague
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, Paul Turner <pjt@google.com>, Tim Hockin <thockin@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On Thu, Oct 13, 2011 at 1:58 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Thu, 2011-10-13 at 13:54 -0700, Ying Han wrote:
>> On Wed, Oct 12, 2011 at 7:14 AM, James Bottomley
>> <James.Bottomley@hansenpartnership.com> wrote:
>> > On Mon, 2011-10-10 at 19:35 -0700, Ying Han wrote:
>> >> On Thu, Sep 29, 2011 at 2:30 PM, Hugh Dickins <hughd@google.com> wrot=
e:
>> >> > On Thu, Sep 29, 2011 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrot=
e:
>> >> >> On Tue 27-09-11 13:16:19, James Bottomley wrote:
>> >> >> > On Mon, 2011-09-26 at 15:10 +0200, Michal Hocko wrote:
>> >> >> > > On Thu 22-09-11 12:16:47, James Bottomley wrote:
>> >> >> > > > Hi All,
>> >> >> > >
>> >> >> > > Hi,
>> >> >> > >
>> >> >> > > >
>> >> >> > > > One of the major work items that came out of the Plumbers co=
nference
>> >> >> > > > containers and Cgroups meeting was the need to work on memcg=
:
>> >> >> > > >
>> >> >> > > > http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/t=
racks/105
>> >> >> > > >
>> >> >> > > > (see etherpad and presentations)
>> >> >> > > >
>> >> >> > > > Since almost everyone will be either at KS or LinuxCon, I th=
ought doing
>> >> >> > > > a small meeting on the Wednesday of Linux Con (so those at K=
S who might
>> >> >> > > > not be staying for the whole of LinuxCon could attend) might=
 be a good
>> >> >> > > > idea. =A0The object would be to get all the major players to=
 agree on
>> >> >> > > > who's doing what. =A0You can see Parallels' direction from t=
he patches
>> >> >> > > > Glauber has been posting. =A0Google should shortly be starti=
ng work on
>> >> >> > > > other aspects of the memgc as well.
>> >> >> > > >
>> >> >> > > > As a precursor to the meeting (and actually a requirement to=
 make it
>> >> >> > > > effective) we need to start posting our preliminary patches =
and design
>> >> >> > > > ideas to the mm list (hint, Google people, this means you).
>> >> >> > > >
>> >> >> > > > I think I've got all of the interested parties in the To: fi=
eld, but I'm
>> >> >> > > > sending this to the mm list just in case I missed anyone. =
=A0If everyone's
>> >> >> > > > OK with the idea (and enough people are going to be there) I=
'll get the
>> >> >> > > > Linux Foundation to find us a room.
>> >> >> > >
>> >> >> > > I am not going to be at KS but I am in Prague. I would be happ=
y to meet
>> >> >> > > as well if it is possible.
>> >> >> >
>> >> >> > Certainly.
>> >> >>
>> >> >> OK, then add me as well.
>> >> >
>> >> > Please include Ying Han and Hugh Dickins; but regrettably, scheduli=
ng
>> >> > issues will prevent Greg Thelen from attending.
>> >>
>> >> Thank you Hugh. I will be in KS as well as the memcg meeting. Sorry
>> >> for the late reply due to OOO in the past few weeks.
>> >>
>> >> James,
>> >>
>> >> Thank you so much for organizing this and please keep us informed whe=
n
>> >> the detailed schedule is out :)
>> >
>> > We're a bit blocked on this. =A0We have some proposals, particularly i=
n
>> > the area of shrinkers, but we know you have patches in this area which
>> > we haven't seen ... can you post the google memgc patches just for
>> > reference (they don't have to be final, or even highly polished) just =
so
>> > we have a common base to work from?
>>
>> sorry for getting back late.
>>
>> We are preparing the patches and should be able to send out before the
>> summit. The patchset itself does the kernel slab accounting in memcg,
>> and something we would like to discuss in the memcg meeting in
>> Wednesday as well.
>
> Perfect, thanks. =A0This meshes well because we're trying to recast the
> Dentry cache patch in terms of slab accounting and we need to make sure
> our two patches are consistent.

I assume the dentry cache patch is the "[PATCH v3 0/4] Per-container
dcache limitation "?

Also, I am not sure where to get more information of the proposals
being sent so far for the meeting, and it would be helpful for us to
look through them before the day. Sorry if i missed it somewhere in
linux-mm :)

Thanks

--Ying


>
> James
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
