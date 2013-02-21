Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 374CF6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 18:08:14 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kq12so97537pab.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 15:08:13 -0800 (PST)
Date: Thu, 21 Feb 2013 15:04:26 -0800
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] memcg: Add memory.pressure_level events
Message-ID: <20130221230425.GA22792@lizard.fhda.edu>
References: <20130219044012.GA23356@lizard.sbx00618.mountca.wayport.net>
 <20130220001743.GE16950@blaptop>
 <CAOS58YOPjcH_pFFhPLJEAdaLkm5FoOy9mG2i-PkWAcb7O6V_Kw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOS58YOPjcH_pFFhPLJEAdaLkm5FoOy9mG2i-PkWAcb7O6V_Kw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, cgroups@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Feb 19, 2013 at 04:21:28PM -0800, Tejun Heo wrote:
> On Tue, Feb 19, 2013 at 4:17 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Should we really enable memcg for just pressure notificaion in embedded side?
> > I didn't check the size(cgroup + memcg) and performance penalty but I don't want
> > to add unnecessary overhead if it is possible.
> > Do you have a plan to support it via global knob(ie, /proc/mempressure), NOT memcg?
> 
> That should be handled by mempressure at the root cgroup. If that adds
> significant amount of overhead code or memory-wise, we just need to
> fix root cgroup handling in memcg. No reason to further complicate the
> interface which already is pretty complex.

For what it worth, I agree here. Even if we decide to make another
interface to vmpressure (which, say, would not require memcg), then it is
better to keep the API the same: eventfd + control file. That way,
API/ABI-wise there will be no differnce between memcg and non-memcg
kernels, which is cool.

Thanks,
Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
