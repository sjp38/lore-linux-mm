Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id CEBE76B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 13:54:28 -0500 (EST)
Message-ID: <4EF37CC5.7060503@am.sony.com>
Date: Thu, 22 Dec 2011 10:53:57 -0800
From: Frank Rowand <frank.rowand@am.sony.com>
Reply-To: <frank.rowand@am.sony.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219121255.GA2086@tiehlicka.suse.cz> <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com> <20111220145654.GA26881@oksana.dev.rtsoft.ru> <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com> <20111221002853.GA11504@oksana.dev.rtsoft.ru> <4EF132EA.7000300@am.sony.com> <CAHGf_=r8=aG=BZLTjmZtkW6gcdkK=GU8g=5L57Fspx_DaA7Czw@mail.gmail.com>
In-Reply-To: <CAHGf_=r8=aG=BZLTjmZtkW6gcdkK=GU8g=5L57Fspx_DaA7Czw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rowand, Frank" <Frank_Rowand@sonyusa.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "tbird20d@gmail.com" <tbird20d@gmail.com>

On 12/21/11 17:16, KOSAKI Motohiro wrote:
>>> So for 2MB kernel that's about 20KB of an additional text... This seems
>>> affordable, especially as a trade-off for the things that cgroups may
>>> provide.
>>
>> A comment from http://lkml.indiana.edu/hypermail/linux/kernel/1102.1/00412.html:
>>
>> "I care about 5K. (But honestly, I don't actively hunt stuff less than
>> 10K in size, because there's too many of them to chase, currently)."
> 
> Hm, interesting. Because of, current memory cgroup notification was
> made by a request from Sony and CELinux. AFAIK, at least, Sony
> are already using cgroups.

Sony makes a very large range of products.  The memory available on the
different products can range from a few megabytes to hundreds of megabytes
(and I wouldn't be surprised if the top of the range is gigabytes).

Our low memory products lead us to be concerned about the growth in
memory usage by newer kernel versions.  Of course we also like additional
features and kernel improvements, so we understand the balancing act of
features requiring more memory, while at the same time discouraging
memory growth for resource constrained systems.  Config options are
one of the tools used to manage that balancing act.

>>> The fact is, for desktop and server Linux, cgroups slowly becomes a
>>> mandatory thing. And the reason for this is that cgroups mechanism
>>> provides some very useful features (in an extensible way, like plugins),
>>> i.e. a way to manage and track processes and its resources -- which is the
>>> main purpose of cgroups.
>>
>> And for embedded and for real-time, some of us do not want cgroups to be
>> a mandatory thing.  We want it to remain configurable.  My personal
>> interest is in keeping the latency of certain critical paths (especially
>> in the scheduler) short and consistent.
> 
> As far as I observed, modern embedded system have both RT and no RT process.
> Java VM or user downloadable programs may need memory notification
> because users may download bad programs. in the other hand, rt
> processes are not downloadable and much tested by hardware vendor. So,
> I think you only need
> split process between under cgroups and not under cgroups.
> 
> cgroups have zero or much likely zero overhead if the processes don't use it.
> Of course, feedback are welcome. I'm interesting your embedded usecase.

No, cgroups have _near_ zero overhead when the cgroup configuration option is
turned off. :-)  (Sorry, being pedantic, but still serious.)

Again, we have many different products.  Some may find cgroups to be useful.
But at least one of our product groups totally removed the cgroups source code
from their scheduler as part of their focus on reducing latency.

We have to think about a wide range of (sometimes conflicting)
requirements.  Config options help us choose which features to enable
for each product, resolving some of the conflicting requirements.

-Frank

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
