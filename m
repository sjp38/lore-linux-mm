Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 839F98D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 03:31:07 -0500 (EST)
Date: Fri, 12 Nov 2010 09:31:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v2
Message-ID: <20101112083103.GB7285@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
 <20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
 <20101111093155.GA20630@tiehlicka.suse.cz>
 <20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri 12-11-10 09:41:18, Daisuke Nishimura wrote:
> On Thu, 11 Nov 2010 10:31:55 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 11-11-10 09:46:13, Daisuke Nishimura wrote:
> > > On Wed, 10 Nov 2010 13:51:54 +0100
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > Hi,
> > > > could you consider the patch bellow? It basically changes the default
> > > > swap accounting behavior (when it is turned on in configuration) to be
> > > > configurable as well. 
> > > > 
> > > > The rationale is described in the patch but in short it makes it much
> > > > more easier to enable this feature in distribution kernels as the
> > > > functionality can be provided in the general purpose kernel (with the
> > > > option disabled) without any drawbacks and interested users can enable
> > > > it. This is not possible currently.
> > > > 
> > > > I am aware that boot command line parameter name change is not ideal but
> > > > the original semantic wasn't good enough and I don't like
> > > > noswapaccount=yes|no very much. 
> > > > 
> > > > If we really have to stick to it I can rework the patch to keep the name
> > > > and just add the yes|no logic, though. Or we can keep the original one
> > > > and add swapaccount paramete which would mean the oposite as the other
> > > > one.
> > > > 
> > > hmm, I agree that current parameter name(noswapaccount) is not desirable
> > > for yes|no, but IMHO changing the user interface(iow, making what worked before 
> > > unusable) is worse.
> > > 
> > > Although I'm not sure how many people are using this parameter, I vote for
> > > using "noswapaccount[=(yes|no)]".
> > 
> > Isn't a new swapaccount parameter better than that? I know we don't want
> > to have too many parameters but having a something with a clear meaning
> > is better IMO (noswapaccount=no doesn't sound very intuitive to me).
> > 
> Fair enough. It's just an trade-off between compatibility and understandability.
> 
> > > And you should update Documentation/kernel-parameters.txt too.
> > 
> > Yes, I am aware of that and will do that once there is an agreement on
> > the patch itself. At this stage, I just wanted to have a feadback about
> > the change.
> > 
> I'll ack your patch when it's been released with documentation update.

Changes since v1:
* do not remove noswapaccount parameter and add swapaccount parameter
  instead
* Documentation/kernel-parameters.txt updated

--- 
