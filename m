Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8931F6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:21:51 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so963861dal.1
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 14:21:50 -0800 (PST)
Date: Wed, 9 Jan 2013 14:21:44 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109222144.GF20454@htj.dyndns.org>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130109203731.GA20454@htj.dyndns.org>
 <50EDDF1E.6010705@parallels.com>
 <20130109213604.GA9475@lizard.fhda.edu>
 <20130109215514.GD20454@htj.dyndns.org>
 <20130109220641.GA12865@lizard.fhda.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109220641.GA12865@lizard.fhda.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello, Anton.

On Wed, Jan 09, 2013 at 02:06:41PM -0800, Anton Vorontsov wrote:
> Yeah. I started answering your comments about hierarchical accounting,
> looked into the memcg code, and realized that *this* is where I need the
> memcg stuff. :)

Yay, I wasn't completely clueless.

> Thus yes, I guess I'll have to integrate it with memcg, or sort of.

I really don't know much about memcg internals but I guess
implementation can be split into two pieces.  memcg already has its
own accounting and pressure mechanism so it should be possible to bolt
on the mempressure interface on top of already existing data.  You can
improve / bring some sanity :) to memcg if the proposed mempressure
implementation is better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
