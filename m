Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id E547B6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 02:55:31 -0500 (EST)
Message-ID: <511B46FA.1090802@parallels.com>
Date: Wed, 13 Feb 2013 11:55:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
References: <20130211000220.GA28247@lizard.gateway.2wire.net> <5118C522.3070905@parallels.com> <20130213071922.GB20543@lizard.gateway.2wire.net>
In-Reply-To: <20130213071922.GB20543@lizard.gateway.2wire.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com


>>> +void __init enable_pressure_cgroup(void)
>>> +{
>>> +	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys,
>>> +				   vmpressure_cgroup_files));
>>> +}
>>
>> There is no functionality discovery going on here, and this is
>> conditional on nothing. Isn't it better then to just add the register +
>> read functions to memcontrol.c and add the files in the memcontrol cftype ?
> 
> I was trying to make the stuff similar to the existing CONFIG_MEMCG_SWAP
> code, which does this kind of adding files to the cgroup. But I can surely
> place files into memcontrol cftype as you suggest.
> 
> Thanks a lot for the comments!
> 
Note that swap can be command line disabled, and in that case we won't
register the files.

Then it makes sense to do it in a separate helper. If I understand your
code correctly, once it is compiled in, it will always be enabled. So I
personally think it is clearer if you register it together with the rest
of the crew.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
