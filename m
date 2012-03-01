Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0BBF56B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 03:06:51 -0500 (EST)
Received: by bkwq16 with SMTP id q16so286490bkw.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2012 00:06:49 -0800 (PST)
Message-ID: <4F4F2E16.5080703@openvz.org>
Date: Thu, 01 Mar 2012 12:06:46 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH resend] mm: drain percpu lru add/rotate page-vectors on
 cpu hot-unplug
References: <20120228193620.32063.83425.stgit@zurg> <20120229123818.61a61e9d.akpm@linux-foundation.org>
In-Reply-To: <20120229123818.61a61e9d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Andrew Morton wrote:
> On Tue, 28 Feb 2012 23:40:45 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This cpu hotplug hook was accidentally removed in commit v2.6.30-rc4-18-g00a62ce
>> ("mm: fix Committed_AS underflow on large NR_CPUS environment")
>
> That was a long time ago - maybe we should leave it removed ;) I mean,
> did this bug(?) have any visible effect?  If so, what was that effect?

It's because cpu hotplug/unplug isn't widely used feature.
Visible effect -- some pages are borrowed in per-cpu page-vectors.
Truncate can deal with it, but these pages cannot be reused while this cpu is offline.
So this is like temporary memory leak.

>
> IOW, the changelog didn't give anyone any reason to apply the patch to
> anything!

Sorry, I'm just stuck in pile of patches. It seems I should stop and send them one by one.
This one isn't critical, so there no reasons for pushing it into stable branches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
