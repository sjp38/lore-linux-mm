Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 22D056B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 18:56:10 -0500 (EST)
Date: Fri, 22 Feb 2013 08:56:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] memcg: Add memory.pressure_level events
Message-ID: <20130221235608.GH16950@blaptop>
References: <20130219044012.GA23356@lizard.sbx00618.mountca.wayport.net>
 <20130220001743.GE16950@blaptop>
 <CAOS58YOPjcH_pFFhPLJEAdaLkm5FoOy9mG2i-PkWAcb7O6V_Kw@mail.gmail.com>
 <20130221230425.GA22792@lizard.fhda.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130221230425.GA22792@lizard.fhda.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi Anton,

On Thu, Feb 21, 2013 at 03:04:26PM -0800, Anton Vorontsov wrote:
> On Tue, Feb 19, 2013 at 04:21:28PM -0800, Tejun Heo wrote:
> > On Tue, Feb 19, 2013 at 4:17 PM, Minchan Kim <minchan@kernel.org> wrote:
> > > Should we really enable memcg for just pressure notificaion in embedded side?
> > > I didn't check the size(cgroup + memcg) and performance penalty but I don't want
> > > to add unnecessary overhead if it is possible.
> > > Do you have a plan to support it via global knob(ie, /proc/mempressure), NOT memcg?
> > 
> > That should be handled by mempressure at the root cgroup. If that adds
> > significant amount of overhead code or memory-wise, we just need to
> > fix root cgroup handling in memcg. No reason to further complicate the
> > interface which already is pretty complex.
> 
> For what it worth, I agree here. Even if we decide to make another
> interface to vmpressure (which, say, would not require memcg), then it is
> better to keep the API the same: eventfd + control file. That way,
> API/ABI-wise there will be no differnce between memcg and non-memcg
> kernels, which is cool.

I tend to agree Tejun's opinion POV maintain and I don't have a number
of memcg static/dynamic effect for embedded side so I don't want to argue now.
AFAIRC, Mel reported last year that memcg had rather no small runtime effect
and some memcg guys are trying to solve it. The memcg guy among Cced guys of
this thread could answer that more clearly.

I don't care whatever API looks like. Of course, keeping the API the same is
always good if we decide to need it. The my point is that you have a plan
to support? Why I have a question is that you said your goal is to replace
lowmemory killer but android don't have enabled CONFIG_MEMCG as you know well
so they should enable it for using just notifier? or they need another hack to
connect notifier to global thing?

What's the plan?

> 
> Thanks,
> Anton
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
