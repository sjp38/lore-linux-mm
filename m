Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 364DC6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 19:21:30 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id b40so2813423qcq.24
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:21:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130220001743.GE16950@blaptop>
References: <20130219044012.GA23356@lizard.sbx00618.mountca.wayport.net>
	<20130220001743.GE16950@blaptop>
Date: Tue, 19 Feb 2013 16:21:28 -0800
Message-ID: <CAOS58YOPjcH_pFFhPLJEAdaLkm5FoOy9mG2i-PkWAcb7O6V_Kw@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: Add memory.pressure_level events
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hello,

On Tue, Feb 19, 2013 at 4:17 PM, Minchan Kim <minchan@kernel.org> wrote:
> Should we really enable memcg for just pressure notificaion in embedded side?
> I didn't check the size(cgroup + memcg) and performance penalty but I don't want
> to add unnecessary overhead if it is possible.
> Do you have a plan to support it via global knob(ie, /proc/mempressure), NOT memcg?

That should be handled by mempressure at the root cgroup. If that adds
significant amount of overhead code or memory-wise, we just need to
fix root cgroup handling in memcg. No reason to further complicate the
interface which already is pretty complex.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
