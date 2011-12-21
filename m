Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 52B986B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:31:17 -0500 (EST)
Message-ID: <4EF144D1.2020807@am.sony.com>
Date: Tue, 20 Dec 2011 18:30:41 -0800
From: Frank Rowand <frank.rowand@am.sony.com>
Reply-To: <frank.rowand@am.sony.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219121255.GA2086@tiehlicka.suse.cz> <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com> <20111220145654.GA26881@oksana.dev.rtsoft.ru> <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com> <20111221002853.GA11504@oksana.dev.rtsoft.ru> <4EF132EA.7000300@am.sony.com> <20111221020723.GA5214@oksana.dev.rtsoft.ru>
In-Reply-To: <20111221020723.GA5214@oksana.dev.rtsoft.ru>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: "Rowand, Frank" <Frank_Rowand@sonyusa.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "tbird20d@gmail.com" <tbird20d@gmail.com>

On 12/20/11 18:07, Anton Vorontsov wrote:
> On Tue, Dec 20, 2011 at 05:14:18PM -0800, Frank Rowand wrote:

< snip >

>> And for embedded and for real-time, some of us do not want cgroups to be
>> a mandatory thing.  We want it to remain configurable.  My personal
>> interest is in keeping the latency of certain critical paths (especially
>> in the scheduler) short and consistent.
> 
> Much thanks for your input! That would be quite strong argument for going
> with /dev/mem_notify approach. Do you have any specific numbers how cgroups
> makes scheduler latencies worse?

Sorry, I don't have specific numbers.  And the numbers would be workload
specific anyway.

-Frank

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
