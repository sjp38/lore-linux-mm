Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 748D06B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 03:12:32 -0400 (EDT)
Date: Mon, 21 May 2012 08:12:26 +0100
From: Richard Davies <richard.davies@elastichosts.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <20120521071226.GJ29495@alpha.arachsys.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <20120424082019.GA18395@alpha.arachsys.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C014649EC4D@USINDEVS02.corp.hds.com>
 <20120426142643.GA18863@alpha.arachsys.com>
 <CAHGf_=pcmFrWjfW3eQi_AiemQEm_e=gBZ24s+Hiythmd=J9EUQ@mail.gmail.com>
 <4FA82C11.2030805@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FA82C11.2030805@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Satoru Moriya <satoru.moriya@hds.com>, Jerome Marchand <jmarchan@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

Hi Satoru,

Rik van Riel wrote:
> KOSAKI Motohiro wrote:
> > Richard Davies wrote:
> > >Satoru Moriya wrote:
> > > > > I have run into problems with heavy swapping with swappiness==0 and
> > > > > was pointed to this thread (
> > > > > http://marc.info/?l=linux-mm&m=133522782307215 )
> > > >
> > > > Did you test this patch with your workload?
> > >
> > > I haven't yet tested this patch. It takes a long time since these are
> > > production machines, and the bug itself takes several weeks of
> > > production use to really show up.
> > >
> > > Rik van Riel has pointed out a lot of VM tweaks that he put into 3.4:
> > > http://marc.info/?l=linux-mm&m=133536506926326
> > >
> > > My intention is to reboot half of our machines into plain 3.4 once it
> > > is out, and half onto 3.4 + your patch.
> > >
> > > Then we can compare behaviour.
> > >
> > > Will your patch apply cleanly on 3.4?
> >
> > Note. This patch doesn't solve your issue. This patch mean,
> > when occuring very few swap io, it change to 0. But you said
> > you are seeing eager swap io. As Dave already pointed out, your
> > machine have buffer head issue.
> >
> > So, this thread is pointless.
>
> Running KVM guests directly off block devices results in a lot
> of buffer cache.
>
> I suspect that this patch will in fact fix Richard's issue.
>
> The patch is small, fairly simple and looks like it will fix
> people's problems. It also makes swappiness=0 behave the way
> most people seem to imagine it would work.
>
> If it works for a few people (test results), I believe we
> might as well merge it.
>
> Yes, for cgroups we may need additional logic, but we can
> sort that out as we go along.

Now that 3.4 is out with Rik's fixes, I'm keen to start testing with and
without this extra patch.

Satoru - should I just apply your original patch (most likely), or do you
need to update for the final released kernel?

Thanks,

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
