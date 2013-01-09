Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E5C746B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:04:12 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so952704dak.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 14:04:12 -0800 (PST)
Date: Wed, 9 Jan 2013 14:04:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109220406.GE20454@htj.dyndns.org>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130109203731.GA20454@htj.dyndns.org>
 <50EDDF1E.6010705@parallels.com>
 <20130109213604.GA9475@lizard.fhda.edu>
 <20130109215514.GD20454@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109215514.GD20454@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org

On Wed, Jan 09, 2013 at 01:55:14PM -0800, Tejun Heo wrote:
> Please talk with memcg people and fold it into memcg.  It can (and
> should) be done in a way to not incur overhead when only root memcg is
> in use and how this is done defines userland-visible interface, so
> let's please not repeat past mistakes.

CC'ing KAMEZAWA, Johannes, Li and cgroup mailing list.  Please keep
them cc'd for further discussion.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
