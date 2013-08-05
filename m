Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id BB8FB6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 03:20:17 -0400 (EDT)
Date: Mon, 5 Aug 2013 09:20:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130805072013.GA10146@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <51F9D1F6.4080001@jp.fujitsu.com>
 <20130731201708.efa5ae87.akpm@linux-foundation.org>
 <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
 <20130802073304.GA17746@dhcp22.suse.cz>
 <51FD653A.3060004@jp.fujitsu.com>
 <20130804080751.GA24005@dhcp22.suse.cz>
 <CAHGf_=o19rxB=neUPzZAeL9eeLnksKcbqCJjc+vg=EhYtnuwCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=o19rxB=neUPzZAeL9eeLnksKcbqCJjc+vg=EhYtnuwCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave.hansen@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Sun 04-08-13 21:13:44, KOSAKI Motohiro wrote:
> On Sun, Aug 4, 2013 at 4:07 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Sat 03-08-13 16:16:58, KOSAKI Motohiro wrote:
> >> >>> You missed the "!".  I'm proposing that setting the new bit 2 will
> >> >>> permit people to prevent the new printk if it is causing them problems.
> >> >>
> >> >> No I don't. I'm sure almost all abuse users think our usage is correct. Then,
> >> >> I can imagine all crazy applications start to use this flag eventually.
> >> >
> >> > I guess we do not care about those. If somebody wants to shoot his feet
> >> > then we cannot do much about it. The primary motivation was to find out
> >> > those that think this is right and they are willing to change the setup
> >> > once they know this is not the right way to do things.
> >> >
> >> > I think that giving a way to suppress the warning is a good step. Log
> >> > level might be to coarse and sysctl would be an overkill.
> >>
> >> When Dave Hansen reported this issue originally, he explained a lot of userland
> >> developer misuse /proc/drop_caches because they don't understand what
> >> drop_caches do.
> >> So, if they never understand the fact, why can we trust them? I have no
> >> idea.
> >
> > Well, most of that usage I have come across was legacy scripts which
> > happened to work at a certain point in time because we sucked.
> > Thinks have changed but such scripts happen to survive a long time.
> > We are primarily interested in those.
> 
> Well, if the main target is shell script, task_comm and pid don't help us
> a lot. I suggest to add ppid too.

I do not have any objections to add ppid.
 
> >> Or, if you have different motivation w/ Dave, please let me know it.
> >
> > We have seen reports where users complained about performance drop down
> > when in fact the real culprit turned out to be such a clever script
> > which dropped caches on the background thinking it will help to free
> > some memory. Such cases are tedious to reveal.
> 
> Imagine such script have bit-2 and no logging output. Because
> the script author think "we are doing the right thing".
> Why distro guys want such suppress messages?

I am not really pushing this suppressing functionality. I just
understand that there might be some legitimate use for supressing and if
that is a must for merging the printk, I can live with that.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
