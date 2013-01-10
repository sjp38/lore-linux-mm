Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id DE2CD6B004D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 02:18:21 -0500 (EST)
Message-ID: <50EE6B41.8030205@parallels.com>
Date: Thu, 10 Jan 2013 11:18:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add mempressure cgroup
References: <20130104082751.GA22227@lizard.gateway.2wire.net> <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org> <20130109203731.GA20454@htj.dyndns.org> <50EDDF1E.6010705@parallels.com> <20130109213604.GA9475@lizard.fhda.edu> <20130109215514.GD20454@htj.dyndns.org> <20130109220641.GA12865@lizard.fhda.edu>
In-Reply-To: <20130109220641.GA12865@lizard.fhda.edu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka
 Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz
 Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid
 Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 01/10/2013 02:06 AM, Anton Vorontsov wrote:
> On Wed, Jan 09, 2013 at 01:55:14PM -0800, Tejun Heo wrote:
> [...]
>>> We can use mempressure w/o memcg, and even then it can (or should :) be
>>> useful (for cpuset, for example).
>>
>> The problem is that you end with, at the very least, duplicate
>> hierarchical accounting mechanisms which overlap with each other
>> while, most likely, being slightly different.  About the same thing
>> happened with cpu and cpuacct controllers and we're now trying to
>> deprecate the latter.
> 
> Yeah. I started answering your comments about hierarchical accounting,
> looked into the memcg code, and realized that *this* is where I need the
> memcg stuff. :)
> 
> Thus yes, I guess I'll have to integrate it with memcg, or sort of.
> 

That being my point since the beginning. To generate per-memcg pressure,
you need memcg anyway. So you would have to have two different and
orthogonal mechanisms, and therefore, double account.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
