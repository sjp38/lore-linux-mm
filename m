Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC066B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 05:59:31 -0400 (EDT)
Message-ID: <4E576E6F.1030909@openvz.org>
Date: Fri, 26 Aug 2011 13:59:11 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: skip frozen tasks
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz> <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <4E574CA5.4010701@openvz.org> <alpine.DEB.2.00.1108260209050.14732@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1108260209050.14732@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

David Rientjes wrote:
> On Fri, 26 Aug 2011, Konstantin Khlebnikov wrote:
>
>>> A much better solution would be to lower the badness score that the oom
>>> killer uses for PF_FROZEN threads so that they aren't considered a
>>> priority for kill unless there's nothing else left to kill.
>>
>> Anyway, oom killer shouldn't loop endlessly if it see TIF_MEMDIE on frozen
>> task,
>> it must go on and try to kill somebody else. We cannot wait for thawing this
>> task.
>>
>
> Did you read my suggestion?  I quoted it above again for you.  The badness
> heuristic would only select those tasks to kill as a last resort in the
> hopes they will eventually be thawed and may exit.  Panicking the entire
> machine for what could be isolated by a cgroup is insanity.

Maybe just fix this "panic" logic? OOM killer should panic only on global memory shortage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
