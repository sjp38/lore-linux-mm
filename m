Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C80AD6B0178
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:58:15 -0400 (EDT)
Subject: Re: Proposed memcg meeting at October Kernel Summit/European
 LinuxCon in Prague
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <CALWz4iwOA3AgSDoiVSHBGc81SLNBPu=yy2GF1hwU_9xDhvpfSg@mail.gmail.com>
References: <1316693805.10571.25.camel@dabdike>
	 <20110926131027.GA14964@tiehlicka.suse.cz>
	 <1317147379.9186.19.camel@dabdike.hansenpartnership.com>
	 <20110929115419.GF21113@tiehlicka.suse.cz>
	 <CANsGZ6Y-s8myrSZTyPNry0e29QczE2es6be0O1i0ro=zuz9hmA@mail.gmail.com>
	 <CALWz4iw0HLtjkQPy7FRGyi4Ocm7+gtRujJWU_bWHbYK9fUSv5A@mail.gmail.com>
	 <1318428864.3027.10.camel@dabdike.int.hansenpartnership.com>
	 <CALWz4iwOA3AgSDoiVSHBGc81SLNBPu=yy2GF1hwU_9xDhvpfSg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Oct 2011 15:58:10 -0500
Message-ID: <1318539490.3018.58.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, Paul Turner <pjt@google.com>, Tim Hockin <thockin@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On Thu, 2011-10-13 at 13:54 -0700, Ying Han wrote:
> On Wed, Oct 12, 2011 at 7:14 AM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> > On Mon, 2011-10-10 at 19:35 -0700, Ying Han wrote:
> >> On Thu, Sep 29, 2011 at 2:30 PM, Hugh Dickins <hughd@google.com> wrote:
> >> > On Thu, Sep 29, 2011 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> >> On Tue 27-09-11 13:16:19, James Bottomley wrote:
> >> >> > On Mon, 2011-09-26 at 15:10 +0200, Michal Hocko wrote:
> >> >> > > On Thu 22-09-11 12:16:47, James Bottomley wrote:
> >> >> > > > Hi All,
> >> >> > >
> >> >> > > Hi,
> >> >> > >
> >> >> > > >
> >> >> > > > One of the major work items that came out of the Plumbers conference
> >> >> > > > containers and Cgroups meeting was the need to work on memcg:
> >> >> > > >
> >> >> > > > http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/tracks/105
> >> >> > > >
> >> >> > > > (see etherpad and presentations)
> >> >> > > >
> >> >> > > > Since almost everyone will be either at KS or LinuxCon, I thought doing
> >> >> > > > a small meeting on the Wednesday of Linux Con (so those at KS who might
> >> >> > > > not be staying for the whole of LinuxCon could attend) might be a good
> >> >> > > > idea.  The object would be to get all the major players to agree on
> >> >> > > > who's doing what.  You can see Parallels' direction from the patches
> >> >> > > > Glauber has been posting.  Google should shortly be starting work on
> >> >> > > > other aspects of the memgc as well.
> >> >> > > >
> >> >> > > > As a precursor to the meeting (and actually a requirement to make it
> >> >> > > > effective) we need to start posting our preliminary patches and design
> >> >> > > > ideas to the mm list (hint, Google people, this means you).
> >> >> > > >
> >> >> > > > I think I've got all of the interested parties in the To: field, but I'm
> >> >> > > > sending this to the mm list just in case I missed anyone.  If everyone's
> >> >> > > > OK with the idea (and enough people are going to be there) I'll get the
> >> >> > > > Linux Foundation to find us a room.
> >> >> > >
> >> >> > > I am not going to be at KS but I am in Prague. I would be happy to meet
> >> >> > > as well if it is possible.
> >> >> >
> >> >> > Certainly.
> >> >>
> >> >> OK, then add me as well.
> >> >
> >> > Please include Ying Han and Hugh Dickins; but regrettably, scheduling
> >> > issues will prevent Greg Thelen from attending.
> >>
> >> Thank you Hugh. I will be in KS as well as the memcg meeting. Sorry
> >> for the late reply due to OOO in the past few weeks.
> >>
> >> James,
> >>
> >> Thank you so much for organizing this and please keep us informed when
> >> the detailed schedule is out :)
> >
> > We're a bit blocked on this.  We have some proposals, particularly in
> > the area of shrinkers, but we know you have patches in this area which
> > we haven't seen ... can you post the google memgc patches just for
> > reference (they don't have to be final, or even highly polished) just so
> > we have a common base to work from?
> 
> sorry for getting back late.
> 
> We are preparing the patches and should be able to send out before the
> summit. The patchset itself does the kernel slab accounting in memcg,
> and something we would like to discuss in the memcg meeting in
> Wednesday as well.

Perfect, thanks.  This meshes well because we're trying to recast the
Dentry cache patch in terms of slab accounting and we need to make sure
our two patches are consistent.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
